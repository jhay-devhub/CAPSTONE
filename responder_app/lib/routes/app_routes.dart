// routes/app_routes.dart
// LB-Sentry | Navigation Routes

import 'package:flutter/material.dart';
import '../features/screens/dashboard_screen.dart';
import '../features/screens/emergency_list_screen.dart';
import '../features/screens/emergency_detail_screen.dart';
import '../features/screens/history_screen.dart';
import '../features/models/emergency_model.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String emergencyList = '/emergency-list';
  static const String emergencyDetail = '/emergency-detail';
  static const String history = '/history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case emergencyList:
        return MaterialPageRoute(builder: (_) => const EmergencyListScreen());
      case emergencyDetail:
        final emergency = settings.arguments as EmergencyModel;
        return MaterialPageRoute(
          builder: (_) => EmergencyDetailScreen(emergency: emergency),
        );
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      default:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
    }
  }
}
