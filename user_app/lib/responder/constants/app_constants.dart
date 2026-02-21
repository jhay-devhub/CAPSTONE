/// App-wide constants for the user app.
/// Mapbox token is injected at build/run time via --dart-define-from-file=.env
/// Copy .env.example → .env and fill in your token (never commit .env).
abstract final class AppConstants {
  // Mapbox access token
  // Supplied at compile time: --dart-define-from-file=.env
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  // Mapbox base styles
  static const String mapboxStyleStreets =
      'mapbox://styles/mapbox/streets-v12';
  static const String mapboxStyleSatellite =
      'mapbox://styles/mapbox/satellite-streets-v12';
  static const String mapboxStyleOutdoors =
      'mapbox://styles/mapbox/outdoors-v12';

  // Default map centre (Los Baños, Laguna, Philippines)
  static const double mapDefaultLng = 121.2167;
  static const double mapDefaultLat = 14.1667;
  static const double mapDefaultZoom = 13.0;
}
