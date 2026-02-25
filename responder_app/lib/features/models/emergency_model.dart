// features/models/emergency_model.dart
// LB-Sentry | Emergency Data Model
// Future-ready: Fields map 1:1 to Firebase document structure

import 'package:flutter/material.dart';

enum EmergencyStatus {
  dispatched,
  onTheWay,
  arrived,
  resolved,
}

enum HistoryStatus {
  rejected,
  missed,
  completed,
}

extension HistoryStatusExt on HistoryStatus {
  String get label {
    switch (this) {
      case HistoryStatus.rejected:
        return 'Rejected';
      case HistoryStatus.missed:
        return 'Missed';
      case HistoryStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case HistoryStatus.rejected:
        return const Color(0xFFD32F2F);
      case HistoryStatus.missed:
        return const Color(0xFFE65100);
      case HistoryStatus.completed:
        return const Color(0xFF2E7D32);
    }
  }

  IconData get icon {
    switch (this) {
      case HistoryStatus.rejected:
        return Icons.cancel;
      case HistoryStatus.missed:
        return Icons.timer_off;
      case HistoryStatus.completed:
        return Icons.check_circle;
    }
  }
}

class HistoryEntry {
  final EmergencyModel emergency;
  final HistoryStatus historyStatus;
  final DateTime timestamp;

  HistoryEntry({
    required this.emergency,
    required this.historyStatus,
    required this.timestamp,
  });
}

enum EmergencyType {
  fire,
  medical,
  crime,
  accident,
}

extension EmergencyStatusExt on EmergencyStatus {
  String get label {
    switch (this) {
      case EmergencyStatus.dispatched:
        return 'Dispatched';
      case EmergencyStatus.onTheWay:
        return 'On The Way';
      case EmergencyStatus.arrived:
        return 'Arrived';
      case EmergencyStatus.resolved:
        return 'Resolved';
    }
  }

  EmergencyStatus? get next {
    switch (this) {
      case EmergencyStatus.dispatched:
        return EmergencyStatus.onTheWay;
      case EmergencyStatus.onTheWay:
        return EmergencyStatus.arrived;
      case EmergencyStatus.arrived:
        return EmergencyStatus.resolved;
      case EmergencyStatus.resolved:
        return null;
    }
  }
}

extension EmergencyTypeExt on EmergencyType {
  String get label {
    switch (this) {
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.crime:
        return 'Crime';
      case EmergencyType.accident:
        return 'Accident';
    }
  }
}

class EmergencyModel {
  final String id;
  final EmergencyType emergencyType;
  final String description;
  final double latitude;
  final double longitude;
  EmergencyStatus status;
  final DateTime time;
  final String distance;
  final String assignedAgency;
  final String reporterName;
  final String address;

  EmergencyModel({
    required this.id,
    required this.emergencyType,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.time,
    required this.distance,
    required this.assignedAgency,
    required this.reporterName,
    required this.address,
  });

  // Future Firebase integration: fromMap / toMap
  factory EmergencyModel.fromMap(Map<String, dynamic> map) {
    return EmergencyModel(
      id: map['id'] ?? '',
      emergencyType: EmergencyType.values.firstWhere(
        (e) => e.name == map['emergencyType'],
        orElse: () => EmergencyType.fire,
      ),
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: EmergencyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EmergencyStatus.dispatched,
      ),
      time: DateTime.parse(map['time'] ?? DateTime.now().toIso8601String()),
      distance: map['distance'] ?? '0 km',
      assignedAgency: map['assignedAgency'] ?? '',
      reporterName: map['reporterName'] ?? 'Unknown',
      address: map['address'] ?? 'Unknown Location',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emergencyType': emergencyType.name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'time': time.toIso8601String(),
      'distance': distance,
      'assignedAgency': assignedAgency,
      'reporterName': reporterName,
      'address': address,
    };
  }

  EmergencyModel copyWith({EmergencyStatus? status}) {
    return EmergencyModel(
      id: id,
      emergencyType: emergencyType,
      description: description,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      time: time,
      distance: distance,
      assignedAgency: assignedAgency,
      reporterName: reporterName,
      address: address,
    );
  }
}
