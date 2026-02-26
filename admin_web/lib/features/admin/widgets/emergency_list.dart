import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/emergency_controller.dart';
import '../models/emergency_model.dart';
import 'emergency_details.dart';

/// Left side panel — shows the list of emergency reports with
/// status filter tabs. Tap a card to select it and open the details.
class EmergencyListPanel extends StatelessWidget {
  const EmergencyListPanel({super.key, required this.controller});

  final EmergencyController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _PanelHeader(controller: controller),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: Obx(() {
                if (controller.activeTab.value == 'details') {
                  return EmergencyDetailsView(controller: controller);
                }
                return Column(
                  children: [
                    _FilterBar(controller: controller),
                    const Divider(height: 1, color: AppColors.divider),
                    Expanded(child: _ReportList(controller: controller)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Panel header with List / Details tabs ─────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.controller});
  final EmergencyController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            _Tab(
              label: 'List',
              active: controller.activeTab.value == 'list',
              onTap: () => controller.setTab('list'),
            ),
            _Tab(
              label: 'Details',
              active: controller.activeTab.value == 'details',
              onTap: () => controller.setTab('details'),
            ),
          ],
        ));
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? AppColors.surface : AppColors.background,
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Filter chips row ──────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});
  final EmergencyController controller;

  static const _filters = ['all', 'active', 'pending', 'resolved'];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: _filters
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _FilterChip(
                        label: _label(f),
                        selected: controller.statusFilter.value == f,
                        color: _color(f),
                        onTap: () => controller.setFilter(f),
                      ),
                    ))
                .toList(),
          ),
        ));
  }

  String _label(String f) => switch (f) {
        'all' => 'All',
        'active' => 'Active',
        'pending' => 'Pending',
        'resolved' => 'Resolved',
        _ => f,
      };

  Color _color(String f) => switch (f) {
        'active' => AppColors.error,
        'pending' => AppColors.warning,
        'resolved' => AppColors.success,
        _ => AppColors.primary,
      };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── List of emergency report cards ───────────────────────────────────────────

class _ReportList extends StatelessWidget {
  const _ReportList({required this.controller});
  final EmergencyController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state while first load is in progress
      if (controller.isLoadingReports.value && controller.totalCount == 0) {
        return const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }

      final reports = controller.filteredReports;
      if (reports.isEmpty) {
        return const Center(
          child: Text(
            'No reports found',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: reports.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 12, endIndent: 12),
        itemBuilder: (_, i) => _ReportCard(
          report: reports[i],
          isSelected: controller.selectedReport.value?.id == reports[i].id,
          onTap: () => controller.selectReport(reports[i]),
        ),
      );
    });
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.isSelected,
    required this.onTap,
  });
  final EmergencyReport report;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type + status badge
            Row(
              children: [
                Icon(_typeIcon(report.type),
                    size: 16, color: _typeColor(report.type)),
                const SizedBox(width: 6),
                Text(
                  report.type.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _typeColor(report.type),
                  ),
                ),
                const SizedBox(width: 6),
                StatusBadge(status: report.status),
              ],
            ),
            const SizedBox(height: 6),
            // Address
            Text(
              report.address,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Priority
            Text(
              'Priority: ${report.priority.label}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            // Assigned units
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                ...report.assignedUnits
                    .take(2)
                    .map((u) => _UnitChip(label: u)),
                if (report.assignedUnits.length > 2)
                  _UnitChip(label: '+${report.assignedUnits.length - 2}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(EmergencyType t) => switch (t) {
        EmergencyType.fire => Icons.local_fire_department_rounded,
        EmergencyType.medical => Icons.medical_services_rounded,
        EmergencyType.police ||
        EmergencyType.crime =>
          Icons.local_police_rounded,
        EmergencyType.flood => Icons.water_rounded,
        EmergencyType.roadAccident => Icons.car_crash_rounded,
        EmergencyType.naturalDisaster => Icons.landslide_rounded,
        EmergencyType.other => Icons.warning_rounded,
      };

  Color _typeColor(EmergencyType t) => switch (t) {
        EmergencyType.fire => const Color(0xFFEF4444),
        EmergencyType.medical => const Color(0xFF3B82F6),
        EmergencyType.police || EmergencyType.crime => const Color(0xFF8B5CF6),
        EmergencyType.flood => const Color(0xFF0EA5E9),
        EmergencyType.roadAccident => const Color(0xFFFB923C),
        EmergencyType.naturalDisaster => const Color(0xFF84CC16),
        EmergencyType.other => AppColors.warning,
      };
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
