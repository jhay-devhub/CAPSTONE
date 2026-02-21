import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../controllers/help_report_controller.dart';
import '../../controllers/location_controller.dart';
import 'widgets/help_button_widget.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/help_status_banner.dart';
import 'widgets/help_report_form_sheet.dart';

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

  /// True only while we are actively waiting for the device GPS fix.
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _locationController.requestPermissionAndFetch();
    _helpController.addListener(_onHelpStateChanged);
  }

  @override
  void dispose() {
    _helpController.removeListener(_onHelpStateChanged);
    _helpController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ── Listener ───────────────────────────────────────────────────────────────

  void _onHelpStateChanged() {
    if (!mounted) return;
    final state = _helpController.state;

    if (state == HelpReportState.success || state == HelpReportState.failure) {
      // Auto-reset after 4 s so the user can try again if needed.
      Future<void>.delayed(const Duration(seconds: 4), () {
        if (mounted) _helpController.reset();
      });
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onHelpButtonPressed() async {
    // Guard: ignore taps while a report is already in progress.
    if (_helpController.isSending || _isFetchingLocation) return;

    // Step 1 – ensure we have a GPS position before opening the form.
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

    // Step 2 – open the form sheet and wait for the user's input.
    final formData = await showHelpReportFormSheet(context);
    if (formData == null || !mounted) return;

    // Step 3 – submit the report with the collected form data.
    await _helpController.sendHelpReport(
      latitude: _locationController.latitude,
      longitude: _locationController.longitude,
      userId: 'user_001', // TODO: replace with real authenticated user ID.
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
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([_helpController, _locationController]),
          builder: (context, _) {
            final isBusy =
                _helpController.isSending || _isFetchingLocation;

            return Row(
              children: [
                // Left spacer – occupies the left ~45 % of the screen.
                const Spacer(flex: 1),

                // Content column – right ~55 % of the screen.
                Expanded(
                  flex: 11,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const HomeHeaderWidget(),
                      const SizedBox(height: 48),
                      if (_isFetchingLocation)
                        const _LocationFetchingIndicator()
                      else
                        HelpButtonWidget(
                          onPressed: _onHelpButtonPressed,
                          isEnabled: !isBusy,
                        ),
                      const SizedBox(height: 28),
                      HelpStatusBanner(reportState: _helpController.state),
                    ],
                  ),
                ),

                // Small right margin.
                const SizedBox(width: 120),
              ],
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
