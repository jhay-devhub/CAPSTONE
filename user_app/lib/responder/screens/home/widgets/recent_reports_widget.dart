import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../controllers/recent_reports_controller.dart';
import '../../../models/help_report_model.dart';

/// Displays up to [RecentReportsController.maxReports] previous reports in
/// compact cards. Updates live whenever Firestore changes.
class RecentReportsSection extends StatelessWidget {
  const RecentReportsSection({super.key, required this.controller});

  final RecentReportsController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ──────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.history_rounded,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Recent Reports',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Content ─────────────────────────────────────────────────────
            if (controller.isLoading)
              const _LoadingShimmer()
            else if (controller.isEmpty)
              const _EmptyState()
            else
              ...controller.reports.map((r) => _ReportCard(report: r)),
          ],
        );
      },
    );
  }
}

// ── Report card ───────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});
  final HelpReportModel report;

  @override
  Widget build(BuildContext context) {
    final statusCfg = _statusConfig(report.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Emergency type icon bubble
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                report.emergencyType.icon,
                color: AppColors.primary,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Type + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.emergencyType.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(report.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

            // Status chip
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusCfg.color.withAlpha(22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusCfg.icon,
                      size: 13, color: statusCfg.color),
                  const SizedBox(width: 4),
                  Text(
                    statusCfg.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusCfg.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(HelpReportStatus status) {
    return switch (status) {
      HelpReportStatus.pending => const _StatusConfig(
          label: 'Pending',
          color: AppColors.warning,
          icon: Icons.hourglass_top_rounded,
        ),
      HelpReportStatus.acknowledged => const _StatusConfig(
          label: 'Acknowledged',
          color: AppColors.info,
          icon: Icons.check_circle_outline,
        ),
      HelpReportStatus.inProgress => const _StatusConfig(
          label: 'In Progress',
          color: AppColors.success,
          icon: Icons.directions_car_outlined,
        ),
      HelpReportStatus.resolved => const _StatusConfig(
          label: 'Resolved',
          color: Color(0xFF2E7D32),
          icon: Icons.task_alt,
        ),
      HelpReportStatus.cancelled => const _StatusConfig(
          label: 'Cancelled',
          color: AppColors.textSecondary,
          icon: Icons.cancel_outlined,
        ),
    };
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    final timeStr = _formatTime(dt);

    if (date == today) return 'Today, $timeStr';
    if (date == yesterday) return 'Yesterday, $timeStr';

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month]} ${dt.day}, $timeStr';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No reports yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Config helpers ────────────────────────────────────────────────────────────

@immutable
class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
