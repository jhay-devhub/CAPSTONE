import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// Clean header shown at the top of the Home screen.
///
/// Shows a time-based greeting with user name (or "Guest"),
/// device ID below, and a notification icon.
class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({
    super.key,
    this.deviceName = '',
    this.deviceId = '',
    this.onHistoryPressed,
  });

  /// The resolved device name (e.g. "Samsung Galaxy S23").
  final String deviceName;

  /// The device ID shown as a small identifier.
  final String deviceId;

  /// Called when the history icon is tapped.
  final VoidCallback? onHistoryPressed;

  @override
  Widget build(BuildContext context) {
    // If user is not logged in, show 'Guest'; otherwise show their name.
    // Currently the app uses anonymous device-based identity,
    // so we always show 'Guest'.
    const userName = 'Guest';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Greeting + device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $userName',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'How are you today?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (deviceName.isNotEmpty) ...[
                      Icon(Icons.smartphone,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          deviceName,
                          style: TextStyle(
                            color: AppColors.textSecondary.withAlpha(180),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (deviceName.isNotEmpty && deviceId.isNotEmpty)
                      Text(
                        '  •  ',
                        style: TextStyle(
                          color: AppColors.textSecondary.withAlpha(120),
                          fontSize: 11,
                        ),
                      ),
                    if (deviceId.isNotEmpty)
                      Flexible(
                        child: Text(
                          deviceId,
                          style: TextStyle(
                            color: AppColors.textSecondary.withAlpha(160),
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Action icons
          IconButton(
            onPressed: onHistoryPressed,
            icon: const Icon(Icons.history_rounded),
            color: AppColors.textPrimary,
            iconSize: 26,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            color: AppColors.textPrimary,
            iconSize: 26,
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Evening';
  }
}
