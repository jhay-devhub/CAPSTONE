import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../controllers/profile_controller.dart';
import 'settings_tile_widget.dart';

/// Renders the complete settings list section for the Profile screen.
/// Delegates toggle/tap logic back via callbacks to keep this widget pure UI.
class ProfileSettingsListWidget extends StatelessWidget {
  const ProfileSettingsListWidget({
    super.key,
    required this.controller,
    required this.onEmergencyContactsTap,
    required this.onAboutTap,
    required this.onLogoutTap,
  });

  final ProfileController controller;
  final VoidCallback onEmergencyContactsTap;
  final VoidCallback onAboutTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: AppStrings.settingsSectionLabel),
            SettingsTileWidget(
              icon: Icons.notifications_outlined,
              label: AppStrings.settingsNotifications,
              toggleValue: controller.notificationsEnabled,
              onToggleChanged: (value) =>
                  controller.toggleNotifications(value: value),
            ),
            SettingsTileWidget(
              icon: Icons.location_on_outlined,
              label: AppStrings.settingsLocation,
              toggleValue: controller.locationAccessEnabled,
              onToggleChanged: (value) =>
                  controller.toggleLocationAccess(value: value),
            ),
            const Divider(height: 1),
            SettingsTileWidget(
              icon: Icons.contacts_outlined,
              label: AppStrings.settingsEmergencyContacts,
              onTap: onEmergencyContactsTap,
            ),
            SettingsTileWidget(
              icon: Icons.info_outline,
              label: AppStrings.settingsAbout,
              onTap: onAboutTap,
            ),
            const Divider(height: 1),
            SettingsTileWidget(
              icon: Icons.logout,
              label: AppStrings.settingsLogout,
              onTap: onLogoutTap,
              isDestructive: true,
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.navUnselected,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
      ),
    );
  }
}
