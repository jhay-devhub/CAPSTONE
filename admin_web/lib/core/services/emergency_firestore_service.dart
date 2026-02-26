import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../features/admin/models/emergency_model.dart';

/// Handles real-time Firestore reads and writes for the admin dashboard.
///
/// Reads from the same `emergency_report` collection that the user_app writes
/// to, so no schema changes are required on either side.
class EmergencyFirestoreService {
  EmergencyFirestoreService._();

  static final EmergencyFirestoreService instance =
      EmergencyFirestoreService._();

  static const String _collection = 'emergency_report';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Streams all emergency reports from Firestore in real-time, newest first.
  ///
  /// Documents that fail to deserialize are skipped and logged so a single
  /// malformed document never crashes the entire live feed.
  Stream<List<EmergencyReport>> watchAllReports() {
    return _db
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final reports = <EmergencyReport>[];
      for (final doc in snapshot.docs) {
        try {
          reports.add(EmergencyReport.fromFirestore(doc));
        } catch (e) {
          debugPrint(
            '[EmergencyFirestoreService] Skipping malformed doc ${doc.id}: $e',
          );
        }
      }
      return reports;
    });
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Updates the `status` field of an emergency report document.
  ///
  /// Uses [EmergencyStatus.toFirestoreString] to convert the admin's status
  /// enum back to the user-app's status naming convention (e.g. `inProgress`).
  Future<void> updateStatus(
      String docId, EmergencyStatus newStatus) async {
    try {
      await _db.collection(_collection).doc(docId).update({
        'status': newStatus.toFirestoreString(),
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint(
        '[EmergencyFirestoreService] updateStatus error for $docId: ${e.message}',
      );
      rethrow;
    }
  }

  /// Overwrites the `assignedUnits` list on a report document.
  Future<void> updateAssignedUnits(
      String docId, List<String> units) async {
    try {
      await _db.collection(_collection).doc(docId).update({
        'assignedUnits': units,
      });
    } on FirebaseException catch (e) {
      debugPrint(
        '[EmergencyFirestoreService] updateAssignedUnits error for $docId: ${e.message}',
      );
      rethrow;
    }
  }
}
