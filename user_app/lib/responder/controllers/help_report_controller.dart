import 'package:flutter/foundation.dart';
import '../models/help_report_model.dart';
import '../services/device_id_service.dart';
import '../services/firestore_service.dart';

/// Manages the state and logic for sending an emergency help report.
/// Uses [ChangeNotifier] so the UI can rebuild reactively.
class HelpReportController extends ChangeNotifier {
  HelpReportController();

  // ── State ─────────────────────────────────────────────────────────────────
  HelpReportState _state = HelpReportState.idle;
  String? _errorMessage;
  HelpReportModel? _lastReport;

  final FirestoreService _firestoreService = FirestoreService.instance;
  final DeviceIdService _deviceIdService = DeviceIdService.instance;

  HelpReportState get state => _state;
  String? get errorMessage => _errorMessage;
  HelpReportModel? get lastReport => _lastReport;
  bool get isSending => _state == HelpReportState.sending;

  // ── Public actions ─────────────────────────────────────────────────────────

  /// Sends an emergency help report using the user's [latitude] and [longitude].
  ///
  /// [emergencyType] is required – it determines which vehicle is dispatched.
  /// The device ID is fetched automatically from the hardware.
  Future<void> sendHelpReport({
    required double latitude,
    required double longitude,
    required EmergencyType emergencyType,
    String? description,
    String? injuryNote,
    String? photoPath,
  }) async {
    if (_state == HelpReportState.sending) return; // prevent duplicate taps

    _setState(HelpReportState.sending);
    _errorMessage = null;

    try {
      // Fetch the unique device ID automatically
      final deviceId = await _deviceIdService.getDeviceId();

      final report = HelpReportModel(
        id: '',
        deviceId: deviceId,
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        emergencyType: emergencyType,
        description: description,
        injuryNote: injuryNote,
        photoPath: photoPath,
      );

      // Send to Firestore
      final docId = await _firestoreService.submitHelpReport(report);

      _lastReport = report.copyWith(
        id: docId,
        status: HelpReportStatus.pending,
      );
      _setState(HelpReportState.success);
    } catch (e) {
      debugPrint('[HelpReportController] sendHelpReport error: $e');
      _errorMessage = e.toString();
      _setState(HelpReportState.failure);
    }
  }

  /// Resets state back to idle (e.g. after showing a result snackbar).
  void reset() {
    _state = HelpReportState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _setState(HelpReportState newState) {
    _state = newState;
    notifyListeners();
  }
}

enum HelpReportState { idle, sending, success, failure }
