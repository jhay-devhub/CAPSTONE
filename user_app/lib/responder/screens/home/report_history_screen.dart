import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/help_report_model.dart';
import '../../services/firestore_report_service.dart';

/// Full history of all reports submitted by this device.
///
/// Streams live from Firestore so status updates appear in real-time.
class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  List<HelpReportModel> _reports = [];
  bool _isLoading = true;
  StreamSubscription<List<HelpReportModel>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = FirestoreReportService.instance
        .watchReportsByDevice(widget.deviceId)
        .listen(
      (all) {
        if (!mounted) return;
        setState(() {
          _reports = all; // already sorted newest-first
          _isLoading = false;
        });
      },
      onError: (e) {
        debugPrint('[ReportHistoryScreen] stream error: $e');
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Report History'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No reports yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your emergency reports will appear here.',
            style: TextStyle(
              color: AppColors.textSecondary.withAlpha(160),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _HistoryReportCard(report: report);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HistoryReportCard extends StatelessWidget {
  const _HistoryReportCard({required this.report});
  final HelpReportModel report;

  @override
  Widget build(BuildContext context) {
    final statusCfg = _statusConfig(report.status);

    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: emergency type + status chip
            Row(
              children: [
                // Icon bubble
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

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.emergencyType.label,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(report.timestamp),
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      Icon(statusCfg.icon, size: 13, color: statusCfg.color),
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

            // Description (if present)
            if (report.description?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(
                report.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],

            // Location
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${report.latitude.toStringAsFixed(5)}, '
                  '${report.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
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
    return '${months[dt.month]} ${dt.day}, ${dt.year} $timeStr';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

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
