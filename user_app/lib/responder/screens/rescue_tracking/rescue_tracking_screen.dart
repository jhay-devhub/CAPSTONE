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
///
/// Streams the user's most-recent active report from Firestore and shows:
///   • A marker pin at the reported location on the map
///   • A live status panel at the bottom of the screen
class RescueTrackingScreen extends StatefulWidget {
  const RescueTrackingScreen({super.key});

  @override
  State<RescueTrackingScreen> createState() => _RescueTrackingScreenState();
}

class _RescueTrackingScreenState extends State<RescueTrackingScreen>
    with AutomaticKeepAliveClientMixin {
  final LocationController _locationController = LocationController();
  final MapController _mapController = MapController();
  final RescueReportController _reportController = RescueReportController();

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

  bool _isMapExpanded = false;

  void _reCentre() {
    final pos = _locationController.currentPosition;
    if (pos != null) {
      // Just fly the camera to the already-known position – no GPS reload.
      _mapController.flyTo(pos.longitude, pos.latitude, targetZoom: 15.0);
    } else {
      // No cached position yet; fetch once and then fly.
      _locationController.requestPermissionAndFetch().then((_) {
        final p = _locationController.currentPosition;
        if (p != null) {
          _mapController.flyTo(p.longitude, p.latitude, targetZoom: 15.0);
        }
      });
    }
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
        ],
      ),
    );
  }
}

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
          ),
        ],
      ),
    );
  }
}
