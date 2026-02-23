/// Domain models for emergency reports and chat messages.
/// Designed to be wired to Firestore / the user app later —
/// just swap the factory constructors and the [EmergencyController]
/// data sources without touching the UI widgets.

// ── Enums ─────────────────────────────────────────────────────────────────────

enum EmergencyType { fire, medical, police, flood, other }

enum EmergencyStatus { active, pending, resolved }

enum EmergencyPriority { critical, high, medium, low }

// ── Extensions ────────────────────────────────────────────────────────────────

extension EmergencyTypeX on EmergencyType {
  String get label => switch (this) {
        EmergencyType.fire => 'FIRE',
        EmergencyType.medical => 'MEDICAL',
        EmergencyType.police => 'POLICE',
        EmergencyType.flood => 'FLOOD',
        EmergencyType.other => 'OTHER',
      };
}

extension EmergencyStatusX on EmergencyStatus {
  String get label => switch (this) {
        EmergencyStatus.active => 'Active',
        EmergencyStatus.pending => 'Pending',
        EmergencyStatus.resolved => 'Resolved',
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
  final double? latitude;
  final double? longitude;
  final List<Responder> responders;
  final List<TimelineEvent> timeline;

  /// TODO: Replace with `EmergencyReport.fromFirestore(doc)` when connecting Firebase.
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
        assignedUnits: assignedUnits,
        reportedAt: reportedAt,
        reporterId: reporterId,
        reporterName: reporterName,
        description: description,
        latitude: latitude,
        longitude: longitude,
        responders: responders ?? this.responders,
        timeline: timeline ?? this.timeline,
      );
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
