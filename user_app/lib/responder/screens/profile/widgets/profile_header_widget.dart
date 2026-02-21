import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/user_profile_model.dart';

/// Displays the user's avatar, name and phone at the top of the Profile screen.
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.profile,
  });

  final UserProfileModel profile;

  static const double _avatarRadius = 44;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: _avatarRadius,
            backgroundColor: AppColors.surface,
            backgroundImage: profile.profileImageUrl != null
                ? NetworkImage(profile.profileImageUrl!)
                : null,
            child: profile.profileImageUrl == null
                ? Text(
                    _initials(profile.fullName),
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName.isEmpty ? '—' : profile.fullName,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.phoneNumber.isEmpty ? '—' : profile.phoneNumber,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textOnPrimary.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
