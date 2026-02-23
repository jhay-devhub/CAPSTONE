import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../controllers/emergency_controller.dart';
import '../controllers/map_controller.dart';
import '../widgets/chat_panel.dart';
import '../widgets/emergency_list.dart';
import '../widgets/mapbox.dart';
import '../widgets/statcards.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    // Lazily register MapController so it lives for the lifetime of this route.
    final mapController = Get.put(MapController());
    final emergencyController = Get.put(EmergencyController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          Obx(() {
            final admin = authService.adminUser.value;
            if (admin == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      admin.name.isNotEmpty
                          ? admin.name[0].toUpperCase()
                          : admin.email[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    admin.name.isNotEmpty ? admin.name : admin.email,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authService.signOut();
              Get.offAllNamed(AppConstants.routeLogin);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StatCardsRow(),

            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmergencyListPanel(controller: emergencyController),

                  const SizedBox(width: 16),

                  Expanded(
                    child: MapboxMapWidget(controller: mapController),
                  ),

                  const SizedBox(width: 16),

                  EmergencyChatPanel(controller: emergencyController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


