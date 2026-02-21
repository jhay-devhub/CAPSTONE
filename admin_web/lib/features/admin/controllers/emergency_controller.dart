import 'package:get/get.dart';

import '../models/emergency_model.dart';

/// GetX controller for the emergency list and chat panel.
///
/// Currently uses placeholder/mock data so the UI works immediately.
/// To connect Firebase:
///   1. Replace [_loadMockReports] with a Firestore stream subscription.
///   2. Replace [_loadMockMessages] with a Firestore subcollection stream.
///   3. Replace [sendMessage] with a Firestore `add()` call.
///   4. Replace [updateStatus] with a Firestore `update()` call.
class EmergencyController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────

  final RxList<EmergencyReport> _allReports = <EmergencyReport>[].obs;
  final Rx<EmergencyReport?> selectedReport = Rx<EmergencyReport?>(null);
  final RxString statusFilter = 'all'.obs; // 'all' | 'active' | 'pending' | 'resolved'
  final RxString activeTab = 'list'.obs;   // 'list' | 'details'
  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;
  final RxBool isSendingMessage = false.obs;

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
    _loadMockReports();
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

  void updateStatus(EmergencyReport report, EmergencyStatus newStatus) {
    // TODO: Replace with Firestore update.
    final index = _allReports.indexWhere((r) => r.id == report.id);
    if (index == -1) return;
    final updated = report.copyWith(
      status: newStatus,
      timeline: [
        ...report.timeline,
        TimelineEvent(
          time: DateTime.now(),
          description: 'Status updated to ${newStatus.label}',
        ),
      ],
    );
    _allReports[index] = updated;
    if (selectedReport.value?.id == report.id) {
      selectedReport.value = updated;
    }
    _allReports.refresh();
  }

  /// Assign a new responder to the given report.
  /// TODO: Replace body with Firestore update when connecting Firebase.
  void assignResponder(EmergencyReport report, Responder responder) {
    final index = _allReports.indexWhere((r) => r.id == report.id);
    if (index == -1) return;
    final updated = report.copyWith(
      responders: [...report.responders, responder],
      timeline: [
        ...report.timeline,
        TimelineEvent(
          time: DateTime.now(),
          description: '${responder.name} (${responder.role}) dispatched',
        ),
      ],
    );
    _allReports[index] = updated;
    if (selectedReport.value?.id == report.id) {
      selectedReport.value = updated;
    }
    _allReports.refresh();
  }

  // ── Mock data (replace with Firebase streams) ──────────────────────────────

  void _loadMockReports() {
    _allReports.assignAll([
      EmergencyReport(
        id: 'EM001',
        type: EmergencyType.fire,
        status: EmergencyStatus.active,
        priority: EmergencyPriority.critical,
        address: 'Brgy. Bambang, Los Baños',
        district: 'Los Baños',
        description: 'Structure fire in a 2-storey residential building. Flames visible on second floor.',
        assignedUnits: ['BFP Unit 1', 'BFP Unit 2'],
        reportedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        reporterId: 'user-001',
        reporterName: 'Juan dela Cruz',
        latitude: 14.1680,
        longitude: 121.2170,
        responders: const [
          Responder(id: 'r1', name: 'Firefighter Mike', role: 'Firefighter', status: 'En route'),
          Responder(id: 'r2', name: 'Firefighter Sarah', role: 'Firefighter', status: 'En route'),
        ],
        timeline: [
          TimelineEvent(time: DateTime.now().subtract(const Duration(minutes: 20)), description: 'Emergency reported'),
          TimelineEvent(time: DateTime.now().subtract(const Duration(minutes: 15)), description: 'BFP units dispatched'),
        ],
      ),
      EmergencyReport(
        id: 'EM002',
        type: EmergencyType.medical,
        status: EmergencyStatus.active,
        priority: EmergencyPriority.high,
        address: 'Brgy. Putho-Tuntungin, Los Baños',
        district: 'Los Baños',
        description: 'Patient unconscious, suspected cardiac arrest. Bystanders performing CPR.',
        assignedUnits: ['RHU Ambulance'],
        reportedAt: DateTime.now().subtract(const Duration(minutes: 35)),
        reporterId: 'user-002',
        reporterName: 'Maria Santos',
        latitude: 14.1660,
        longitude: 121.2180,
        responders: const [
          Responder(id: 'r3', name: 'Paramedic Reyes', role: 'Paramedic', status: 'On scene'),
        ],
        timeline: [
          TimelineEvent(time: DateTime.now().subtract(const Duration(minutes: 35)), description: 'Emergency reported'),
          TimelineEvent(time: DateTime.now().subtract(const Duration(minutes: 28)), description: 'Ambulance dispatched'),
          TimelineEvent(time: DateTime.now().subtract(const Duration(minutes: 10)), description: 'Paramedic arrived on scene'),
        ],
      ),
      EmergencyReport(
        id: 'EM003',
        type: EmergencyType.police,
        status: EmergencyStatus.active,
        priority: EmergencyPriority.high,
        address: 'Brgy. Batong Malake, Los Baños',
        district: 'Los Baños',
        description: 'Reported theft in progress at a convenience store. Suspect still on premises.',
        assignedUnits: ['LB PNP Unit 3'],
        reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
        reporterId: 'user-003',
        reporterName: 'Pedro Reyes',
        latitude: 14.1700,
        longitude: 121.2135,
        responders: const [
          Responder(id: 'r4', name: 'Officer Cruz', role: 'Officer', status: 'On scene'),
          Responder(id: 'r5', name: 'Officer Lim', role: 'Officer', status: 'En route'),
        ],
        timeline: [
          TimelineEvent(time: DateTime.now().subtract(const Duration(hours: 1)), description: 'Emergency reported'),
          TimelineEvent(time: DateTime.now().subtract(const Duration(minutes: 50)), description: 'PNP units dispatched'),
        ],
      ),
      EmergencyReport(
        id: 'EM004',
        type: EmergencyType.flood,
        status: EmergencyStatus.pending,
        priority: EmergencyPriority.high,
        address: 'Brgy. Mayondon, Los Baños',
        district: 'Los Baños',
        description: 'Rising flood water near the lakeshore. Several households requesting evacuation.',
        assignedUnits: ['MDRRMO Team A'],
        reportedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        reporterId: 'user-004',
        reporterName: 'Ana Lim',
        latitude: 14.1720,
        longitude: 121.2210,
        responders: const [],
        timeline: [
          TimelineEvent(time: DateTime.now().subtract(const Duration(minutes: 10)), description: 'Emergency reported'),
        ],
      ),
      EmergencyReport(
        id: 'EM005',
        type: EmergencyType.fire,
        status: EmergencyStatus.resolved,
        priority: EmergencyPriority.medium,
        address: 'Brgy. San Antonio, Los Baños',
        district: 'Los Baños',
        description: 'Small grass fire along the road. Contained before spreading to structures.',
        assignedUnits: ['BFP Unit 3'],
        reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
        reporterId: 'user-005',
        reporterName: 'Jose Garcia',
        latitude: 14.1650,
        longitude: 121.2090,
        responders: const [
          Responder(id: 'r6', name: 'Firefighter Bautista', role: 'Firefighter', status: 'Available'),
        ],
        timeline: [
          TimelineEvent(time: DateTime.now().subtract(const Duration(hours: 3)), description: 'Emergency reported'),
          TimelineEvent(time: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)), description: 'BFP Unit 3 dispatched'),
          TimelineEvent(time: DateTime.now().subtract(const Duration(hours: 2)), description: 'Fire contained'),
          TimelineEvent(time: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)), description: 'Incident resolved'),
        ],
      ),
    ]);
  }

  void _loadMockMessages(String emergencyId) {
    // TODO: Replace with Firestore stream: FirebaseFirestore.instance
    //   .collection('emergencies').doc(emergencyId).collection('messages')
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
