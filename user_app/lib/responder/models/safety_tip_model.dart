import 'package:flutter/material.dart';

/// Represents a single safety tip shown in the Safety Tips screen.
@immutable
class SafetyTipModel {
  const SafetyTipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });

  final int id;
  final String title;
  final String description;
  final IconData icon;
  final SafetyTipCategory category;

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
}
