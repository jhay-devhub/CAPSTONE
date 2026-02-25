import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/help_report_model.dart';
<<<<<<< HEAD
import '../services/device_id_service.dart';
import '../services/firestore_service.dart';
=======
import '../services/firestore_report_service.dart';
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f

/// Manages the state and logic for sending an emergency help report.
/// Uses [ChangeNotifier] so the UI can rebuild reactively.
///
/// After a report is submitted the controller opens a Firestore stream on
/// that device's reports so [liveStatus] stays up-to-date in real-time
/// (e.g. pending → acknowledged → in-progress).
class HelpReportController extends ChangeNotifier {
  HelpReportController();

  final FirestoreReportService _firestoreService =
      FirestoreReportService.instance;

  // ── State ─────────────────────────────────────────────────────────────────
  HelpReportState _state = HelpReportState.idle;
  String? _errorMessage;
  HelpReportModel? _lastReport;

<<<<<<< HEAD
  final FirestoreService _firestoreService = FirestoreService.instance;
  final DeviceIdService _deviceIdService = DeviceIdService.instance;
=======
  /// Live status streamed from Firestore after a successful submission.
  HelpReportStatus? _liveStatus;
  StreamSubscription<List<HelpReportModel>>? _statusSub;
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f

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

<<<<<<< HEAD
  /// Sends an emergency help report using the user's [latitude] and [longitude].
  ///
  /// [emergencyType] is required – it determines which vehicle is dispatched.
  /// The device ID is fetched automatically from the hardware.
  Future<void> sendHelpReport({
    required double latitude,
    required double longitude,
=======
  Future<void> sendHelpReport({
    required double latitude,
    required double longitude,
    required String deviceId,
    required String deviceName,
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
    required EmergencyType emergencyType,
    String? description,
    String? injuryNote,
    String? photoPath,
  }) async {
    if (_state == HelpReportState.sending) return;

    _setState(HelpReportState.sending);
    _errorMessage = null;

    try {
      // Fetch the unique device ID automatically
      final deviceId = await _deviceIdService.getDeviceId();

      final report = HelpReportModel(
<<<<<<< HEAD
        id: '',
        deviceId: deviceId,
=======
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        deviceId: deviceId,
        deviceName: deviceName,
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        emergencyType: emergencyType,
        description: description,
        injuryNote: injuryNote,
        photoPath: photoPath,
      );

<<<<<<< HEAD
      // Send to Firestore
      final docId = await _firestoreService.submitHelpReport(report);

      _lastReport = report.copyWith(
        id: docId,
        status: HelpReportStatus.pending,
      );
=======
      final firestoreId = await _firestoreService.submitReport(report);

      _lastReport = report.copyWith(
        firestoreId: firestoreId,
        status: HelpReportStatus.pending,
      );
      _liveStatus = HelpReportStatus.pending;

      // Open a real-time stream so the status banner reflects admin updates.
      _startStatusStream(deviceId);

>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
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
      final latest = reports.first; // ordered newest-first
      _liveStatus = latest.status;
      _lastReport = latest;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[HelpReportController] status stream error: $e');
    });
  }

  void _setState(HelpReportState newState) {
    _state = newState;
    notifyListeners();
  }
<<<<<<< HEAD
=======

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
}

enum HelpReportState { idle, sending, success, failure }

