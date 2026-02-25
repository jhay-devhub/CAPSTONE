import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/help_report_model.dart';

/// Handles all Firestore read/write operations for emergency reports.
///
/// Collection: `emergency_report`
///
/// Each document uses an auto-generated Firestore ID and stores the fields
/// defined in [HelpReportModel.toFirestore].  The same collection is read by
/// the admin web dashboard, so field names must remain stable.
class FirestoreReportService {
  FirestoreReportService._();

  static final FirestoreReportService instance = FirestoreReportService._();

  static const String _collection = 'emergency_report';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Saves a new emergency report to Firestore.
  ///
  /// Returns the Firestore document ID assigned to this report.
  /// Throws a [FirebaseException] on network / permission errors.
  Future<String> submitReport(HelpReportModel report) async {
    try {
      final docRef = await _db
          .collection(_collection)
          .add(report.toFirestore());

      debugPrint('[FirestoreReportService] Report saved: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('[FirestoreReportService] submitReport error: ${e.message}');
      rethrow;
    }
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Streams all reports submitted by a specific device, ordered by newest
  /// first. Sorting is done client-side to avoid requiring a composite index.
  Stream<List<HelpReportModel>> watchReportsByDevice(String deviceId) {
    return _db
        .collection(_collection)
        .where('deviceId', isEqualTo: deviceId)
        .snapshots()
        .map((snapshot) {
      final reports = snapshot.docs
          .map((doc) => HelpReportModel.fromFirestore(doc))
          .toList();
      // Sort newest-first in Dart (avoids composite index on deviceId+timestamp).
      reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reports;
    });
  }

  /// Fetches the single most-recent report from a device (one-time read).
  Future<HelpReportModel?> getLatestReport(String deviceId) async {
    final snapshot = await _db
        .collection(_collection)
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return HelpReportModel.fromFirestore(snapshot.docs.first);
  }

  // ── Update ────────────────────────────────────────────────────────────────

  /// Updates only the `status` field of an existing report.
  /// Called if/when the user cancels or the admin updates the status.
  Future<void> updateStatus(String docId, HelpReportStatus status) async {
    await _db.collection(_collection).doc(docId).update({
      'status': status.name,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}
