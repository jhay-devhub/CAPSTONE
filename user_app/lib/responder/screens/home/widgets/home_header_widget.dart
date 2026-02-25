import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// Gradient header card shown at the top of the Home screen.
///
/// Shows a time-based greeting, a subtitle, and the device name as a
/// small chip so the anonymous reporter can identify their device.
class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key, this.deviceName = ''});

  /// The resolved device name (e.g. "Samsung Galaxy S23").
  /// Shows a placeholder while it's still being fetched.
  final String deviceName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time-based greeting
          Text(
            _greeting(),
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your safety is our priority.',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Device chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withAlpha(60),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.smartphone,
                    size: 14, color: Color(0xDDFFFFFF)),
                const SizedBox(width: 6),
                Text(
                  deviceName.isEmpty ? 'This device' : deviceName,
                  style: const TextStyle(
                    color: Color(0xEEFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning! 👋';
    if (hour >= 12 && hour < 17) return 'Good afternoon! 👋';
    if (hour >= 17 && hour < 21) return 'Good evening! 👋';
    return 'Stay safe tonight! 🌙';
  }
}
