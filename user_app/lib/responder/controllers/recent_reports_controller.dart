import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/help_report_model.dart';
import '../services/firestore_report_service.dart';

/// Streams the most-recent [maxReports] emergency reports for a given device.
///
/// Used by [HomeScreen] to display a "Recent Reports" section that updates
/// live whenever Firestore changes (status updates, deletions, new reports).
class RecentReportsController extends ChangeNotifier {
  RecentReportsController({required String deviceId, this.maxReports = 3}) {
    _init(deviceId);
  }

  /// Maximum number of reports to show. Defaults to 3.
  final int maxReports;

  // ── State ─────────────────────────────────────────────────────────────────

  List<HelpReportModel> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<List<HelpReportModel>>? _sub;

  List<HelpReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get isEmpty => _reports.isEmpty;
  String? get errorMessage => _errorMessage;

  // ── Init ──────────────────────────────────────────────────────────────────

  void _init(String deviceId) {
    _sub = FirestoreReportService.instance
        .watchReportsByDevice(deviceId)
        .listen(
      (all) {
        // The stream is already sorted newest-first; take at most [maxReports].
        _reports = all.take(maxReports).toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('[RecentReportsController] stream error: $e');
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Disposal ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
