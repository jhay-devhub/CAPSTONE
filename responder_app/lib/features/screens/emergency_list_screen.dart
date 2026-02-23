// features/screens/emergency_list_screen.dart
// LB-Sentry | Emergency Reports List - Filtered by BFP

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_theme.dart';
import '../controllers/responder_controller.dart';
import '../models/emergency_model.dart';
import '../widgets/emergency_card.dart';
import '../../routes/app_routes.dart';

enum _FilterTab { all, active, resolved }

class EmergencyListScreen extends StatefulWidget {
  const EmergencyListScreen({super.key});

  @override
  State<EmergencyListScreen> createState() => _EmergencyListScreenState();
}

class _EmergencyListScreenState extends State<EmergencyListScreen> {
  _FilterTab _currentTab = _FilterTab.active;
  EmergencyType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<ResponderController>(
      builder: (context, controller, _) {
        final allBfp = controller.myAgencyEmergencies;
        final displayed = _getDisplayed(allBfp);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Emergency Reports'),
                Text(
                  'Agency: ${controller.responder.agency}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<EmergencyType?>(
                icon: Badge(
                  isLabelVisible: _typeFilter != null,
                  backgroundColor: Colors.amber,
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
                onSelected: (type) => setState(() => _typeFilter = type),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: null, child: Text('All Types')),
                  const PopupMenuItem(value: EmergencyType.fire, child: Text('🔥 Fire')),
                  const PopupMenuItem(value: EmergencyType.medical, child: Text('🏥 Medical')),
                  const PopupMenuItem(value: EmergencyType.crime, child: Text('🚔 Crime')),
                  const PopupMenuItem(value: EmergencyType.accident, child: Text('🚗 Accident')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Tab bar ──
              Container(
                color: AppColors.primary,
                child: Row(
                  children: [
                    _TabBtn(
                      label: 'Active (${controller.activeCount})',
                      isActive: _currentTab == _FilterTab.active,
                      onTap: () => setState(() => _currentTab = _FilterTab.active),
                    ),
                    _TabBtn(
                      label: 'All (${allBfp.length})',
                      isActive: _currentTab == _FilterTab.all,
                      onTap: () => setState(() => _currentTab = _FilterTab.all),
                    ),
                    _TabBtn(
                      label: 'Resolved (${controller.resolvedEmergencies.length})',
                      isActive: _currentTab == _FilterTab.resolved,
                      onTap: () => setState(() => _currentTab = _FilterTab.resolved),
                    ),
                  ],
                ),
              ),

              // ── Type filter chips ──
              if (_typeFilter != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Wrap(
                    children: [
                      Chip(
                        label: Text('Filtered: ${_typeFilter!.label}'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _typeFilter = null),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── List ──
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : displayed.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: controller.refreshData,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: displayed.length,
                              itemBuilder: (context, index) {
                                final emergency = displayed[index];
                                return EmergencyCard(
                                  emergency: emergency,
                                  onTap: () {
                                    controller.selectEmergency(emergency);
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.emergencyDetail,
                                      arguments: emergency,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<EmergencyModel> _getDisplayed(List<EmergencyModel> all) {
    List<EmergencyModel> list;
    switch (_currentTab) {
      case _FilterTab.active:
        list = all.where((e) => e.status != EmergencyStatus.resolved).toList();
        break;
      case _FilterTab.resolved:
        list = all.where((e) => e.status == EmergencyStatus.resolved).toList();
        break;
      case _FilterTab.all:
        list = all;
    }
    if (_typeFilter != null) {
      list = list.where((e) => e.emergencyType == _typeFilter).toList();
    }
    return list;
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No emergencies found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pull to refresh',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabBtn({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
