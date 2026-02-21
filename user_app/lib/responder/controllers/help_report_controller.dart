import 'package:flutter/foundation.dart';
import '../models/help_report_model.dart';

/// Manages the state and logic for sending an emergency help report.
/// Uses [ChangeNotifier] so the UI can rebuild reactively.
class HelpReportController extends ChangeNotifier {
  HelpReportController();

  // ── State ─────────────────────────────────────────────────────────────────
  HelpReportState _state = HelpReportState.idle;
  String? _errorMessage;
  HelpReportModel? _lastReport;

  HelpReportState get state => _state;
  String? get errorMessage => _errorMessage;
  HelpReportModel? get lastReport => _lastReport;
  bool get isSending => _state == HelpReportState.sending;

  // ── Public actions ─────────────────────────────────────────────────────────

  /// Sends an emergency help report using the user's [latitude] and [longitude].
  ///
  /// [emergencyType] is required – it determines which vehicle is dispatched.
  /// All other fields are optional supplementary information.
  /// Replace the body of [_sendReportToBackend] with your real API call.
  Future<void> sendHelpReport({
    required double latitude,
    required double longitude,
    required String userId,
    required EmergencyType emergencyType,
    String? description,
    String? injuryNote,
    String? photoPath,
  }) async {
    if (_state == HelpReportState.sending) return; // prevent duplicate taps

    _setState(HelpReportState.sending);
    _errorMessage = null;

    try {
      final report = HelpReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        emergencyType: emergencyType,
        description: description,
        injuryNote: injuryNote,
        photoPath: photoPath,
      );

      await _sendReportToBackend(report);

      _lastReport = report.copyWith(status: HelpReportStatus.acknowledged);
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

  /// TODO: Replace with a real HTTP / Firebase call.
  Future<void> _sendReportToBackend(HelpReportModel report) async {
    // Simulated network delay – remove once real API is integrated.
    await Future<void>.delayed(const Duration(seconds: 2));

    debugPrint('[HelpReportController] Report sent: ${report.toJson()}');

    // Throw an exception here to test the error path during development:
    // throw Exception('Server unavailable');
  }
}

enum HelpReportState { idle, sending, success, failure }
