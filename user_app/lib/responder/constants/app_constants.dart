/// App-wide constants for the user app.
abstract final class AppConstants {
  // Mapbox public access token
  static const String mapboxAccessToken =
      'pk.eyJ1Ijoiamh5bHJkcnZyIiwiYSI6ImNtbGR0dWg4dzExYnIzY3NhZ3k5ZHF5ejgifQ.n1hDdX1gdZNe7M1BVVyMGw';

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
