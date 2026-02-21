/// All user-facing string literals in one place.
/// Replace or wrap with an i18n solution later if needed.
abstract final class AppStrings {
  // App-wide
  static const String appName = 'ResQLink';
  static const String unsupportedPlatformTitle = 'Unsupported Platform';
  static const String unsupportedPlatformMessage =
      'This application is designed for iOS and Android devices only.';

  // Bottom navigation labels
  static const String navHome = 'Home';
  static const String navRescue = 'Rescue & Tracking';
  static const String navSafetyTips = 'Safety Tips';
  static const String navProfile = 'Profile';

  // Home screen
  static const String homeGreeting = 'Stay Safe';
  static const String homeSubtitle = 'Tap the button below if you need emergency help.';
  static const String helpButtonLabel = 'HELP';
  static const String helpDialogCancel = 'Cancel';
  static const String fetchingLocationForReport = 'Fetching your location…';
  static const String locationFetchFailed =
      'Could not get your location. Please check permissions and try again.';

  // Help report form sheet
  static const String reportFormTitle = 'What happened?';
  static const String reportFormSubtitle =
      'We will dispatch the right team to your location.';
  static const String reportTypeLabel = 'Type of Emergency';
  static const String reportTypeRequired = 'Please select an emergency type to continue.';
  static const String reportPhotoLabel = 'Photo (Optional)';
  static const String reportPhotoSubtitle = 'Attach a photo to help responders.';
  static const String reportPhotoPickButton = 'Add Photo';
  static const String reportPhotoRemoveButton = 'Remove Photo';
  static const String reportDescriptionLabel = 'Description (Optional)';
  static const String reportDescriptionHint = 'Briefly describe what happened…';
  static const String reportInjuryLabel = 'Injuries (Optional)';
  static const String reportInjuryHint = 'Describe any injuries if present…';
  static const String reportSendButton = 'Send Report';
  static const String photoSourceCamera = 'Use Camera';
  static const String photoSourceGallery = 'Choose from Gallery';
  static const String photoPickError = 'Could not pick image. Please try again.';
  static const String helpSentSuccess = 'Emergency report sent! Help is on the way.';
  static const String helpSentFailure = 'Failed to send report. Please try again.';
  static const String helpSending = 'Sending report…';

  // Rescue & Tracking screen
  static const String rescueTitle = 'Rescue & Tracking';
  static const String rescueSubtitle = 'Live map of your location and nearby responders.';
  static const String locationPermissionDenied =
      'Location permission denied. Please enable it in Settings.';
  static const String locationServiceDisabled =
      'Location services are disabled. Please turn them on.';
  static const String fetchingLocation = 'Fetching your location…';

  // Safety Tips screen
  static const String safetyTipsTitle = 'Safety Tips';
  static const String safetyTipsSubtitle = 'Follow these steps to stay safe during an emergency.';

  // Profile screen
  static const String profileTitle = 'Profile';
  static const String profileName = 'Full Name';
  static const String profilePhone = 'Phone Number';
  static const String profileEmail = 'Email Address';
  static const String settingsSectionLabel = 'Settings';
  static const String settingsNotifications = 'Notifications';
  static const String settingsLocation = 'Location Access';
  static const String settingsEmergencyContacts = 'Emergency Contacts';
  static const String settingsAbout = 'About ResQLink';
  static const String settingsLogout = 'Log Out';

  // Generic
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String loading = 'Loading…';
  static const String errorGeneric = 'Something went wrong. Please try again.';
}
