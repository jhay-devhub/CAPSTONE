import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/help_report_model.dart';
import '../services/device_id_service.dart';
import '../services/firestore_report_service.dart';

/// Manages the state and logic for sending an emergency help report.
/// Uses [ChangeNotifier] so the UI can rebuild reactively.
///
/// After a report is submitted the controller opens a Firestore stream on
/// that device's reports so [liveStatus] stays up-to-date in real-time
/// (e.g. pending → acknowledged → in-progress).
class HelpReportController extends ChangeNotifier {
  HelpReportController() {
    _autoRestore();
  }

  final FirestoreReportService _firestoreService =
      FirestoreReportService.instance;

  // ── State ─────────────────────────────────────────────────────────────────
  HelpReportState _state = HelpReportState.idle;
  String? _errorMessage;
  HelpReportModel? _lastReport;

  /// Live status streamed from Firestore after a successful submission.
  HelpReportStatus? _liveStatus;
  StreamSubscription<List<HelpReportModel>>? _statusSub;

  HelpReportState get state => _state;
  String? get errorMessage => _errorMessage;
  HelpReportModel? get lastReport => _lastReport;
  HelpReportStatus? get liveStatus => _liveStatus;
  bool get isSending => _state == HelpReportState.sending;

  /// True when a submitted report is still active (not resolved/cancelled).
  bool get hasActiveReport =>
      _liveStatus != null &&
      _liveStatus != HelpReportStatus.resolved &&
      _liveStatus != HelpReportStatus.cancelled;

  // ── Public actions ─────────────────────────────────────────────────────────

  Future<void> sendHelpReport({
    required double latitude,
    required double longitude,
    required String deviceId,
    required String deviceName,
    required EmergencyType emergencyType,
    String? description,
    String? injuryNote,
    String? photoPath,
  }) async {
    if (_state == HelpReportState.sending) return;

    _setState(HelpReportState.sending);
    _errorMessage = null;

    try {
      final report = HelpReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        deviceId: deviceId,
        deviceName: deviceName,
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        emergencyType: emergencyType,
        description: description,
        injuryNote: injuryNote,
        photoPath: photoPath,
      );

      final firestoreId = await _firestoreService.submitReport(report);

      _lastReport = report.copyWith(
        firestoreId: firestoreId,
        status: HelpReportStatus.pending,
      );
      _liveStatus = HelpReportStatus.pending;

      // Open a real-time stream so the status banner reflects admin updates.
      _startStatusStream(deviceId);

      _setState(HelpReportState.success);
    } catch (e, stack) {
      debugPrint('[HelpReportController] sendHelpReport error: $e');
      debugPrint('[HelpReportController] stack: $stack');
      _errorMessage = e.toString();
      _setState(HelpReportState.failure);
    }
  }

  /// Resets the send-state to idle while keeping [liveStatus] alive so the
  /// status banner continues showing the current report state.
  void reset() {
    _state = HelpReportState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Called once on construction: fetches device ID and subscribes to any
  /// existing active report so the banner reappears after an app restart.
  Future<void> _autoRestore() async {
    try {
      final deviceId = await DeviceIdService.instance.getDeviceId();
      _startStatusStream(deviceId);
    } catch (e) {
      debugPrint('[HelpReportController] autoRestore error: $e');
    }
  }

  void _startStatusStream(String deviceId) {
    _statusSub?.cancel();
    _statusSub = _firestoreService
        .watchReportsByDevice(deviceId)
        .listen((reports) {
      if (reports.isEmpty) {
        // Document was deleted from Firestore — clear the live status.
        _liveStatus = null;
        _lastReport = null;
        notifyListeners();
        return;
      }
      // Use the most recent non-resolved/cancelled report, or null if all done.
      final active = reports.where(
        (r) =>
            r.status != HelpReportStatus.resolved &&
            r.status != HelpReportStatus.cancelled,
      ).toList();
      if (active.isEmpty) {
        _liveStatus = null;
        _lastReport = null;
      } else {
        final latest = active.first;
        _liveStatus = latest.status;
        _lastReport = latest;
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint('[HelpReportController] status stream error: $e');
    });
  }

  void _setState(HelpReportState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }
}

enum HelpReportState { idle, sending, success, failure }

