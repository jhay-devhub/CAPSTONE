import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/emergency_controller.dart';
import '../models/emergency_model.dart';
import 'emergency_dialogs.dart';

/// The Details tab content — shows full incident information,
/// assigned responders, timeline, and action buttons.
class EmergencyDetailsView extends StatelessWidget {
  const EmergencyDetailsView({super.key, required this.controller});
  final EmergencyController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final report = controller.selectedReport.value;
      if (report == null) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 32, color: AppColors.textHint),
              SizedBox(height: 10),
              Text('Select an incident from the list',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Incident header ───────────────────────────────────
                  Row(
                    children: [
                      Icon(_typeIcon(report.type), size: 28, color: _typeColor(report.type)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.type.label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            report.id,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Badges
                  Wrap(
                    spacing: 6,
                    children: [
                      StatusBadge(status: report.status),
                      PriorityBadge(priority: report.priority),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.divider),

                  // ── Address ───────────────────────────────────────────
                  _DetailSection(label: 'ADDRESS', value: report.address),
                  const SizedBox(height: 12),

                  // ── Lat / Lng ─────────────────────────────────────────
                  if (report.latitude != null && report.longitude != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _DetailSection(
                            label: 'LATITUDE',
                            value: report.latitude!.toStringAsFixed(4),
                          ),
                        ),
                        Expanded(
                          child: _DetailSection(
                            label: 'LONGITUDE',
                            value: report.longitude!.toStringAsFixed(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Description ───────────────────────────────────────
                  if (report.description != null) ...[
                    _DetailSection(label: 'DESCRIPTION', value: report.description!),
                    const SizedBox(height: 12),
                  ],

                  // ── Assigned Responders ───────────────────────────────
                  const Text(
                    'ASSIGNED RESPONDERS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (report.responders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('No responders assigned yet.',
                          style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                    )
                  else
                    ...report.responders.map((r) => _ResponderTile(responder: r)),
                  const SizedBox(height: 12),

                  // ── Timeline ──────────────────────────────────────────
                  if (report.timeline.isNotEmpty) ...[
                    const Text(
                      'TIMELINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...report.timeline.map((e) => _TimelineTile(event: e)),
                  ],
                ],
              ),
            ),
          ),

          // ── Action buttons ────────────────────────────────────────────
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => showUpdateStatusDialog(context, report, controller),
                    child: const Text('Update Status',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.inputBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => showAssignResponderDialog(context, report, controller),
                    child: const Text('Assign Responder',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textPrimary)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  IconData _typeIcon(EmergencyType t) => switch (t) {
        EmergencyType.fire => Icons.local_fire_department_rounded,
        EmergencyType.medical => Icons.medical_services_rounded,
        EmergencyType.police => Icons.local_police_rounded,
        EmergencyType.flood => Icons.water_rounded,
        EmergencyType.other => Icons.warning_rounded,
      };

  Color _typeColor(EmergencyType t) => switch (t) {
        EmergencyType.fire => const Color(0xFFEF4444),
        EmergencyType.medical => const Color(0xFF3B82F6),
        EmergencyType.police => const Color(0xFF8B5CF6),
        EmergencyType.flood => const Color(0xFF0EA5E9),
        EmergencyType.other => AppColors.warning,
      };
}

// ── Helper widgets (private to this file) ─────────────────────────────────────

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ResponderTile extends StatelessWidget {
  const _ResponderTile({required this.responder});
  final Responder responder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              responder.role.isNotEmpty ? responder.role[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                responder.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                responder.status,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event});
  final TimelineEvent event;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(event.time);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.description,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared badges (used by both list and details) ────────────────────────────

/// Status badge (active / pending / resolved).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final EmergencyStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      EmergencyStatus.active => (Colors.white, const Color(0xFFEF4444)),
      EmergencyStatus.pending => (Colors.white, AppColors.warning),
      EmergencyStatus.resolved => (Colors.white, AppColors.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Priority badge (critical / high / medium / low).
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});
  final EmergencyPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      EmergencyPriority.critical => const Color(0xFFEA580C),
      EmergencyPriority.high => AppColors.warning,
      EmergencyPriority.medium => AppColors.info,
      EmergencyPriority.low => AppColors.success,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        'Priority: ${priority.label.toUpperCase()}',
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
