class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Admin Panel';
  static const String appVersion = '1.0.0';

  // Firestore collection names
  static const String adminsCollection = 'admins';
  static const String usersCollection = 'users';

  // Firestore field names
  static const String fieldEmail = 'email';
  static const String fieldRole = 'role';
  static const String fieldIsActive = 'isActive';
  static const String fieldName = 'name';
  static const String fieldCreatedAt = 'createdAt';

  // Admin roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';

  // Route names
  static const String routeLogin = '/login';
  static const String routeDashboard = '/dashboard';

  // Error messages
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorEmptyPassword = 'Password cannot be empty.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorNotAdmin =
      'Access denied. This account does not have admin privileges.';
  static const String errorGeneric = 'An unexpected error occurred. Please try again.';
  static const String errorNetworkFailed =
      'Network error. Please check your connection.';

  // UI text
  static const String labelEmail = 'Email address';
  static const String labelPassword = 'Password';
  static const String buttonLogin = 'Sign In';
  static const String titleLogin = 'Admin Sign In';
  static const String subtitleLogin = 'Enter your credentials to access the admin panel.';

  // Mapbox
  // Token is injected at build/run time via --dart-define-from-file=.env
  // Copy .env.example → .env and fill in your token (never commit .env).
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  static const String mapboxStyleStreets =
      'mapbox://styles/mapbox/streets-v12';
  static const String mapboxStyleSatellite =
      'mapbox://styles/mapbox/satellite-streets-v12';
  static const String mapboxStyleOutdoors =
      'mapbox://styles/mapbox/outdoors-v12';

  // Default map position (Los Baños, Laguna, Philippines)
  static const double mapDefaultLng = 121.2167;
  static const double mapDefaultLat = 14.1667;
  static const double mapDefaultZoom = 13.0;
}
