// features/screens/dashboard_screen.dart
// LB-Sentry | Dashboard — Clean White UI

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../controllers/responder_controller.dart';
import '../models/responder_model.dart';
import '../models/emergency_model.dart';
import '../widgets/emergency_card.dart';
import '../widgets/assignment_alert_dialog.dart';
import '../../routes/app_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<ResponderController>().triggerIncomingEmergency();
      }
    });
  }

  void _showAlert(ResponderController controller) {
    if (_dialogShown) return;
    _dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogCtx) => ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<ResponderController>(
          builder: (_, ctrl, __) {
            if (!ctrl.isDialogVisible) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(dialogCtx).canPop()) {
                  Navigator.of(dialogCtx).pop();
                }
              });
            }
            return const AssignmentAlertDialog();
          },
        ),
      ),
    ).then((_) => _dialogShown = false);
  }

  @override
  Widget build(BuildContext context) {
    // Force white status bar icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Consumer<ResponderController>(
      builder: (context, controller, _) {
        if (controller.isDialogVisible && !_dialogShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _showAlert(controller));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          // ── Simple fixed AppBar (no sliver, no overlap issues) ──
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: Colors.black12,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shield, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LB-SENTRY',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Responder Dashboard',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Notification bell
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700, size: 24),
                    onPressed: () {},
                  ),
                  if (controller.activeCount > 0)
                    Positioned(
                      right: 8,
                      top: 10,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${controller.activeCount}',
                            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.history_rounded, color: Colors.grey.shade700, size: 24),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: Colors.grey.shade100),
            ),
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResponderCard(controller),
                  const SizedBox(height: 16),
                  _buildStatsRow(controller),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Active Emergencies', controller.activeCount),
                  const SizedBox(height: 10),
                  _buildActiveList(context, controller),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => controller.triggerIncomingEmergency(),
            backgroundColor: AppColors.primary,
            elevation: 4,
            icon: const Icon(Icons.add_alert, color: Colors.white),
            label: const Text(
              'Simulate Alert',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // ─── RESPONDER CARD ──────────────────────────────────────────────────────────
  Widget _buildResponderCard(ResponderController controller) {
    final r = controller.responder;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  r.name.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(r.rank, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                    Text(r.unit, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: Text(
                  r.agency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'My Status:',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
              const SizedBox(width: 12),
              _StatusChip(
                label: 'Available',
                isSelected: r.status == ResponderStatus.available,
                activeColor: const Color(0xFF2E7D32),
                onTap: () => controller.setResponderStatus(ResponderStatus.available),
              ),
              const SizedBox(width: 6),
              _StatusChip(
                label: 'Busy',
                isSelected: r.status == ResponderStatus.busy,
                activeColor: const Color(0xFFE65100),
                onTap: () => controller.setResponderStatus(ResponderStatus.busy),
              ),
              const SizedBox(width: 6),
              _StatusChip(
                label: 'Offline',
                isSelected: r.status == ResponderStatus.offline,
                activeColor: Colors.grey.shade600,
                onTap: () => controller.setResponderStatus(ResponderStatus.offline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STATS ROW ───────────────────────────────────────────────────────────────
  Widget _buildStatsRow(ResponderController controller) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.warning_amber_rounded,
            label: 'Active',
            value: '${controller.activeCount}',
            color: AppColors.dispatched,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline_rounded,
            label: 'Completed',
            value: '${controller.completedTodayCount}',
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            label: 'Avg Time',
            value: controller.avgResponseTime,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  // ─── SECTION HEADER ──────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ─── ACTIVE LIST ─────────────────────────────────────────────────────────────
  Widget _buildActiveList(BuildContext context, ResponderController controller) {
    final active = controller.myAgencyEmergencies
        .where((e) => e.status != EmergencyStatus.resolved)
        .toList();

    if (active.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_rounded, size: 44, color: Color(0xFF2E7D32)),
              SizedBox(height: 10),
              Text(
                'All clear',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              Text(
                'No active emergencies right now',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: active
          .map((e) => EmergencyCard(
                emergency: e,
                onTap: () {
                  controller.selectEmergency(e);
                  Navigator.pushNamed(context, AppRoutes.emergencyDetail, arguments: e);
                },
              ))
          .toList(),
    );
  }

  // ─── QUICK ACTIONS ───────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.list_alt_rounded,
                label: 'All Reports',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.emergencyList),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.history_rounded,
                label: 'History',
                color: Colors.grey.shade700,
                onTap: () => Navigator.pushNamed(context, AppRoutes.history),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.map_outlined,
                label: 'Map View',
                color: Colors.blue.shade700,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.headset_mic_outlined,
                label: 'Dispatch',
                color: Colors.teal.shade700,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── LOCAL WIDGETS ────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white.withOpacity(0.35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
