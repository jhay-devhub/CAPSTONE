import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../controllers/help_report_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/recent_reports_controller.dart';
import '../../services/device_id_service.dart';
import 'location_pin_screen.dart';
import 'widgets/help_button_widget.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/help_status_banner.dart';
import 'widgets/help_report_form_sheet.dart';
import 'widgets/recent_reports_widget.dart';

/// Home screen – entry point for sending an emergency HELP report.
///
/// HELP button flow:
///   1. Fetch GPS position (shows a spinner if location is not ready).
///   2. Open [showHelpReportFormSheet] and wait for the user to fill the form.
///   3. Forward the [HelpReportFormData] to [HelpReportController].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HelpReportController _helpController = HelpReportController();
  final LocationController _locationController = LocationController();

  /// Stable anonymous reporter ID – resolved once on init.
  String _deviceId = '';
  String _deviceName = '';

  /// Streams the last 3 reports for this device. Created once deviceId resolves.
  RecentReportsController? _recentReportsController;

  /// True only while we are actively waiting for the device GPS fix.
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _locationController.requestPermissionAndFetch();
    _helpController.addListener(_onHelpStateChanged);
    _resolveDeviceInfo();
  }

  /// Fetch the device ID and name once; stored for the session.
  Future<void> _resolveDeviceInfo() async {
    final info = await DeviceIdService.instance.getDeviceInfo();
    if (!mounted) return;
    setState(() {
      _deviceId = info.id;
      _deviceName = info.name;
      _recentReportsController =
          RecentReportsController(deviceId: info.id);
    });
  }

  @override
  void dispose() {
    _helpController.removeListener(_onHelpStateChanged);
    _helpController.dispose();
    _locationController.dispose();
    _recentReportsController?.dispose();
    super.dispose();
  }

  // ── Listener ───────────────────────────────────────────────────────────────

  void _onHelpStateChanged() {
    if (!mounted) return;
    final state = _helpController.state;

    if (state == HelpReportState.failure) {
      final error = _helpController.errorMessage ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    }

    // Reset the send-state after 3 s so the button is re-enabled,
    // but liveStatus keeps showing the Firestore status.
    if (state == HelpReportState.success || state == HelpReportState.failure) {
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (mounted) _helpController.reset();
      });
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onHelpButtonPressed() async {
    // Guard: ignore taps while a report is already in progress.
    if (_helpController.isSending || _isFetchingLocation) return;

    // Step 1 – ensure we have a GPS position before opening the map.
    if (_locationController.currentPosition == null) {
      setState(() => _isFetchingLocation = true);
      try {
        await _locationController.requestPermissionAndFetch();
      } finally {
        if (mounted) setState(() => _isFetchingLocation = false);
      }

      if (!mounted) return;

      // Still no position after fetch attempt – show feedback and abort.
      if (_locationController.currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.locationFetchFailed),
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    // Step 2 – open the location-pin map so the user can confirm / adjust.
    final pinned = await Navigator.of(context).push<PinnedLocation>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LocationPinScreen(
          initialLat: _locationController.latitude,
          initialLng: _locationController.longitude,
        ),
      ),
    );
    if (pinned == null || !mounted) return;

    // Step 3 – open the form sheet and wait for the user's input.
    final formData = await showHelpReportFormSheet(context);
    if (formData == null || !mounted) return;

    // Step 4 – submit using the pinned location + device info to Firestore.
    await _helpController.sendHelpReport(
      latitude: pinned.latitude,
      longitude: pinned.longitude,
      deviceId: _deviceId,
      deviceName: _deviceName,
      emergencyType: formData.emergencyType,
      description: formData.description,
      injuryNote: formData.injuryNote,
      photoPath: formData.photoPath,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([_helpController, _locationController]),
          builder: (context, _) {
            final isBusy =
                _helpController.isSending || _isFetchingLocation;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Greeting header card ─────────────────────────────────
                  HomeHeaderWidget(deviceName: _deviceName),

                  const SizedBox(height: 44),

                  // ── HELP button ──────────────────────────────────────────
                  if (_isFetchingLocation)
                    const _LocationFetchingIndicator()
                  else
                    HelpButtonWidget(
                      onPressed: _onHelpButtonPressed,
                      isEnabled: !isBusy,
                    ),

                  const SizedBox(height: 24),

                  // ── Live status banner (only visible when report active) ─
                  ListenableBuilder(
                    listenable: _helpController,
                    builder: (context, _) =>
                        HelpStatusBanner(controller: _helpController),
                  ),

                  const SizedBox(height: 36),

                  // ── Recent reports (live from Firestore, last 3) ─────────
                  if (_recentReportsController != null)
                    RecentReportsSection(
                        controller: _recentReportsController!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

/// Spinner + label shown while waiting for the initial GPS fix.
class _LocationFetchingIndicator extends StatelessWidget {
  const _LocationFetchingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 12),
        Text(
          AppStrings.fetchingLocationForReport,
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
