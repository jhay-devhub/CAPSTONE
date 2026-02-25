// features/widgets/history_card.dart
// LB-Sentry | History Item Card

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_theme.dart';
import '../models/emergency_model.dart';

class HistoryCard extends StatelessWidget {
  final HistoryEntry entry;

  const HistoryCard({super.key, required this.entry});

  IconData get _typeIcon {
    switch (entry.emergency.emergencyType) {
      case EmergencyType.fire: return Icons.local_fire_department;
      case EmergencyType.medical: return Icons.medical_services;
      case EmergencyType.crime: return Icons.security;
      case EmergencyType.accident: return Icons.car_crash;
    }
  }

  Color get _typeColor {
    switch (entry.emergency.emergencyType) {
      case EmergencyType.fire: return AppColors.primary;
      case EmergencyType.medical: return Colors.blue.shade700;
      case EmergencyType.crime: return Colors.purple.shade700;
      case EmergencyType.accident: return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hs = entry.historyStatus;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: hs.color.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.emergency.emergencyType.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _typeColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${entry.emergency.id}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.emergency.description,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd – hh:mm a').format(entry.timestamp),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hs.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: hs.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(hs.icon, size: 11, color: hs.color),
                      const SizedBox(width: 4),
                      Text(
                        hs.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: hs.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
