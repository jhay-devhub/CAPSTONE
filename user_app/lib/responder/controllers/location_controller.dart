import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Manages device GPS access and current position state.
/// Call [requestPermissionAndFetch] once on screen entry.
class LocationController extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────
  Position? _currentPosition;
  LocationFetchState _fetchState = LocationFetchState.idle;
  String? _errorMessage;

  Position? get currentPosition => _currentPosition;
  LocationFetchState get fetchState => _fetchState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _fetchState == LocationFetchState.loading;
  bool get hasError => _fetchState == LocationFetchState.error;

  double get latitude => _currentPosition?.latitude ?? 0.0;
  double get longitude => _currentPosition?.longitude ?? 0.0;

  // ── Public actions ─────────────────────────────────────────────────────────

  Future<void> requestPermissionAndFetch() async {
    _setFetchState(LocationFetchState.loading);
    _errorMessage = null;

    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        _errorMessage = 'location_service_disabled';
        _setFetchState(LocationFetchState.error);
        return;
      }

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

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _setFetchState(LocationFetchState.loaded);
    } catch (e) {
      debugPrint('[LocationController] requestPermissionAndFetch error: $e');
      _errorMessage = e.toString();
      _setFetchState(LocationFetchState.error);
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setFetchState(LocationFetchState newState) {
    _fetchState = newState;
    notifyListeners();
  }
}

enum LocationFetchState { idle, loading, loaded, error }
