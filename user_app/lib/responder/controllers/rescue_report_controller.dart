import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/help_report_model.dart';
import '../services/device_id_service.dart';
import '../services/firestore_report_service.dart';

/// Streams the user's most-recent active emergency report from Firestore.
///
/// Used by [RescueTrackingScreen] to:
///   • Show a live status panel (pending → acknowledged → in-progress)
///   • Place a marker on the map at the reported location
///
/// The stream auto-updates whenever the admin changes the report status.
class RescueReportController extends ChangeNotifier {
  RescueReportController() {
    _init();
  }

  // ── State ─────────────────────────────────────────────────────────────────

  HelpReportModel? _activeReport;
  bool _isLoading = true;
  String? _errorMessage;

  HelpReportModel? get activeReport => _activeReport;
  bool get isLoading => _isLoading;
  bool get hasReport => _activeReport != null;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<HelpReportModel>>? _sub;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    try {
      final deviceId = await DeviceIdService.instance.getDeviceId();
      _sub = FirestoreReportService.instance
          .watchReportsByDevice(deviceId)
          .listen(
        (reports) {
          // If the document was deleted the list will be empty — clear state.
          if (reports.isEmpty) {
            _activeReport = null;
          } else {
            // Pick the first non-resolved, non-cancelled report (newest first).
            _activeReport = reports.firstWhere(
              (r) =>
                  r.status != HelpReportStatus.resolved &&
                  r.status != HelpReportStatus.cancelled,
              orElse: () => reports.first,
            );
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('[RescueReportController] stream error: $e');
          _errorMessage = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('[RescueReportController] init error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
