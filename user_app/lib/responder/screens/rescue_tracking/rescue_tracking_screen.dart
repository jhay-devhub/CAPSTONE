import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/map_controller.dart';
import 'widgets/map_view_widget.dart';

/// Rescue & Tracking screen – shows a live Mapbox map centred on the
/// user's current GPS location with the Los Baños boundary overlay.
class RescueTrackingScreen extends StatefulWidget {
  const RescueTrackingScreen({super.key});

  @override
  State<RescueTrackingScreen> createState() => _RescueTrackingScreenState();
}

class _RescueTrackingScreenState extends State<RescueTrackingScreen>
    with AutomaticKeepAliveClientMixin {
  final LocationController _locationController = LocationController();
  final MapController _mapController = MapController();

  @override
  bool get wantKeepAlive => true; // Preserve map state when switching tabs.

  @override
  void initState() {
    super.initState();
    _locationController.requestPermissionAndFetch();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _reCentre() {
    _locationController.requestPermissionAndFetch().then((_) {
      final pos = _locationController.currentPosition;
      if (pos != null) {
        _mapController.flyTo(pos.longitude, pos.latitude, targetZoom: 15.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin.

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.rescueTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Re-centre map',
            onPressed: _reCentre,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _locationController,
        builder: (context, _) {
          return MapViewWidget(
            locationController: _locationController,
            mapController: _mapController,
          );
        },
      ),
    );
  }
}
