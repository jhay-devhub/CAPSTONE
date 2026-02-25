// features/widgets/status_badge.dart
// LB-Sentry | Status Badge Widget

import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';
import '../models/emergency_model.dart';

class StatusBadge extends StatelessWidget {
  final EmergencyStatus status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  Color get _color {
    switch (status) {
      case EmergencyStatus.dispatched:
        return AppColors.dispatched;
      case EmergencyStatus.onTheWay:
        return AppColors.onTheWay;
      case EmergencyStatus.arrived:
        return AppColors.arrived;
      case EmergencyStatus.resolved:
        return AppColors.resolved;
    }
  }

  IconData get _icon {
    switch (status) {
      case EmergencyStatus.dispatched:
        return Icons.radio_button_checked;
      case EmergencyStatus.onTheWay:
        return Icons.directions_car;
      case EmergencyStatus.arrived:
        return Icons.location_on;
      case EmergencyStatus.resolved:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 10 : 12, color: _color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.bold,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
