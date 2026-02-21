import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../controllers/help_report_controller.dart';

/// Shows a contextual status chip beneath the HELP button
/// reflecting the current [HelpReportState].
class HelpStatusBanner extends StatelessWidget {
  const HelpStatusBanner({
    super.key,
    required this.reportState,
  });

  final HelpReportState reportState;

  @override
  Widget build(BuildContext context) {
    final config = _bannerConfig(reportState);
    if (config == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(reportState),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  _BannerConfig? _bannerConfig(HelpReportState reportState) {
    return switch (reportState) {
      HelpReportState.sending => const _BannerConfig(
          message: AppStrings.helpSending,
          color: AppColors.info,
          icon: Icons.send,
        ),
      HelpReportState.success => const _BannerConfig(
          message: AppStrings.helpSentSuccess,
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        ),
      HelpReportState.failure => const _BannerConfig(
          message: AppStrings.helpSentFailure,
          color: AppColors.error,
          icon: Icons.error_outline,
        ),
      HelpReportState.idle => null,
    };
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
