import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../controllers/help_report_controller.dart';
import '../../../models/help_report_model.dart';

/// Shows a contextual status chip beneath the HELP button.
///
/// While sending: shows a spinner chip.
/// After success: shows the live Firestore [HelpReportStatus] from the controller
///   so the user sees pending → acknowledged → in-progress in real-time.
/// On failure: shows an error chip.
class HelpStatusBanner extends StatelessWidget {
  const HelpStatusBanner({super.key, required this.controller});

  final HelpReportController controller;

  @override
  Widget build(BuildContext context) {
    final config = _resolveBannerConfig();
    if (config == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(config.message),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: config.color.withAlpha(25),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: config.color, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, color: config.color, size: 18),
            const SizedBox(width: 8),
            Text(
              config.message,
              style: TextStyle(
                color: config.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _BannerConfig? _resolveBannerConfig() {
    // While actively sending show spinner state.
    if (controller.state == HelpReportState.sending) {
      return const _BannerConfig(
        message: AppStrings.helpSending,
        color: AppColors.info,
        icon: Icons.send,
      );
    }

    if (controller.state == HelpReportState.failure) {
      return const _BannerConfig(
        message: AppStrings.helpSentFailure,
        color: AppColors.error,
        icon: Icons.error_outline,
      );
    }

    // Show live Firestore status once report is submitted.
    final live = controller.liveStatus;
    if (live != null) {
      return switch (live) {
        HelpReportStatus.pending => const _BannerConfig(
            message: '🕐 Report Pending – Waiting for response…',
            color: AppColors.warning,
            icon: Icons.hourglass_top_rounded,
          ),
        HelpReportStatus.acknowledged => const _BannerConfig(
            message: '✅ Report Acknowledged',
            color: AppColors.info,
            icon: Icons.check_circle_outline,
          ),
        HelpReportStatus.inProgress => const _BannerConfig(
            message: '🚨 Help is on the way!',
            color: AppColors.success,
            icon: Icons.directions_car_outlined,
          ),
        HelpReportStatus.resolved => const _BannerConfig(
            message: '✔ Report Resolved',
            color: AppColors.success,
            icon: Icons.task_alt,
          ),
        HelpReportStatus.cancelled => const _BannerConfig(
            message: 'Report Cancelled',
            color: AppColors.textSecondary,
            icon: Icons.cancel_outlined,
          ),
      };
    }

    return null;
  }
}

@immutable
class _BannerConfig {
  const _BannerConfig({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;
}
