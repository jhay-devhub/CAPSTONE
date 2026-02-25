import 'package:flutter/material.dart';

/// Represents a single safety tip shown in the Safety Tips screen.
/// Each tip can have expandable steps for detailed instructions.
@immutable
class SafetyTipModel {
  const SafetyTipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.steps = const [],
  });

  final int id;
  final String title;
  final String description;
  final IconData icon;
  final SafetyTipCategory category;

  /// Step-by-step instructions shown when the card is expanded.
  final List<String> steps;

  @override
  String toString() => 'SafetyTipModel(id: $id, title: $title)';
}

enum SafetyTipCategory {
  fire,
  flood,
  medical,
  earthquake,
  general,
}

extension SafetyTipCategoryLabel on SafetyTipCategory {
  String get label {
    switch (this) {
      case SafetyTipCategory.fire:
        return 'Fire';
      case SafetyTipCategory.flood:
        return 'Flood';
      case SafetyTipCategory.medical:
        return 'Medical';
      case SafetyTipCategory.earthquake:
        return 'Earthquake';
      case SafetyTipCategory.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case SafetyTipCategory.fire:
        return Icons.local_fire_department;
      case SafetyTipCategory.flood:
        return Icons.water;
      case SafetyTipCategory.medical:
        return Icons.medical_services;
      case SafetyTipCategory.earthquake:
        return Icons.landslide;
      case SafetyTipCategory.general:
        return Icons.shield;
    }
  }

  Color get color {
    switch (this) {
      case SafetyTipCategory.fire:
        return const Color(0xFFD32F2F);
      case SafetyTipCategory.flood:
        return const Color(0xFF1565C0);
      case SafetyTipCategory.medical:
        return const Color(0xFF2E7D32);
      case SafetyTipCategory.earthquake:
        return const Color(0xFFE65100);
      case SafetyTipCategory.general:
        return const Color(0xFF455A64);
    }
  }
}
