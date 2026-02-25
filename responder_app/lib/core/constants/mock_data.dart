// core/constants/mock_data.dart
// LB-Sentry | Mock Data for Prototype
// Replace with Firebase calls in production

import '../../features/models/emergency_model.dart';
import '../../features/models/responder_model.dart';

class MockData {
  // ─── RESPONDER INFO ─────────────────────────────────────────────────────────
  static final ResponderModel currentResponder = ResponderModel(
    id: 'R-001',
    name: 'Juan Dela Cruz',
    agency: 'BFP',
    rank: 'Fire Officer I',
    badgeNumber: 'BFP-2024-0187',
    unit: 'Station 3 - Los Baños',
    status: ResponderStatus.available,
    latitude: 14.1693,
    longitude: 121.2406,
  );

  // ─── EMERGENCY REPORTS ──────────────────────────────────────────────────────
  static List<EmergencyModel> emergencies = [
    EmergencyModel(
      id: 'EM-001',
      emergencyType: EmergencyType.fire,
      description:
          'Structure fire reported at a 2-storey residential house. Flames visible from second floor. Occupants may still be inside.',
      latitude: 14.1710,
      longitude: 121.2430,
      status: EmergencyStatus.dispatched,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      distance: '1.2 km',
      assignedAgency: 'BFP',
      reporterName: 'Maria Santos',
      address: 'Purok 3, Brgy. Batong Malake, Los Baños',
    ),
    EmergencyModel(
      id: 'EM-002',
      emergencyType: EmergencyType.fire,
      description:
          'Grass fire spreading near residential area. Strong winds reported. Risk of spreading to nearby homes.',
      latitude: 14.1650,
      longitude: 121.2380,
      status: EmergencyStatus.onTheWay,
      time: DateTime.now().subtract(const Duration(minutes: 18)),
      distance: '2.5 km',
      assignedAgency: 'BFP',
      reporterName: 'Roberto Cruz',
      address: 'Sitio Bulihan, Brgy. Bayog, Los Baños',
    ),
    EmergencyModel(
      id: 'EM-003',
      emergencyType: EmergencyType.medical,
      description:
          'Elderly male, 72 years old, experiencing chest pains and difficulty breathing. Conscious but in distress.',
      latitude: 14.1720,
      longitude: 121.2450,
      status: EmergencyStatus.arrived,
      time: DateTime.now().subtract(const Duration(minutes: 32)),
      distance: '0.8 km',
      assignedAgency: 'BFP',
      reporterName: 'Lina Reyes',
      address: 'Blk 5 Lot 12, Purok 7, Brgy. Putho-Tuntungin, Los Baños',
    ),
    EmergencyModel(
      id: 'EM-004',
      emergencyType: EmergencyType.accident,
      description:
          'Vehicular accident involving motorcycle and jeepney. Two injured. Road partially blocked.',
      latitude: 14.1680,
      longitude: 121.2410,
      status: EmergencyStatus.resolved,
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      distance: '3.1 km',
      assignedAgency: 'BFP',
      reporterName: 'Fernando Bautista',
      address: 'National Highway near UPLB Gate 1, Los Baños',
    ),
    EmergencyModel(
      id: 'EM-005',
      emergencyType: EmergencyType.crime,
      description:
          'Reported armed robbery in progress at local convenience store. Suspect still on premises.',
      latitude: 14.1705,
      longitude: 121.2398,
      status: EmergencyStatus.dispatched,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      distance: '0.5 km',
      assignedAgency: 'PNP',
      reporterName: 'Anonymous',
      address: 'P. Guevara St., Brgy. Mayondon, Los Baños',
    ),
    EmergencyModel(
      id: 'EM-006',
      emergencyType: EmergencyType.fire,
      description:
          'Kitchen fire at carinderia. Fire extinguished by bystanders but structural damage needs assessment.',
      latitude: 14.1698,
      longitude: 121.2422,
      status: EmergencyStatus.resolved,
      time: DateTime.now().subtract(const Duration(hours: 3)),
      distance: '1.8 km',
      assignedAgency: 'BFP',
      reporterName: 'Gloria Mendoza',
      address: 'Crossing Bayog, Brgy. Bagong Silang, Los Baños',
    ),
  ];

  // ─── DASHBOARD STATS (MOCK) ─────────────────────────────────────────────────
  static const int completedToday = 4;
  static const String avgResponseTime = '8 min';
  static const int totalResponders = 12;
}
