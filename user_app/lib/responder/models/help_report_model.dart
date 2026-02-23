import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Emergency type ────────────────────────────────────────────────────────────

/// The category of emergency the user is reporting.
/// This determines which response vehicle will be dispatched.
enum EmergencyType {
  fire,
  roadAccident,
  medical,
  flood,
  naturalDisaster,
  crime,
  other;

  /// Human-readable label shown in the UI.
  String get label {
    switch (this) {
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.roadAccident:
        return 'Road Accident';
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.flood:
        return 'Flood';
      case EmergencyType.naturalDisaster:
        return 'Natural Disaster';
      case EmergencyType.crime:
        return 'Crime';
      case EmergencyType.other:
        return 'Other';
    }
  }

  /// Icon representing this emergency category.
  IconData get icon {
    switch (this) {
      case EmergencyType.fire:
        return Icons.local_fire_department;
      case EmergencyType.roadAccident:
        return Icons.car_crash;
      case EmergencyType.medical:
        return Icons.medical_services;
      case EmergencyType.flood:
        return Icons.water;
      case EmergencyType.naturalDisaster:
        return Icons.landslide;
      case EmergencyType.crime:
        return Icons.security;
      case EmergencyType.other:
        return Icons.help_outline;
    }
  }

  /// Message shown to the user describing which vehicle will be dispatched.
  String get vehicleDispatchNote {
    switch (this) {
      case EmergencyType.fire:
        return 'A fire truck will be dispatched to your location.';
      case EmergencyType.roadAccident:
        return 'A rescue vehicle and ambulance will be dispatched.';
      case EmergencyType.medical:
        return 'An ambulance will be dispatched to your location.';
      case EmergencyType.flood:
        return 'A rescue boat and response team will be dispatched.';
      case EmergencyType.naturalDisaster:
        return 'An emergency response team will be dispatched.';
      case EmergencyType.crime:
        return 'A police unit will be dispatched to your location.';
      case EmergencyType.other:
        return 'The nearest available response team will be dispatched.';
    }
  }
}

// ── Report status ─────────────────────────────────────────────────────────────

/// Lifecycle states for a single help report.
enum HelpReportStatus {
  pending,
  acknowledged,
  inProgress,
  resolved,
  cancelled;

  String get label {
    switch (this) {
      case HelpReportStatus.pending:
        return 'Pending';
      case HelpReportStatus.acknowledged:
        return 'Acknowledged';
      case HelpReportStatus.inProgress:
        return 'In Progress';
      case HelpReportStatus.resolved:
        return 'Resolved';
      case HelpReportStatus.cancelled:
        return 'Cancelled';
    }
  }
}

// ── Model ─────────────────────────────────────────────────────────────────────

/// Immutable data model for a single help request sent by the user.
@immutable
class HelpReportModel {
  const HelpReportModel({
    required this.id,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.emergencyType,
    this.description,
    this.injuryNote,
    this.photoPath,
    this.status = HelpReportStatus.pending,
  });

  final String id;

  /// Unique hardware device identifier – the primary key that links
  /// a report to the physical device that sent it.
  final String deviceId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  /// Required: determines which response vehicle is dispatched.
  final EmergencyType emergencyType;

  /// Optional: brief description of what happened.
  final String? description;

  /// Optional: description of any injuries present.
  final String? injuryNote;

  /// Optional: local file path of an attached photo.
  final String? photoPath;

  final HelpReportStatus status;

  HelpReportModel copyWith({
    String? id,
    String? deviceId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    EmergencyType? emergencyType,
    String? description,
    String? injuryNote,
    String? photoPath,
    HelpReportStatus? status,
  }) {
    return HelpReportModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      emergencyType: emergencyType ?? this.emergencyType,
      description: description ?? this.description,
      injuryNote: injuryNote ?? this.injuryNote,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        'emergencyType': emergencyType.name,
        'description': description,
        'injuryNote': injuryNote,
        'photoPath': photoPath,
        'status': status.name,
      };

  /// Converts this model to a Firestore-compatible map.
  /// Uses [Timestamp] instead of ISO string for proper Firestore ordering.
  Map<String, dynamic> toFirestore() => {
        'deviceId': deviceId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': Timestamp.fromDate(timestamp),
        'emergencyType': emergencyType.name,
        'description': description,
        'injuryNote': injuryNote,
        'photoPath': photoPath,
        'status': status.name,
      };

  /// Creates a [HelpReportModel] from a Firestore document.
  factory HelpReportModel.fromFirestore(
    String id,
    Map<String, dynamic> json,
  ) {
    return HelpReportModel(
      id: id,
      deviceId: json['deviceId'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
              DateTime.now(),
      emergencyType: EmergencyType.values.byName(
        json['emergencyType'] as String? ?? 'other',
      ),
      description: json['description'] as String?,
      injuryNote: json['injuryNote'] as String?,
      photoPath: json['photoPath'] as String?,
      status: HelpReportStatus.values.byName(
        json['status'] as String? ?? 'pending',
      ),
    );
  }

  @override
  String toString() =>
      'HelpReportModel(id: $id, device: $deviceId, type: ${emergencyType.label}, '
      'status: ${status.label}, lat: $latitude, lng: $longitude)';
}
