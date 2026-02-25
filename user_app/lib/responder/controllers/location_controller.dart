import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Manages device GPS access and current position state.
///
/// Strategy for accuracy:
/// 1. Shows the last-known position instantly (prevents blank screen).
/// 2. Opens a high-accuracy position stream and replaces the position each
///    time a *better* fix arrives (lower accuracy radius = better).
/// 3. Stops the stream once accuracy ≤ [_targetAccuracyMeters] or after
///    [_timeoutSeconds] seconds, whichever comes first.
///
/// Call [requestPermissionAndFetch] once on screen entry.
class LocationController extends ChangeNotifier {
  // ── Tuning constants ──────────────────────────────────────────────────────

  /// Stop streaming once the fix is this accurate (in metres).
  static const double _targetAccuracyMeters = 30.0;

  /// Give up streaming after this many seconds (keeps the best fix so far).
  static const int _timeoutSeconds = 20;

  // ── State ─────────────────────────────────────────────────────────────────
  Position? _currentPosition;
  LocationFetchState _fetchState = LocationFetchState.idle;
  String? _errorMessage;

  StreamSubscription<Position>? _positionSub;
  Timer? _timeoutTimer;

  Position? get currentPosition => _currentPosition;
  LocationFetchState get fetchState => _fetchState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _fetchState == LocationFetchState.loading;
  bool get hasError => _fetchState == LocationFetchState.error;

  double get latitude => _currentPosition?.latitude ?? 0.0;
  double get longitude => _currentPosition?.longitude ?? 0.0;

  // ── Public actions ─────────────────────────────────────────────────────────

  Future<void> requestPermissionAndFetch() async {
    // Cancel any in-flight stream from a previous call.
    _cancelStream();

    _setFetchState(LocationFetchState.loading);
    _errorMessage = null;

    try {
      // 1. Check GPS service is enabled.
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        _errorMessage = 'location_service_disabled';
        _setFetchState(LocationFetchState.error);
        return;
      }

      // 2. Ensure permission is granted.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _errorMessage = 'location_permission_denied';
        _setFetchState(LocationFetchState.error);
        return;
      }

      // 3. Show last-known position instantly so the map isn't blank.
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && _currentPosition == null) {
        _currentPosition = lastKnown;
        _setFetchState(LocationFetchState.loaded);
      }

      // 4. Stream high-accuracy fixes; keep upgrading until target is met.
      final settings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        intervalDuration: Duration(seconds: 2),
        forceLocationManager: false,
      );

      _positionSub = Geolocator.getPositionStream(locationSettings: settings)
          .listen(
        (position) {
          // Accept this fix if we have nothing yet, OR it is more accurate
          // than the current position.
          final current = _currentPosition;
          final isBetter = current == null ||
              position.accuracy < current.accuracy;

          if (isBetter) {
            _currentPosition = position;
            _setFetchState(LocationFetchState.loaded);
            debugPrint(
              '[LocationController] fix updated – '
              'accuracy: ${position.accuracy.toStringAsFixed(1)} m',
            );
          }

          // Stop streaming once we have a sufficiently accurate fix.
          if (position.accuracy <= _targetAccuracyMeters) {
            debugPrint(
              '[LocationController] target accuracy reached '
              '(${position.accuracy.toStringAsFixed(1)} m ≤ '
              '${_targetAccuracyMeters} m) – stopping stream.',
            );
            _cancelStream();
          }
        },
        onError: (e) {
          debugPrint('[LocationController] position stream error: $e');
          // Keep showing whatever fix we have; only error out if we have none.
          if (_currentPosition == null) {
            _errorMessage = e.toString();
            _setFetchState(LocationFetchState.error);
          }
          _cancelStream();
        },
      );

      // 5. Hard timeout – stop streaming after _timeoutSeconds regardless.
      _timeoutTimer = Timer(Duration(seconds: _timeoutSeconds), () {
        if (_positionSub != null) {
          debugPrint(
            '[LocationController] timeout after ${_timeoutSeconds}s – '
            'keeping best fix so far '
            '(accuracy: ${_currentPosition?.accuracy.toStringAsFixed(1) ?? "none"} m).',
          );
          _cancelStream();
        }
      });
    } catch (e) {
      debugPrint('[LocationController] requestPermissionAndFetch error: $e');
      _errorMessage = e.toString();
      _setFetchState(LocationFetchState.error);
    }
  }

  // ── Disposal ───────────────────────────────────────────────────────────────

  void _cancelStream() {
    _positionSub?.cancel();
    _positionSub = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  @override
  void dispose() {
    _cancelStream();
    super.dispose();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setFetchState(LocationFetchState newState) {
    _fetchState = newState;
    notifyListeners();
  }
}

enum LocationFetchState { idle, loading, loaded, error }
