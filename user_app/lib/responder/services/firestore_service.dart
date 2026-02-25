import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/help_report_model.dart';

/// Singleton service that handles all Firestore CRUD operations.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection references ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('emergency');

  // ── Help Reports ───────────────────────────────────────────────────────────

  /// Submit a new help report. Returns the Firestore document ID.
  Future<String> submitHelpReport(HelpReportModel report) async {
    final data = report.toFirestore();
    final docRef = await _reports.add(data);
    debugPrint('[FirestoreService] Report created: ${docRef.id}');
    return docRef.id;
  }

  /// Stream real-time updates for a single report (useful for tracking).
  Stream<HelpReportModel?> watchReport(String reportId) {
    return _reports.doc(reportId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return HelpReportModel.fromFirestore(doc);
    });
  }

  /// Stream all reports for a specific device, ordered newest first.
  Stream<List<HelpReportModel>> watchDeviceReports(String deviceId) {
    return _reports
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HelpReportModel.fromFirestore(doc))
            .toList());
  }

  /// Fetch a single report once.
  Future<HelpReportModel?> getReport(String reportId) async {
    final doc = await _reports.doc(reportId).get();
    if (!doc.exists || doc.data() == null) return null;
    return HelpReportModel.fromFirestore(doc);
  }

  /// Update the status of an existing report.
  Future<void> updateReportStatus(
    String reportId,
    HelpReportStatus status,
  ) async {
    await _reports.doc(reportId).update({'status': status.name});
  }

  /// Cancel a report.
  Future<void> cancelReport(String reportId) async {
    await updateReportStatus(reportId, HelpReportStatus.cancelled);
  }
}
