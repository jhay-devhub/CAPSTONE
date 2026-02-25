import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/map_controller.dart';
import '../../controllers/rescue_report_controller.dart';
import '../../models/help_report_model.dart';
import 'widgets/map_view_widget.dart';

/// Rescue & Tracking screen – shows a live Mapbox map centred on the
/// user's current GPS location with the Los Baños boundary overlay.
<<<<<<< HEAD
/// Map takes the top half; emergency status takes the bottom half.
=======
///
/// Streams the user's most-recent active report from Firestore and shows:
///   • A marker pin at the reported location on the map
///   • A live status panel at the bottom of the screen
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
class RescueTrackingScreen extends StatefulWidget {
  const RescueTrackingScreen({super.key});

  @override
  State<RescueTrackingScreen> createState() => _RescueTrackingScreenState();
}

class _RescueTrackingScreenState extends State<RescueTrackingScreen>
    with AutomaticKeepAliveClientMixin {
  final LocationController _locationController = LocationController();
  final MapController _mapController = MapController();
<<<<<<< HEAD
  bool _isMapExpanded = false;
=======
  final RescueReportController _reportController = RescueReportController();
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _locationController.requestPermissionAndFetch();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _mapController.dispose();
    _reportController.dispose();
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

  void _toggleMapSize() {
    setState(() => _isMapExpanded = !_isMapExpanded);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
      body: Column(
        children: [
<<<<<<< HEAD
          // ── Map section (top half or full screen) ──────────────────────
          Expanded(
            flex: _isMapExpanded ? 1 : 1,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: ListenableBuilder(
                    listenable: _locationController,
                    builder: (context, _) {
                      return MapViewWidget(
                        locationController: _locationController,
                        mapController: _mapController,
                      );
                    },
                  ),
                ),
                // Expand/collapse toggle button
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _toggleMapSize,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isMapExpanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isMapExpanded ? 'Show Status' : 'Expand Map',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
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
          ),

          // ── Emergency status section (bottom half) ────────────────────
          if (!_isMapExpanded)
            Expanded(
              flex: 1,
              child: _EmergencyStatusSection(),
            ),
=======
          Expanded(
            child: ListenableBuilder(
              listenable:
                  Listenable.merge([_locationController, _reportController]),
              builder: (context, _) {
                return MapViewWidget(
                  locationController: _locationController,
                  mapController: _mapController,
                  activeReport: _reportController.activeReport,
                );
              },
            ),
          ),
          // Live status panel – only shown when a report exists.
          ListenableBuilder(
            listenable: _reportController,
            builder: (context, _) {
              final report = _reportController.activeReport;
              if (report == null) return const SizedBox.shrink();
              return _ReportStatusPanel(report: report);
            },
          ),
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
        ],
      ),
    );
  }
}

<<<<<<< HEAD
/// Bottom section showing active emergency status or empty state.
class _EmergencyStatusSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real emergency tracking data
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 40,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Active Emergency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your location is being tracked.\nWhen you send a help report, rescue status\nwill appear here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'All clear',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
=======
// ── Status panel ──────────────────────────────────────────────────────────────

class _ReportStatusPanel extends StatelessWidget {
  const _ReportStatusPanel({required this.report});
  final HelpReportModel report;

  Color _statusColor() => switch (report.status) {
        HelpReportStatus.pending => AppColors.warning,
        HelpReportStatus.acknowledged => AppColors.info,
        HelpReportStatus.inProgress => AppColors.success,
        HelpReportStatus.resolved => AppColors.success,
        HelpReportStatus.cancelled => AppColors.textSecondary,
      };

  IconData _statusIcon() => switch (report.status) {
        HelpReportStatus.pending => Icons.hourglass_top_rounded,
        HelpReportStatus.acknowledged => Icons.check_circle_outline,
        HelpReportStatus.inProgress => Icons.directions_car_outlined,
        HelpReportStatus.resolved => Icons.task_alt,
        HelpReportStatus.cancelled => Icons.cancel_outlined,
      };

  String _statusLabel() => switch (report.status) {
        HelpReportStatus.pending => 'Pending – Waiting for response',
        HelpReportStatus.acknowledged => 'Acknowledged',
        HelpReportStatus.inProgress => 'Help is on the way!',
        HelpReportStatus.resolved => 'Resolved',
        HelpReportStatus.cancelled => 'Cancelled',
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(_statusIcon(), color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                _statusLabel(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.emergency_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                report.emergencyType.label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${report.latitude.toStringAsFixed(5)}, '
                '${report.longitude.toStringAsFixed(5)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
>>>>>>> 595f9dab6164cda79ddddad8ee835590f698916f
          ),
        ],
      ),
    );
  }
}
