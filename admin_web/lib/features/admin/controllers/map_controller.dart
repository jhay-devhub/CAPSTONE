import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';

/// GetX controller that owns all reactive map state.
/// The actual Mapbox GL JS map lives in JavaScript; this controller
/// holds the Flutter-side state and exposes helper methods used by
/// [MapboxMapWidget] to drive the JS bridge.
class MapController extends GetxController {
  // ── reactive state ────────────────────────────────────────────────────────

  final RxString activeStyle = AppConstants.mapboxStyleStreets.obs;
  final RxDouble centerLng = AppConstants.mapDefaultLng.obs;
  final RxDouble centerLat = AppConstants.mapDefaultLat.obs;
  final RxDouble zoom = AppConstants.mapDefaultZoom.obs;
  final RxBool isMapReady = false.obs;
  final RxBool isSatellite = false.obs;
  final RxBool maskVisible = false.obs;

  // ── available styles shown in the UI ─────────────────────────────────────

  final List<MapStyleOption> styleOptions = const [
    MapStyleOption(
      label: 'Streets',
      url: AppConstants.mapboxStyleStreets,
      icon: '🗺️',
    ),
    MapStyleOption(
      label: 'Satellite',
      url: AppConstants.mapboxStyleSatellite,
      icon: '🛰️',
    ),
    MapStyleOption(
      label: 'Outdoors',
      url: AppConstants.mapboxStyleOutdoors,
      icon: '⛰️',
    ),
  ];

  // ── public API ────────────────────────────────────────────────────────────

  /// Called by [MapboxMapWidget] once the JS map has been initialised.
  void onMapReady() => isMapReady.value = true;

  /// Switch the base map style; the widget observes [activeStyle] and
  /// forwards the change to the JS bridge.
  void setStyle(String styleUrl) {
    if (activeStyle.value == styleUrl) return;
    activeStyle.value = styleUrl;
    isSatellite.value = styleUrl == AppConstants.mapboxStyleSatellite;
  }

  /// Toggle the visibility of the Los Baños mask/outline.
  void toggleMask() {
    maskVisible.value = !maskVisible.value;
  }

  /// Fly the camera to [lng]/[lat] at the given [zoom] level.
  void flyTo(double lng, double lat, {double? targetZoom}) {
    centerLng.value = lng;
    centerLat.value = lat;
    if (targetZoom != null) zoom.value = targetZoom;
  }
}

// ── value object ─────────────────────────────────────────────────────────────

class MapStyleOption {
  const MapStyleOption({
    required this.label,
    required this.url,
    required this.icon,
  });

  final String label;
  final String url;
  final String icon;
}
