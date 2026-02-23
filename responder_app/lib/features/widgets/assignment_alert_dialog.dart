// features/widgets/assignment_alert_dialog.dart
// LB-Sentry | Incoming Emergency Assignment Modal

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../controllers/responder_controller.dart';
import '../models/emergency_model.dart';
import 'countdown_timer_widget.dart';

class AssignmentAlertDialog extends StatelessWidget {
  const AssignmentAlertDialog({super.key});

  IconData _typeIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.fire: return Icons.local_fire_department;
      case EmergencyType.medical: return Icons.medical_services;
      case EmergencyType.crime: return Icons.security;
      case EmergencyType.accident: return Icons.car_crash;
    }
  }

  Color _typeColor(EmergencyType type) {
    switch (type) {
      case EmergencyType.fire: return AppColors.primary;
      case EmergencyType.medical: return Colors.blue.shade700;
      case EmergencyType.crime: return Colors.purple.shade700;
      case EmergencyType.accident: return Colors.orange.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResponderController>(
      builder: (context, controller, _) {
        if (!controller.isDialogVisible || controller.incomingEmergency == null) {
          return const SizedBox.shrink();
        }

        final emergency = controller.incomingEmergency!;
        final typeColor = _typeColor(emergency.emergencyType);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
            );
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Pulsing icon
                        _PulsingIcon(icon: _typeIcon(emergency.emergencyType)),
                        const SizedBox(height: 10),
                        const Text(
                          '🚨 NEW EMERGENCY ASSIGNED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          emergency.emergencyType.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ──
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Timer + info row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CountdownTimerWidget(seconds: controller.timerSeconds),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    icon: Icons.location_on,
                                    label: 'Location',
                                    value: emergency.address,
                                    color: typeColor,
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.near_me,
                                    label: 'Distance',
                                    value: emergency.distance,
                                    color: typeColor,
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.business,
                                    label: 'Agency',
                                    value: emergency.assignedAgency,
                                    color: typeColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Description
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: typeColor.withOpacity(0.15)),
                          ),
                          child: Text(
                            emergency.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Timer warning
                        if (controller.timerSeconds <= 15) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber, size: 14, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text(
                                  'Auto-declining soon!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Buttons ──
                        Row(
                          children: [
                            // Reject
                            Expanded(
                              child: _DialogButton(
                                label: 'Reject',
                                icon: Icons.cancel_outlined,
                                isLoading: controller.isRejecting,
                                isDisabled: controller.isAccepting,
                                outlined: true,
                                onPressed: () {
                                  controller.rejectAssignment();
                                  _showSnack(context, 'Emergency Rejected', Colors.grey.shade700);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Accept
                            Expanded(
                              flex: 2,
                              child: _DialogButton(
                                label: 'Accept',
                                icon: Icons.check_circle,
                                isLoading: controller.isAccepting,
                                isDisabled: controller.isRejecting,
                                color: typeColor,
                                onPressed: () {
                                  _showSnack(context, 'Emergency Accepted — En Route!', typeColor);
                                  controller.acceptAssignment(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── LOCAL SUB-WIDGETS ────────────────────────────────────────────────────────

class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  const _PulsingIcon({required this.icon});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(widget.icon, color: Colors.white, size: 32),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool outlined;
  final Color? color;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.outlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;
    final isInactive = isLoading || isDisabled;

    if (outlined) {
      return SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: isInactive ? null : onPressed,
          icon: isLoading
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(icon, size: 16),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isInactive ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          elevation: 2,
        ),
      ),
    );
  }
}
