import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

/// Displays the greeting header with dynamic device name on the Home screen.
class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({
    super.key,
    this.deviceName,
  });

  /// The dynamic device name (e.g. "Realme 10").
  final String? deviceName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayName = (deviceName != null && deviceName!.isNotEmpty)
        ? deviceName!
        : 'Loading device…';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Device name chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                displayName,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // App name – ResQLink
        Text(
          AppStrings.appName,
          style: textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Greeting
        Text(
          AppStrings.homeGreeting,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          AppStrings.homeSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
