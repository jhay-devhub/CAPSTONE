import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../constants/app_constants.dart';

/// Manages Mapbox map state for the Rescue & Tracking screen.
///
/// Wraps the [MapboxMap] SDK controller (provided by [MapWidget.onMapCreated])
/// and exposes reactive state via [ChangeNotifier] so widgets can rebuild
/// without an extra state-management package.
///
/// NOTE: This controller is used only on Android / iOS via mapbox_maps_flutter.
class MapController extends ChangeNotifier {
  // ── SDK handle ────────────────────────────────────────────────────────────

  MapboxMap? _mapboxMap;
  MapboxMap? get mapboxMap => _mapboxMap;

  // ── Reactive state ────────────────────────────────────────────────────────

  bool _isMapReady = false;
  bool _maskVisible = false;
  String _activeStyle = AppConstants.mapboxStyleStreets;

  bool get isMapReady => _isMapReady;
  bool get maskVisible => _maskVisible;
  String get activeStyle => _activeStyle;

  // ── Available base styles ─────────────────────────────────────────────────

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

  // ── Called by MapboxMapWidget ─────────────────────────────────────────────

  /// Stores the SDK controller once the [MapWidget] has been created.
  void onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _isMapReady = true;
    notifyListeners();
  }

  // ── Public actions ────────────────────────────────────────────────────────

  /// Switch the base-map style; the widget re-adds custom layers after the
  /// style has loaded via its [onStyleLoadedEventListener].
  Future<void> setStyle(String styleUrl) async {
    if (_activeStyle == styleUrl) return;
    _activeStyle = styleUrl;
    notifyListeners();
    await _mapboxMap?.style.setStyleURI(styleUrl);
  }

  /// Toggle the visibility of the Los Baños boundary outline layer.
  Future<void> toggleMask() async {
    _maskVisible = !_maskVisible;
    notifyListeners();
    await _setBoundaryVisibility(_maskVisible);
  }

  /// Animate the camera to the Los Baños town centre.
  Future<void> fitLosBanos() async {
    await _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            AppConstants.mapDefaultLng,
            AppConstants.mapDefaultLat,
          ),
        ),
        zoom: AppConstants.mapDefaultZoom,
        pitch: 0,
        bearing: 0,
      ),
      MapAnimationOptions(duration: 800),
    );
  }

  /// Fly the camera to [lng]/[lat] at an optional [targetZoom].
  Future<void> flyTo(double lng, double lat, {double? targetZoom}) async {
    await _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: targetZoom ?? AppConstants.mapDefaultZoom,
      ),
      MapAnimationOptions(duration: 600),
    );
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<void> _setBoundaryVisibility(bool visible) async {
    final map = _mapboxMap;
    if (map == null) return;
    try {
      await map.style.setStyleLayerProperty(
        'los-banos-outline',
        'visibility',
        visible ? 'visible' : 'none',
      );
    } catch (_) {
      // Layer may not exist yet (style not fully loaded).
    }
  }

  @override
  void dispose() {
    _mapboxMap = null;
    super.dispose();
  }
}

// ── Value object ──────────────────────────────────────────────────────────────

/// Describes a Mapbox base-style option shown in the style picker.
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

