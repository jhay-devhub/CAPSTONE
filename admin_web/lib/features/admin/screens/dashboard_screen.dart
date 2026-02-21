import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

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
    );
  }
}
