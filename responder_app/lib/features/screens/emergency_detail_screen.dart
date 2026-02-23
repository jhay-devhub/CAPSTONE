// features/screens/emergency_detail_screen.dart
// LB-Sentry | Emergency Detail — Clean White UI, Fixed Header

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_theme.dart';
import '../controllers/responder_controller.dart';
import '../models/emergency_model.dart';
import '../widgets/status_badge.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/info_tile.dart';

class EmergencyDetailScreen extends StatelessWidget {
  final EmergencyModel emergency;

  const EmergencyDetailScreen({super.key, required this.emergency});

  Color _typeColor(EmergencyType type) {
    switch (type) {
      case EmergencyType.fire: return AppColors.primary;
      case EmergencyType.medical: return Colors.blue.shade700;
      case EmergencyType.crime: return Colors.purple.shade700;
      case EmergencyType.accident: return Colors.orange.shade700;
    }
  }

  IconData _typeIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.fire: return Icons.local_fire_department;
      case EmergencyType.medical: return Icons.medical_services;
      case EmergencyType.crime: return Icons.security;
      case EmergencyType.accident: return Icons.car_crash;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResponderController>(
      builder: (context, controller, _) {
        final current = controller.emergencies.firstWhere(
          (e) => e.id == emergency.id,
          orElse: () => emergency,
        );

        final typeColor = _typeColor(current.emergencyType);

        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ));

        return Scaffold(
          backgroundColor: Colors.white,
          // ── Clean AppBar — no overlap, no double title ──
          appBar: AppBar(
            backgroundColor: typeColor,
            surfaceTintColor: typeColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                ));
                Navigator.pop(context);
              },
            ),
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_typeIcon(current.emergencyType), color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  '${current.emergencyType.label} Emergency',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  current.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMapPlaceholder(current, typeColor),
                const SizedBox(height: 16),
                _buildStatusProgress(current),
                const SizedBox(height: 16),
                _buildInfoCard(current, typeColor),
                const SizedBox(height: 16),
                _buildReporterCard(current),
                const SizedBox(height: 16),
                _buildActionButtons(context, controller, current, typeColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapPlaceholder(EmergencyModel e, Color typeColor) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: _MapGridPainter()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 42, color: typeColor),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Incident Location',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: typeColor),
                      ),
                      Text(
                        'Lat: ${e.latitude.toStringAsFixed(4)}, Lng: ${e.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_pin_circle, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('You: Station 3', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('🗺 Map Placeholder', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusProgress(EmergencyModel e) {
    final steps = [
      {'status': EmergencyStatus.dispatched, 'label': 'Dispatched', 'icon': Icons.radio_button_checked},
      {'status': EmergencyStatus.onTheWay, 'label': 'On The Way', 'icon': Icons.directions_car},
      {'status': EmergencyStatus.arrived, 'label': 'Arrived', 'icon': Icons.location_on},
      {'status': EmergencyStatus.resolved, 'label': 'Resolved', 'icon': Icons.check_circle},
    ];

    final currentIndex = EmergencyStatus.values.indexOf(e.status);

    Color nodeColor0(EmergencyStatus s) {
      switch (s) {
        case EmergencyStatus.dispatched: return AppColors.dispatched;
        case EmergencyStatus.onTheWay: return AppColors.onTheWay;
        case EmergencyStatus.arrived: return AppColors.arrived;
        case EmergencyStatus.resolved: return AppColors.resolved;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Response Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (i) {
              final step = steps[i];
              final status = step['status'] as EmergencyStatus;
              final icon = step['icon'] as IconData;
              final label = step['label'] as String;
              final isDone = i <= currentIndex;
              final isCurrent = i == currentIndex;
              final nodeColor = nodeColor0(status);

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isCurrent ? 38 : 32,
                            height: isCurrent ? 38 : 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone ? nodeColor : Colors.grey.shade100,
                              border: Border.all(
                                color: isDone ? nodeColor : Colors.grey.shade200,
                                width: isCurrent ? 2 : 1,
                              ),
                              boxShadow: isCurrent
                                  ? [BoxShadow(color: nodeColor.withOpacity(0.35), blurRadius: 10, spreadRadius: 2)]
                                  : null,
                            ),
                            child: Icon(icon, size: 16, color: isDone ? Colors.white : Colors.grey.shade400),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: isDone ? nodeColor : Colors.grey.shade400,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        height: 2,
                        width: 14,
                        color: i < currentIndex ? nodeColor0(steps[i]['status'] as EmergencyStatus) : Colors.grey.shade200,
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(EmergencyModel e, Color typeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Incident Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            StatusBadge(status: e.status),
          ]),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: typeColor.withOpacity(0.12)),
            ),
            child: Text(e.description, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 12),
          InfoTile(icon: Icons.location_on, label: 'Address', value: e.address, iconColor: typeColor),
          InfoTile(icon: Icons.near_me, label: 'Distance from Station', value: e.distance, iconColor: Colors.blue),
          InfoTile(icon: Icons.access_time, label: 'Reported At', value: DateFormat('MMM dd, yyyy – hh:mm a').format(e.time), iconColor: Colors.grey),
          InfoTile(icon: Icons.business, label: 'Assigned Agency', value: e.assignedAgency, iconColor: typeColor),
        ],
      ),
    );
  }

  Widget _buildReporterCard(EmergencyModel e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reporter Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 8),
          InfoTile(icon: Icons.person, label: 'Reported By', value: e.reporterName, iconColor: Colors.teal),
          InfoTile(
            icon: Icons.gps_fixed,
            label: 'GPS Coordinates',
            value: '${e.latitude.toStringAsFixed(4)}, ${e.longitude.toStringAsFixed(4)}',
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ResponderController controller, EmergencyModel e, Color typeColor) {
    if (e.status == EmergencyStatus.resolved) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.25)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 26),
            SizedBox(width: 10),
            Text('Emergency Resolved', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Response Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          if (e.status == EmergencyStatus.dispatched)
            CustomButton(
              label: 'Accept & En Route',
              icon: Icons.directions_car,
              color: AppColors.onTheWay,
              onPressed: () {
                controller.acceptEmergency(e.id);
                _snack(context, 'Status updated: On The Way', AppColors.onTheWay);
              },
            ),
          if (e.status == EmergencyStatus.onTheWay)
            CustomButton(
              label: 'Mark Arrived On Scene',
              icon: Icons.location_on,
              color: AppColors.arrived,
              onPressed: () {
                controller.markArrived(e.id);
                _snack(context, 'Status updated: Arrived', AppColors.arrived);
              },
            ),
          if (e.status == EmergencyStatus.arrived)
            CustomButton(
              label: 'Mark as Resolved',
              icon: Icons.check_circle,
              color: const Color(0xFF2E7D32),
              onPressed: () => _confirmResolve(context, controller, e),
            ),
          const SizedBox(height: 10),
          CustomButton(
            label: 'Call Dispatch',
            icon: Icons.headset_mic_outlined,
            outlined: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _confirmResolve(BuildContext context, ResponderController controller, EmergencyModel e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark as Resolved?'),
        content: const Text('Confirm that the emergency has been handled and situation is under control.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.markResolved(e.id);
              _snack(context, 'Emergency Resolved ✓', const Color(0xFF2E7D32));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade300..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final road = Paint()..color = Colors.white..strokeWidth = 7..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), road);
    canvas.drawLine(Offset(size.width * 0.38, 0), Offset(size.width * 0.38, size.height), road);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height * 0.45), road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
