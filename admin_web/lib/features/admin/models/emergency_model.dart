import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain models for emergency reports and chat messages.
/// Connected to the Firestore `emergency_report` collection written by user_app.

// ── Enums ─────────────────────────────────────────────────────────────────────

/// All emergency types that can arrive from the user_app plus `police` kept
/// for backwards compatibility with any admin-created entries.
enum EmergencyType {
  fire,
  medical,
  police,
  flood,
  roadAccident,
  naturalDisaster,
  crime,
  other,
}

enum EmergencyStatus { active, pending, resolved }

enum EmergencyPriority { critical, high, medium, low }

// ── Extensions ────────────────────────────────────────────────────────────────

extension EmergencyTypeX on EmergencyType {
  String get label => switch (this) {
        EmergencyType.fire => 'FIRE',
        EmergencyType.medical => 'MEDICAL',
        EmergencyType.police => 'POLICE',
        EmergencyType.flood => 'FLOOD',
        EmergencyType.roadAccident => 'ROAD ACCIDENT',
        EmergencyType.naturalDisaster => 'NATURAL DISASTER',
        EmergencyType.crime => 'CRIME',
        EmergencyType.other => 'OTHER',
      };
}

extension EmergencyStatusX on EmergencyStatus {
  String get label => switch (this) {
        EmergencyStatus.active => 'Active',
        EmergencyStatus.pending => 'Pending',
        EmergencyStatus.resolved => 'Resolved',
      };

  /// Maps the admin's status back to the user-app's Firestore status strings.
  String toFirestoreString() => switch (this) {
        EmergencyStatus.active => 'inProgress',
        EmergencyStatus.pending => 'pending',
        EmergencyStatus.resolved => 'resolved',
      };
}

extension EmergencyPriorityX on EmergencyPriority {
  String get label => switch (this) {
        EmergencyPriority.critical => 'critical',
        EmergencyPriority.high => 'high',
        EmergencyPriority.medium => 'medium',
        EmergencyPriority.low => 'low',
      };
}

// ── Models ────────────────────────────────────────────────────────────────────

/// A responder assigned to an emergency (BFP, RHU, PNP, MDRRMO, etc.).
class Responder {
  const Responder({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
  });

  final String id;
  final String name;
  final String role;   // e.g. 'Firefighter', 'Paramedic', 'Officer'
  final String status; // e.g. 'En route', 'On scene', 'Available'

  factory Responder.fromMap(Map<String, dynamic> map) => Responder(
        id: map['id'] as String,
        name: map['name'] as String,
        role: map['role'] as String,
        status: map['status'] as String,
      );

  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'role': role, 'status': status};
}

/// A single entry in the incident timeline.
class TimelineEvent {
  const TimelineEvent({required this.time, required this.description});

  final DateTime time;
  final String description;

  factory TimelineEvent.fromMap(Map<String, dynamic> map) => TimelineEvent(
        time: DateTime.parse(map['time'] as String),
        description: map['description'] as String,
      );

  Map<String, dynamic> toMap() =>
      {'time': time.toIso8601String(), 'description': description};
}

class EmergencyReport {
  const EmergencyReport({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    required this.address,
    required this.district,
    required this.assignedUnits,
    required this.reportedAt,
    required this.reporterId,
    required this.reporterName,
    this.description,
    this.injuryNote,
    this.deviceName,
    this.latitude,
    this.longitude,
    this.responders = const [],
    this.timeline = const [],
  });

  final String id;
  final EmergencyType type;
  final EmergencyStatus status;
  final EmergencyPriority priority;
  final String address;
  final String district;
  final List<String> assignedUnits;
  final DateTime reportedAt;
  final String reporterId;
  final String reporterName;
  final String? description;
  /// Injury description submitted by the user, if any.
  final String? injuryNote;
  /// Human-readable device name of the reporter's phone.
  final String? deviceName;
  final double? latitude;
  final double? longitude;
  final List<Responder> responders;
  final List<TimelineEvent> timeline;

  // ── Firestore deserialization ──────────────────────────────────────────────

  /// Creates an [EmergencyReport] from a Firestore document snapshot.
  ///
  /// Handles mapping from the user_app's field names / enum strings to the
  /// admin's domain model. Fields that the user_app does not write (e.g.
  /// `address`, `priority`) are derived automatically.
  factory EmergencyReport.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();
    final type = _typeFromString(data['emergencyType'] as String? ?? 'other');

    return EmergencyReport(
      id: doc.id,
      type: type,
      status: _statusFromString(data['status'] as String? ?? 'pending'),
      priority: _derivePriority(type),
      address: _formatAddress(lat, lng),
      district: 'Los Baños',
      assignedUnits:
          List<String>.from(data['assignedUnits'] as List? ?? const []),
      reportedAt:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reporterId: data['deviceId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? 'Anonymous',
      description: data['description'] as String?,
      injuryNote: data['injuryNote'] as String?,
      deviceName: data['deviceName'] as String?,
      latitude: lat,
      longitude: lng,
      // Responders are admin-managed — not stored in user-app docs yet.
      responders: const [],
      timeline: [
        TimelineEvent(
          time: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          description: 'Emergency reported',
        ),
      ],
    );
  }

  /// Legacy constructor from a plain [Map] (kept for any existing tests/code).
  factory EmergencyReport.fromMap(Map<String, dynamic> map) {
    return EmergencyReport(
      id: map['id'] as String,
      type: EmergencyType.values.byName(map['type'] as String),
      status: EmergencyStatus.values.byName(map['status'] as String),
      priority: EmergencyPriority.values.byName(map['priority'] as String),
      address: map['address'] as String,
      district: map['district'] as String,
      assignedUnits: List<String>.from(map['assignedUnits'] as List),
      reportedAt: DateTime.parse(map['reportedAt'] as String),
      reporterId: map['reporterId'] as String,
      reporterName: map['reporterName'] as String,
      description: map['description'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      responders: (map['responders'] as List? ?? [])
          .map((e) => Responder.fromMap(e as Map<String, dynamic>))
          .toList(),
      timeline: (map['timeline'] as List? ?? [])
          .map((e) => TimelineEvent.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'status': status.name,
        'priority': priority.name,
        'address': address,
        'district': district,
        'assignedUnits': assignedUnits,
        'reportedAt': reportedAt.toIso8601String(),
        'reporterId': reporterId,
        'reporterName': reporterName,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'responders': responders.map((r) => r.toMap()).toList(),
        'timeline': timeline.map((t) => t.toMap()).toList(),
      };

  EmergencyReport copyWith({
    EmergencyStatus? status,
    List<String>? assignedUnits,
    List<Responder>? responders,
    List<TimelineEvent>? timeline,
  }) =>
      EmergencyReport(
        id: id,
        type: type,
        status: status ?? this.status,
        priority: priority,
        address: address,
        district: district,
        assignedUnits: assignedUnits ?? this.assignedUnits,
        reportedAt: reportedAt,
        reporterId: reporterId,
        reporterName: reporterName,
        description: description,
        injuryNote: injuryNote,
        deviceName: deviceName,
        latitude: latitude,
        longitude: longitude,
        responders: responders ?? this.responders,
        timeline: timeline ?? this.timeline,
      );

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Maps user_app's `emergencyType` string to the admin's [EmergencyType].
  static EmergencyType _typeFromString(String value) => switch (value) {
        'fire' => EmergencyType.fire,
        'medical' => EmergencyType.medical,
        'police' => EmergencyType.police,
        'flood' => EmergencyType.flood,
        'roadAccident' => EmergencyType.roadAccident,
        'naturalDisaster' => EmergencyType.naturalDisaster,
        'crime' => EmergencyType.crime,
        _ => EmergencyType.other,
      };

  /// Maps user_app's `status` strings to the admin's [EmergencyStatus].
  ///
  /// | user_app value        | admin status |
  /// |-----------------------|--------------|
  /// | pending               | pending      |
  /// | acknowledged          | active       |
  /// | inProgress            | active       |
  /// | resolved / cancelled  | resolved     |
  static EmergencyStatus _statusFromString(String value) => switch (value) {
        'acknowledged' || 'inProgress' => EmergencyStatus.active,
        'resolved' || 'cancelled' => EmergencyStatus.resolved,
        _ => EmergencyStatus.pending,
      };

  /// Derives a [EmergencyPriority] from an [EmergencyType] since the user_app
  /// does not currently send a priority field.
  static EmergencyPriority _derivePriority(EmergencyType type) =>
      switch (type) {
        EmergencyType.fire => EmergencyPriority.critical,
        EmergencyType.medical ||
        EmergencyType.crime ||
        EmergencyType.flood ||
        EmergencyType.roadAccident ||
        EmergencyType.naturalDisaster =>
          EmergencyPriority.high,
        EmergencyType.police || EmergencyType.other => EmergencyPriority.medium,
      };

  /// Formats lat/lng into a human-readable coordinate string used as the
  /// report address until reverse geocoding is integrated.
  static String _formatAddress(double? lat, double? lng) {
    if (lat == null || lng == null) return 'Unknown Location';
    return '${lat.toStringAsFixed(5)}°N, ${lng.toStringAsFixed(5)}°E';
  }
}

// ── Chat Message ──────────────────────────────────────────────────────────────

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.emergencyId,
    required this.senderId,
    required this.senderName,
    required this.isAdmin,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String emergencyId;
  final String senderId;
  final String senderName;

  /// [true] = sent by admin (shown on the right in blue).
  /// [false] = sent by reporter / responder (shown on the left).
  final bool isAdmin;
  final String text;
  final DateTime sentAt;

  /// TODO: Replace with `ChatMessage.fromFirestore(doc)` when connecting Firebase.
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      emergencyId: map['emergencyId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      isAdmin: map['isAdmin'] as bool,
      text: map['text'] as String,
      sentAt: DateTime.parse(map['sentAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'emergencyId': emergencyId,
        'senderId': senderId,
        'senderName': senderName,
        'isAdmin': isAdmin,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
      };
}
