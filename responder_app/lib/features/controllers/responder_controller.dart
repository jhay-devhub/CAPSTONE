// features/controllers/responder_controller.dart
// LB-Sentry | Main State Controller
// Architecture: UI → Controller → Mock Data (future: Firebase)

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/mock_data.dart';
import '../models/emergency_model.dart';
import '../models/responder_model.dart';

class ResponderController extends ChangeNotifier {
  // ─── CORE STATE ──────────────────────────────────────────────────────────────
  final ResponderModel _responder = MockData.currentResponder;
  final List<EmergencyModel> _emergencies = List.from(MockData.emergencies);
  EmergencyModel? _selectedEmergency;
  bool _isLoading = false;

  // ─── ASSIGNMENT ALERT STATE ──────────────────────────────────────────────────
  EmergencyModel? _incomingEmergency;
  bool _isDialogVisible = false;
  int _timerSeconds = 60;
  Timer? _countdownTimer;
  bool _isAccepting = false;
  bool _isRejecting = false;

  // ─── HISTORY STATE ───────────────────────────────────────────────────────────
  final List<HistoryEntry> _historyList = [];

  // ─── GETTERS ────────────────────────────────────────────────────────────────
  ResponderModel get responder => _responder;
  List<EmergencyModel> get emergencies => _emergencies;
  EmergencyModel? get selectedEmergency => _selectedEmergency;
  bool get isLoading => _isLoading;
  EmergencyModel? get incomingEmergency => _incomingEmergency;
  bool get isDialogVisible => _isDialogVisible;
  int get timerSeconds => _timerSeconds;
  bool get isAccepting => _isAccepting;
  bool get isRejecting => _isRejecting;
  List<HistoryEntry> get historyList => List.unmodifiable(_historyList);

  List<EmergencyModel> get myAgencyEmergencies =>
      _emergencies.where((e) => e.assignedAgency == _responder.agency).toList();

  List<EmergencyModel> get activeEmergencies => myAgencyEmergencies
      .where((e) => e.status != EmergencyStatus.resolved)
      .toList();

  List<EmergencyModel> get resolvedEmergencies => myAgencyEmergencies
      .where((e) => e.status == EmergencyStatus.resolved)
      .toList();

  int get activeCount => activeEmergencies.length;
  int get completedTodayCount => MockData.completedToday;
  String get avgResponseTime => MockData.avgResponseTime;

  // ─── ASSIGNMENT FLOW ─────────────────────────────────────────────────────────

  void triggerIncomingEmergency() {
    if (_isDialogVisible) return;

    final dispatched = myAgencyEmergencies
        .where((e) => e.status == EmergencyStatus.dispatched)
        .toList();

    if (dispatched.isEmpty) return;

    _incomingEmergency = dispatched.first;
    _isDialogVisible = true;
    _timerSeconds = 60;
    _isAccepting = false;
    _isRejecting = false;
    notifyListeners();

    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds <= 1) {
        timer.cancel();
        _onTimeout();
      } else {
        _timerSeconds--;
        notifyListeners();
      }
    });
  }

  void _onTimeout() {
    if (_incomingEmergency == null) return;
    _addToHistory(_incomingEmergency!, HistoryStatus.missed);
    _dismissDialog();
  }

  void acceptAssignment(BuildContext context) {
    if (_incomingEmergency == null || _isAccepting) return;
    _isAccepting = true;
    notifyListeners();

    _countdownTimer?.cancel();

    final emergency = _incomingEmergency!;
    _updateStatus(emergency.id, EmergencyStatus.onTheWay);
    _setResponderStatus(ResponderStatus.busy);
    _selectedEmergency = _getById(emergency.id);

    _dismissDialog();

    Future.microtask(() {
      Navigator.of(context).pushNamed('/emergency-detail', arguments: _selectedEmergency);
    });
  }

  void rejectAssignment() {
    if (_incomingEmergency == null || _isRejecting) return;
    _isRejecting = true;
    notifyListeners();

    _countdownTimer?.cancel();
    _addToHistory(_incomingEmergency!, HistoryStatus.rejected);
    _dismissDialog();
  }

  void _dismissDialog() {
    _incomingEmergency = null;
    _isDialogVisible = false;
    _isAccepting = false;
    _isRejecting = false;
    notifyListeners();
  }

  // ─── HISTORY ─────────────────────────────────────────────────────────────────
  void _addToHistory(EmergencyModel emergency, HistoryStatus status) {
    _historyList.insert(0, HistoryEntry(
      emergency: emergency,
      historyStatus: status,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void moveToHistory(EmergencyModel emergency, HistoryStatus status) {
    _addToHistory(emergency, status);
  }

  // ─── SELECT ──────────────────────────────────────────────────────────────────
  void selectEmergency(EmergencyModel emergency) {
    _selectedEmergency = emergency;
    notifyListeners();
  }

  void clearSelectedEmergency() {
    _selectedEmergency = null;
    notifyListeners();
  }

  // ─── STATUS UPDATES ──────────────────────────────────────────────────────────
  void acceptEmergency(String id) {
    _updateStatus(id, EmergencyStatus.onTheWay);
    _setResponderStatus(ResponderStatus.busy);
  }

  void markOnTheWay(String id) => _updateStatus(id, EmergencyStatus.onTheWay);
  void markArrived(String id) => _updateStatus(id, EmergencyStatus.arrived);

  void markResolved(String id) {
    final emergency = _getById(id);
    _updateStatus(id, EmergencyStatus.resolved);
    if (emergency != null) _addToHistory(emergency, HistoryStatus.completed);
    final stillActive = activeEmergencies.where((e) => e.id != id).isNotEmpty;
    if (!stillActive) _setResponderStatus(ResponderStatus.available);
  }

  void advanceStatus(String id) {
    final emergency = _getById(id);
    if (emergency == null) return;
    switch (emergency.status) {
      case EmergencyStatus.dispatched: acceptEmergency(id); break;
      case EmergencyStatus.onTheWay: markArrived(id); break;
      case EmergencyStatus.arrived: markResolved(id); break;
      case EmergencyStatus.resolved: break;
    }
  }

  void setResponderStatus(ResponderStatus status) => _setResponderStatus(status);

  // ─── PRIVATE ─────────────────────────────────────────────────────────────────
  void _updateStatus(String id, EmergencyStatus newStatus) {
    final index = _emergencies.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _emergencies[index].status = newStatus;
    if (_selectedEmergency?.id == id) _selectedEmergency = _emergencies[index];
    notifyListeners();
  }

  void _setResponderStatus(ResponderStatus status) {
    _responder.status = status;
    notifyListeners();
  }

  EmergencyModel? _getById(String id) {
    try { return _emergencies.firstWhere((e) => e.id == id); }
    catch (_) { return null; }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
