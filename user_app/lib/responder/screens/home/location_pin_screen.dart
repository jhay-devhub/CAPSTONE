import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

/// Full-screen modal that lets the user confirm or adjust their emergency
/// location by dragging the map before the report form is shown.
///
/// Returns a [PinnedLocation] when the user taps "Confirm Location",
/// or `null` if they cancel.
///
/// Flow:
///   1. Map opens centred on [initialLat]/[initialLng] with a centre pin icon.
///   2. User drags the map to reposition the pin.
///   3. Coordinates update whenever the camera becomes idle.
///   4. "Confirm Location" reads the current camera centre and pops.
class LocationPinScreen extends StatefulWidget {
  const LocationPinScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  final double initialLat;
  final double initialLng;

  @override
  State<LocationPinScreen> createState() => _LocationPinScreenState();
}

class _LocationPinScreenState extends State<LocationPinScreen> {
  MapboxMap? _mapboxMap;
  bool _isConfirming = false;

  // Displayed pin coordinates – start at GPS fix, update when map is idle.
  late double _pinLat;
  late double _pinLng;

  @override
  void initState() {
    super.initState();
    _pinLat = widget.initialLat;
    _pinLng = widget.initialLng;
  }

  // ── Map callbacks ─────────────────────────────────────────────────────────

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    // Show the user's real position as a pulsing dot for reference.
    mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        pulsingColor: AppColors.accent.value,
      ),
    );
  }

  /// Called when the camera finishes moving. Updates the displayed coordinates.
  Future<void> _onMapIdle(MapIdleEventData _) async {
    final map = _mapboxMap;
    if (map == null) return;
    final state = await map.getCameraState();
    if (!mounted) return;
    setState(() {
      _pinLng = state.center.coordinates.lng.toDouble();
      _pinLat = state.center.coordinates.lat.toDouble();
    });
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Snap the camera back to the user's original GPS fix.
  Future<void> _snapToGps() async {
    await _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(widget.initialLng, widget.initialLat),
        ),
        zoom: 16.0,
      ),
      MapAnimationOptions(duration: 600),
    );
  }

  /// Read the current camera centre and pop with the confirmed location.
  Future<void> _confirmLocation() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    final map = _mapboxMap;
    double lat = _pinLat;
    double lng = _pinLng;

    if (map != null) {
      final state = await map.getCameraState();
      lat = state.center.coordinates.lat.toDouble();
      lng = state.center.coordinates.lng.toDouble();
    }

    if (mounted) {
      Navigator.of(context).pop(PinnedLocation(latitude: lat, longitude: lng));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────────────────
          MapWidget(
            key: const ValueKey('location-pin-map'),
            styleUri: AppConstants.mapboxStyleStreets,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(widget.initialLng, widget.initialLat),
              ),
              zoom: 16.0,
            ),
            onMapCreated: _onMapCreated,
            onMapIdleListener: _onMapIdle,
          ),

          // ── Centre pin icon ──────────────────────────────────────────────
          // Offset upward by half the icon height so the pin tip sits exactly
          // at the map centre.
          const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: Icon(
                Icons.location_pin,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),

          // ── Top bar ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Drag the map to set your location',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _CircleButton(
                    icon: Icons.my_location,
                    tooltip: 'Back to my GPS location',
                    onTap: _snapToGps,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom panel ─────────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(38),
                        blurRadius: 16,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Live coordinates
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${_pinLat.toStringAsFixed(5)},  '
                            '${_pinLng.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Confirm button
                      ElevatedButton.icon(
                        onPressed: _isConfirming ? null : _confirmLocation,
                        icon: _isConfirming
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: const Text('Confirm Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: AppColors.textPrimary),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

// ── Return value ──────────────────────────────────────────────────────────────

/// The confirmed lat/lng the user selected on the pin map.
class PinnedLocation {
  const PinnedLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
