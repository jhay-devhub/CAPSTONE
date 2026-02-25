// features/models/responder_model.dart
// LB-Sentry | Responder Data Model

enum ResponderStatus { available, busy, offline }

extension ResponderStatusExt on ResponderStatus {
  String get label {
    switch (this) {
      case ResponderStatus.available:
        return 'Available';
      case ResponderStatus.busy:
        return 'Busy';
      case ResponderStatus.offline:
        return 'Offline';
    }
  }
}

class ResponderModel {
  final String id;
  final String name;
  final String agency;
  final String rank;
  final String badgeNumber;
  final String unit;
  ResponderStatus status;
  final double latitude;
  final double longitude;

  ResponderModel({
    required this.id,
    required this.name,
    required this.agency,
    required this.rank,
    required this.badgeNumber,
    required this.unit,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  // Future Firebase: fromMap / toMap
  factory ResponderModel.fromMap(Map<String, dynamic> map) {
    return ResponderModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      agency: map['agency'] ?? '',
      rank: map['rank'] ?? '',
      badgeNumber: map['badgeNumber'] ?? '',
      unit: map['unit'] ?? '',
      status: ResponderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ResponderStatus.available,
      ),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'agency': agency,
      'rank': rank,
      'badgeNumber': badgeNumber,
      'unit': unit,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ResponderModel copyWith({ResponderStatus? status}) {
    return ResponderModel(
      id: id,
      name: name,
      agency: agency,
      rank: rank,
      badgeNumber: badgeNumber,
      unit: unit,
      status: status ?? this.status,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
