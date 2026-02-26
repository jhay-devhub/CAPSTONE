import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/services/emergency_firestore_service.dart';
import '../models/emergency_model.dart';

/// GetX controller for the emergency list and chat panel.
///
/// Subscribes to real-time Firestore streams and exposes reactive state
/// for the UI to observe. All reports are read-only from the dashboard;
/// the user_app is the single source of truth for submissions.
class EmergencyController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────

  final RxList<EmergencyReport> _allReports = <EmergencyReport>[].obs;
  final Rx<EmergencyReport?> selectedReport = Rx<EmergencyReport?>(null);
  final RxString statusFilter = 'all'.obs; // 'all' | 'active' | 'pending' | 'resolved'
  final RxString activeTab = 'list'.obs;   // 'list' | 'details'
  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;
  final RxBool isSendingMessage = false.obs;
  final RxBool isLoadingReports = true.obs;

  // ── Services ───────────────────────────────────────────────────────────────

  final EmergencyFirestoreService _firestoreService =
      EmergencyFirestoreService.instance;

  // ── Derived ────────────────────────────────────────────────────────────────

  /// Exposed so map widgets can observe all reports for marker rendering.
  RxList<EmergencyReport> get allReportsRx => _allReports;

  List<EmergencyReport> get filteredReports {
    if (statusFilter.value == 'all') return _allReports;
    final status = EmergencyStatus.values.byName(statusFilter.value);
    return _allReports.where((r) => r.status == status).toList();
  }

  int get totalCount => _allReports.length;
  int get activeCount =>
      _allReports.where((r) => r.status == EmergencyStatus.active).length;
  int get pendingCount =>
      _allReports.where((r) => r.status == EmergencyStatus.pending).length;
  int get resolvedCount =>
      _allReports.where((r) => r.status == EmergencyStatus.resolved).length;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _subscribeToReports();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void setFilter(String filter) => statusFilter.value = filter;

  void setTab(String tab) => activeTab.value = tab;

  void selectReport(EmergencyReport report) {
    selectedReport.value = report;
    activeTab.value = 'details'; // open Details tab automatically
    _loadMockMessages(report.id);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty || selectedReport.value == null) return;

    // TODO: Replace with Firestore add + real admin user id/name from AuthService.
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emergencyId: selectedReport.value!.id,
      senderId: 'admin-001',
      senderName: 'Admin Control',
      isAdmin: true,
      text: text.trim(),
      sentAt: DateTime.now(),
    );
    chatMessages.add(message);
  }

  Future<void> updateStatus(
      EmergencyReport report, EmergencyStatus newStatus) async {
    try {
      // Optimistically update the local list while Firestore processes.
      final index = _allReports.indexWhere((r) => r.id == report.id);
      if (index == -1) return;

      final updated = report.copyWith(status: newStatus);
      _allReports[index] = updated;
      if (selectedReport.value?.id == report.id) {
        selectedReport.value = updated;
      }
      _allReports.refresh();

      // Persist to Firestore.
      await _firestoreService.updateStatus(report.id, newStatus);
    } catch (e) {
      debugPrint('[EmergencyController] updateStatus error: $e');
      rethrow;
    }
  }

  Future<void> updateAssignedUnits(
      EmergencyReport report, List<String> units) async {
    try {
      await _firestoreService.updateAssignedUnits(report.id, units);
    } catch (e) {
      debugPrint('[EmergencyController] updateAssignedUnits error: $e');
      rethrow;
    }
  }

  // ── Firestore streaming ────────────────────────────────────────────────────

  void _subscribeToReports() {
    _firestoreService.watchAllReports().listen(
      (reports) {
        _allReports.assignAll(reports);
        isLoadingReports.value = false;

        // If selected report is no longer in the list, deselect it.
        if (selectedReport.value != null &&
            !reports.any((r) => r.id == selectedReport.value!.id)) {
          selectedReport.value = null;
          activeTab.value = 'list';
        }
      },
      onError: (e) {
        debugPrint('[EmergencyController] Error watching reports: $e');
        isLoadingReports.value = false;
      },
    );
  }

  // ── Mock messages (TODO: Real chat subcollection later) ──────────────────────

  void _loadMockMessages(String emergencyId) {
    // TODO: Replace with Firestore stream: FirebaseFirestore.instance
    //   .collection('emergency_report').doc(emergencyId).collection('messages')
    //   .orderBy('sentAt').snapshots()
    chatMessages.assignAll([
      ChatMessage(
        id: 'msg-001',
        emergencyId: emergencyId,
        senderId: 'admin-001',
        senderName: 'Admin Control',
        isAdmin: true,
        text: 'Response units dispatched. ETA 5 minutes.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      ChatMessage(
        id: 'msg-002',
        emergencyId: emergencyId,
        senderId: 'user-001',
        senderName: 'Reporter',
        isAdmin: false,
        text: 'Please hurry, it\'s spreading fast.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 13)),
      ),
      ChatMessage(
        id: 'msg-003',
        emergencyId: emergencyId,
        senderId: 'admin-001',
        senderName: 'Admin Control',
        isAdmin: true,
        text: 'Stay calm and move away from the area. Units are on the way.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    ]);
  }
}
