import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../controllers/profile_controller.dart';
import 'widgets/profile_header_widget.dart';
import 'widgets/profile_settings_list_widget.dart';

/// Profile screen – shows user details and application settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final ProfileController _profileController = ProfileController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _onEmergencyContactsTap() {
    // TODO: Navigate to emergency contacts screen.
    _showComingSoonSnackBar(AppStrings.settingsEmergencyContacts);
  }

  void _onAboutTap() {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 ResQLink Team',
    );
  }

  void _onLogoutTap() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.helpDialogCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.settingsLogout),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        // TODO: Call auth logout service.
        _showComingSoonSnackBar('Logout');
      }
    });
  }

  void _showComingSoonSnackBar(String featureName) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$featureName – coming soon!')),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
      ),
      body: ListenableBuilder(
        listenable: _profileController,
        builder: (context, _) {
          if (_profileController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_profileController.errorMessage != null) {
            return Center(
              child: Text(
                _profileController.errorMessage!,
                textAlign: TextAlign.center,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeaderWidget(profile: _profileController.profile),
                ProfileSettingsListWidget(
                  controller: _profileController,
                  onEmergencyContactsTap: _onEmergencyContactsTap,
                  onAboutTap: _onAboutTap,
                  onLogoutTap: _onLogoutTap,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
