import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_constants.dart';
import '../../../controllers/location_controller.dart';
import '../../../controllers/map_controller.dart';

/// Flutter widget that renders a full Mapbox native map via
/// [MapWidget] from the `mapbox_maps_flutter` package.
///
/// Features:
/// - Los Baños boundary outline (GeoJSON asset)
/// - Animated user-location pulsing dot
/// - Camera centres on the user's GPS fix when available
/// - Toolbar with style picker + "fit Los Baños" + boundary toggle buttons
///
/// Usage:
/// ```dart
/// MapboxMapWidget(
///   controller: _mapController,
///   locationController: _locationController,
/// )
/// ```
class MapboxMapWidget extends StatefulWidget {
  const MapboxMapWidget({
    super.key,
    required this.controller,
    required this.locationController,
  });

  final MapController controller;
  final LocationController locationController;

  @override
  State<MapboxMapWidget> createState() => _MapboxMapWidgetState();
}

class _MapboxMapWidgetState extends State<MapboxMapWidget> {
  MapController get _ctrl => widget.controller;
  LocationController get _locCtrl => widget.locationController;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    super.dispose();
  }

  // Rebuilds the toolbar when the controller notifies (style / mask changes).
  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  // ── Map lifecycle ─────────────────────────────────────────────────────────

  void _onMapCreated(MapboxMap mapboxMap) {
    _ctrl.onMapCreated(mapboxMap);
  }

  /// Called by the SDK every time a style finishes loading (initial + swaps).
  /// Re-adds custom layers so they survive style changes.
  Future<void> _onStyleLoaded(StyleLoadedEventData _) async {
    await _addBoundaryLayer();
    await _enableLocationPuck();
    await _centreOnUser();
  }

  /// Loads the GeoJSON boundary from assets and adds a line layer.
  Future<void> _addBoundaryLayer() async {
    final map = _ctrl.mapboxMap;
    if (map == null) return;

    try {
      final geoJson =
          await rootBundle.loadString('assets/geo/los_banos_boundary.geojson');

      // Remove stale source/layer if the style was switched.
      try {
        await map.style.removeStyleLayer('los-banos-outline');
      } catch (_) {}
      try {
        await map.style.removeStyleSource('los-banos-boundary');
      } catch (_) {}

      await map.style.addSource(
        GeoJsonSource(id: 'los-banos-boundary', data: geoJson),
      );

      await map.style.addLayer(
        LineLayer(
          id: 'los-banos-outline',
          sourceId: 'los-banos-boundary',
          lineColor: AppColors.accent.value, // blue from app palette
          lineWidth: 2.0,
          lineOpacity: 0.85,
        ),
      );

      // Respect current toggle state.
      if (!_ctrl.maskVisible) {
        await map.style.setStyleLayerProperty(
          'los-banos-outline',
          'visibility',
          'none',
        );
      }
    } catch (e) {
      debugPrint('[MapboxMapWidget] addBoundaryLayer error: $e');
    }
  }

  /// Enables the built-in pulsing blue location dot.
  Future<void> _enableLocationPuck() async {
    await _ctrl.mapboxMap?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        puckBearingEnabled: true,
        pulsingEnabled: true,
        pulsingColor: AppColors.accent.value,
      ),
    );
  }

  /// Flies the camera to the user's current GPS position (if available).
  Future<void> _centreOnUser() async {
    final pos = _locCtrl.currentPosition;
    if (pos != null) {
      await _ctrl.flyTo(pos.longitude, pos.latitude, targetZoom: 15.0);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Guard: show a clear error if the token was not injected at compile time.
    if (AppConstants.mapboxAccessToken.isEmpty) {
      return _TokenMissingError();
    }

    return Column(
      children: [
        _MapToolbar(controller: _ctrl),
        Expanded(
          child: MapWidget(
            key: const ValueKey('rescue-tracking-map'),
            styleUri: _ctrl.activeStyle,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  AppConstants.mapDefaultLng,
                  AppConstants.mapDefaultLat,
                ),
              ),
              zoom: AppConstants.mapDefaultZoom,
            ),
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoaded,
          ),
        ),
      ],
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────────────────────────

class _MapToolbar extends StatelessWidget {
  const _MapToolbar({required this.controller});

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            'Live Map',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const Spacer(),

          // Style selector
          _StyleSelector(controller: controller),

          const SizedBox(width: 8),

          // Fit-to-Los-Baños button
          Tooltip(
            message: 'Fit to Los Baños',
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: controller.fitLosBanos,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.fit_screen_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Boundary toggle button
          Tooltip(
            message: controller.maskVisible
                ? 'Hide Los Baños boundary'
                : 'Show Los Baños boundary',
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: controller.toggleMask,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  controller.maskVisible
                      ? Icons.layers
                      : Icons.layers_outlined,
                  size: 18,
                  color: controller.maskVisible
                      ? AppColors.accent
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Style selector ────────────────────────────────────────────────────────────

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({required this.controller});

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.styleOptions.firstWhere(
      (o) => o.url == controller.activeStyle,
      orElse: () => controller.styleOptions.first,
    );

    return PopupMenuButton<MapStyleOption>(
      tooltip: 'Change map style',
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (_) => controller.styleOptions
          .map(
            (opt) => PopupMenuItem<MapStyleOption>(
              value: opt,
              child: Row(
                children: [
                  Text(opt.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontWeight: opt.url == controller.activeStyle
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: opt.url == controller.activeStyle
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (opt.url == controller.activeStyle) ...[
                    const Spacer(),
                    const Icon(Icons.check, size: 16, color: AppColors.accent),
                  ],
                ],
              ),
            ),
          )
          .toList(),
      onSelected: (opt) => controller.setStyle(opt.url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              current.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Token missing error ───────────────────────────────────────────────────────

class _TokenMissingError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.key_off_outlined,
                size: 48, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(
              'Mapbox token missing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Run with: flutter run --dart-define-from-file=.env',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
