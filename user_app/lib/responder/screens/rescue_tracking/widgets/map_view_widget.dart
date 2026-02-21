import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../controllers/location_controller.dart';

/// Placeholder widget that reserves space for the map that will be
/// integrated later. Drop the chosen map SDK widget inside
/// [_MapPlaceholder] when ready.
///
/// All loading / error states are preserved so the parent screen
/// needs no changes once the real map is wired in.
class MapViewWidget extends StatelessWidget {
  const MapViewWidget({
    super.key,
    required this.locationController,
  });

  final LocationController locationController;

  @override
  Widget build(BuildContext context) {
    final locationState = locationController.fetchState;
    final position = locationController.currentPosition;

    if (locationState == LocationFetchState.loading) {
      return const _MapLoadingOverlay();
    }

    if (locationState == LocationFetchState.error) {
      return _MapErrorOverlay(
        errorCode: locationController.errorMessage,
        onRetry: locationController.requestPermissionAndFetch,
      );
    }

    return _MapPlaceholder(
      latitude: position?.latitude,
      longitude: position?.longitude,
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

/// Empty container that marks where the map SDK widget will be placed.
/// Replace the [Container] child with your chosen map widget when ready.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({this.latitude, this.longitude});

  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context) {
    final hasLocation = latitude != null && longitude != null;

    return Container(
      // TODO: Replace this Container with your chosen map SDK widget.
      color: const Color(0xFFE8F0E8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 72,
              color: AppColors.primary.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              'Map will appear here',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (hasLocation) ...[
              const SizedBox(height: 8),
              Text(
                'Lat: ${latitude!.toStringAsFixed(5)}  '
                'Lng: ${longitude!.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

