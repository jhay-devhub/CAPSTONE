// features/widgets/emergency_card.dart
// LB-Sentry | Emergency Card Widget

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_theme.dart';
import '../models/emergency_model.dart';
import 'status_badge.dart';

class EmergencyCard extends StatelessWidget {
  final EmergencyModel emergency;
  final VoidCallback? onTap;

  const EmergencyCard({super.key, required this.emergency, this.onTap});

  Color get _typeColor {
    switch (emergency.emergencyType) {
      case EmergencyType.fire:
        return AppColors.primary;
      case EmergencyType.medical:
        return Colors.blue;
      case EmergencyType.crime:
        return Colors.purple;
      case EmergencyType.accident:
        return Colors.orange;
    }
  }

  IconData get _typeIcon {
    switch (emergency.emergencyType) {
      case EmergencyType.fire:
        return Icons.local_fire_department;
      case EmergencyType.medical:
        return Icons.medical_services;
      case EmergencyType.crime:
        return Icons.security;
      case EmergencyType.accident:
        return Icons.car_crash;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_typeIcon, color: _typeColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              emergency.emergencyType.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _typeColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${emergency.id}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          emergency.address,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: emergency.status, compact: true),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 10),

              // ── Description ──
              Text(
                emergency.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 10),

              // ── Footer row ──
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.access_time,
                    label: DateFormat('hh:mm a').format(emergency.time),
                  ),
                  const SizedBox(width: 8),
                  _MetaChip(
                    icon: Icons.near_me,
                    label: emergency.distance,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _typeColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      emergency.assignedAgency,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _typeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
