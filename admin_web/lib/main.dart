import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/config/firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/services/auth_service.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register core services — permanent so they persist for the app's lifetime.
  final authService = Get.put<AuthService>(AuthService(), permanent: true);

  // Check if Firebase already has a valid admin session persisted in the
  // browser (localStorage). If yes, skip the login screen entirely.
  final alreadyLoggedIn = await authService.isLoggedInAsAdmin();
  final startRoute =
      alreadyLoggedIn ? AppConstants.routeDashboard : AppConstants.routeLogin;

  runApp(AdminApp(initialRoute: startRoute));
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A5F),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: initialRoute,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
