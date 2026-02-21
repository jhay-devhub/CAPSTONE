/// Named route constants to avoid magic strings in navigation calls.
abstract final class AppRoutes {
  static const String shell = '/';
  static const String home = '/home';
  static const String rescueTracking = '/rescue-tracking';
  static const String safetyTips = '/safety-tips';
  static const String profile = '/profile';
}

/// Bottom navigation tab indices for clarity.
abstract final class AppTabIndex {
  static const int home = 0;
  static const int rescueTracking = 1;
  static const int safetyTips = 2;
  static const int profile = 3;
}
