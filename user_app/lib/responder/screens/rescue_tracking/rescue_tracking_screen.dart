import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../controllers/location_controller.dart';
import 'widgets/map_view_widget.dart';

/// Rescue & Tracking screen – shows a live map overlay
/// centred on the user's current GPS location.
class RescueTrackingScreen extends StatefulWidget {
  const RescueTrackingScreen({super.key});

  @override
  State<RescueTrackingScreen> createState() => _RescueTrackingScreenState();
}

class _RescueTrackingScreenState extends State<RescueTrackingScreen>
    with AutomaticKeepAliveClientMixin {
  final LocationController _locationController = LocationController();

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
    super.dispose();
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
            onPressed: _locationController.requestPermissionAndFetch,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _locationController,
        builder: (context, _) {
          return MapViewWidget(
            locationController: _locationController,
          );
        },
      ),
    );
  }
}
