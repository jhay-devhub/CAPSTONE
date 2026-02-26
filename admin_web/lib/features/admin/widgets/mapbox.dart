// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:convert';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/emergency_controller.dart';
import '../controllers/map_controller.dart';
import '../models/emergency_model.dart';

/// A Flutter-web widget that embeds a full Mapbox GL JS map via
/// [HtmlElementView] + the JS bridge functions defined in web/index.html.
///
/// Usage:
/// ```dart
/// MapboxMapWidget(controller: Get.find<MapController>())
/// ```
class MapboxMapWidget extends StatefulWidget {
  const MapboxMapWidget({
    super.key,
    required this.controller,
  });

  final MapController controller;

  @override
  State<MapboxMapWidget> createState() => _MapboxMapWidgetState();
}

class _MapboxMapWidgetState extends State<MapboxMapWidget> {
  static int _instanceCounter = 0;

  late final String _containerId;
  late final String _viewType;
  bool _viewRegistered = false;

  MapController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();

    // Give each instance a unique DOM id so multiple maps can coexist.
    _instanceCounter++;
    _containerId = 'mapbox-container-$_instanceCounter';
    _viewType = 'mapbox-view-$_instanceCounter';

    _registerPlatformView();

    // Observe reactive style changes after initial mount.
    ever(_ctrl.activeStyle, (String style) {
      if (_ctrl.isMapReady.value) {
        js.context.callMethod('setMapboxStyle', [_containerId, style]);
      }
    });

    // Observe flyTo changes.
    ever(_ctrl.centerLng, (_) => _flyTo());
    ever(_ctrl.centerLat, (_) => _flyTo());
    ever(_ctrl.zoom, (_) => _flyTo());
  }

  void _registerPlatformView() {
    if (_viewRegistered) return;
    _viewRegistered = true;

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final div = html.DivElement()
          ..id = _containerId
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.position = 'relative';
        return div;
      },
    );
  }

  /// Calls the JS bridge to initialise the Mapbox map.
  /// Must be called after the HtmlElementView is in the DOM.
  void _initMap() {
    js.context.callMethod('initMapbox', [
      _containerId,
      AppConstants.mapboxAccessToken,
    ]);
    _ctrl.onMapReady();
    // Sync initial mask state to JS (off by default).
    js.context.callMethod('setMaskVisible', [_containerId, _ctrl.maskVisible.value]);
    _initMarkers();
  }

  /// Registers the JS->Dart click callback and starts watching all reports.
  void _initMarkers() {
    // Register a global JS callback so marker clicks can reach Dart.
    js.context['_mapboxMarkerClick'] = js.JsFunction.withThis((_, dynamic reportId) {
      try {
        final id = reportId.toString();
        final ec = Get.find<EmergencyController>();
        final report = ec.allReportsRx.firstWhereOrNull((r) => r.id == id);
        if (report != null) ec.selectReport(report);
      } catch (_) {}
    });

    // Push initial markers then update whenever the list changes.
    final ec = Get.find<EmergencyController>();
    _updateMarkers(ec.allReportsRx);
    ever(ec.allReportsRx, (List<EmergencyReport> reports) {
      _updateMarkers(reports);
    });
  }

  /// Serialises only active/pending [reports] with lat/lng to JSON and calls
  /// the JS bridge. Resolved reports are excluded so their pins are removed.
  void _updateMarkers(List<EmergencyReport> reports) {
    if (!_ctrl.isMapReady.value) return;
    final data = reports
        .where((r) =>
            r.status != EmergencyStatus.resolved &&
            r.latitude != null &&
            r.longitude != null)
        .map((r) => {
              'id': r.id,
              'lat': r.latitude!,
              'lng': r.longitude!,
              'type': r.type.name,
              'status': r.status.name,
              'address': r.address,
            })
        .toList();
    js.context.callMethod('setEmergencyMarkers', [_containerId, jsonEncode(data)]);
  }

  void _flyTo() {
    if (!_ctrl.isMapReady.value) return;
    js.context.callMethod('flyMapboxTo', [
      _containerId,
      _ctrl.centerLng.value,
      _ctrl.centerLat.value,
      _ctrl.zoom.value,
    ]);
  }

  @override
  void dispose() {
    js.context.callMethod('removeMapboxMap', [_containerId]);
    super.dispose();
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Guard: show a clear error if the token was not injected at compile time.
    if (AppConstants.mapboxAccessToken.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.key_off_outlined,
                  size: 48, color: AppColors.warning),
              const SizedBox(height: 12),
              const Text(
                'Mapbox token missing',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Run with: flutter run -d chrome --dart-define-from-file=.env',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MapToolbar(controller: _ctrl, containerId: _containerId),
          Expanded(
            child: HtmlElementView(
              viewType: _viewType,
              onPlatformViewCreated: (_) => _initMap(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── toolbar ───────────────────────────────────────────────────────────────────

class _MapToolbar extends StatelessWidget {
  const _MapToolbar({
    required this.controller,
    required this.containerId,
  });

  final MapController controller;
  final String containerId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Live Map',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),

          // Style selector chips
          _StyleSelector(controller: controller),

          const SizedBox(width: 12),

          // Resize / refresh button
          Tooltip(
            message: 'Fit to Los Baños boundary',
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () =>
                  js.context.callMethod('fitMapboxBounds', [containerId]),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.fit_screen_outlined,
                    size: 18, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Mask toggle button
          Obx(() => Tooltip(
                message: controller.maskVisible.value
                    ? 'Hide Los Baños mask'
                    : 'Show Los Baños mask',
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    controller.toggleMask();
                    js.context.callMethod('toggleMask', [containerId]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      controller.maskVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ── style selector ────────────────────────────────────────────────────────────

class _StyleSelector extends StatelessWidget {
  const _StyleSelector({required this.controller});

  final MapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopupMenuButton<MapStyleOption>(
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
                      fontWeight: opt.url == controller.activeStyle.value
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: opt.url == controller.activeStyle.value
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (opt.url == controller.activeStyle.value) ...[
                    const Spacer(),
                    const Icon(Icons.check,
                        size: 16, color: AppColors.primary),
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
          border: Border.all(color: AppColors.inputBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.styleOptions
                  .firstWhere(
                    (o) => o.url == controller.activeStyle.value,
                    orElse: () => controller.styleOptions.first,
                  )
                  .icon,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            Text(
              controller.styleOptions
                  .firstWhere(
                    (o) => o.url == controller.activeStyle.value,
                    orElse: () => controller.styleOptions.first,
                  )
                  .label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    ));
  }
}
