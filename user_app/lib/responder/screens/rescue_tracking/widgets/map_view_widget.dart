import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../controllers/location_controller.dart';
import '../../../controllers/map_controller.dart';
import '../../../models/help_report_model.dart';
import 'mapbox_map_widget.dart';

/// Orchestrates loading / error states for the map and renders
/// [MapboxMapWidget] once a GPS fix is available.
class MapViewWidget extends StatelessWidget {
  const MapViewWidget({
    super.key,
    required this.locationController,
    required this.mapController,
    this.activeReport,
  });

  final LocationController locationController;
  final MapController mapController;

  /// The user’s latest active report – if set, a marker is placed on the map.
  final HelpReportModel? activeReport;

  @override
  Widget build(BuildContext context) {
    final locationState = locationController.fetchState;

    if (locationState == LocationFetchState.loading) {
      return const _MapLoadingOverlay();
    }

    if (locationState == LocationFetchState.error) {
      return _MapErrorOverlay(
        errorCode: locationController.errorMessage,
        onRetry: locationController.requestPermissionAndFetch,
      );
    }

    // Location is ready (idle or loaded) — show the live map.
    return MapboxMapWidget(
      controller: mapController,
      locationController: locationController,
      activeReport: activeReport,
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Shown while the GPS fix is being obtained.
class _MapLoadingOverlay extends StatelessWidget {
  const _MapLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(AppStrings.fetchingLocation),
        ],
      ),
    );
  }
}

/// Shown when the GPS position could not be obtained.
class _MapErrorOverlay extends StatelessWidget {
  const _MapErrorOverlay({
    required this.errorCode,
    required this.onRetry,
  });

  final String? errorCode;
  final VoidCallback onRetry;

  String _resolveMessage() {
    switch (errorCode) {
      case 'location_service_disabled':
        return AppStrings.locationServiceDisabled;
      case 'location_permission_denied':
        return AppStrings.locationPermissionDenied;
      default:
        return AppStrings.errorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _resolveMessage(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

