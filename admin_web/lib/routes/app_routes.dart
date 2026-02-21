import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/admin/screens/dashboard_screen.dart';
import '../core/constants/app_constants.dart';
import '../core/services/auth_service.dart';

part 'app_pages.dart';

class AppRoutes {
  AppRoutes._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppConstants.routeLogin,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppConstants.routeDashboard,
      page: () => const DashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

/// Redirects unauthenticated access to the login screen.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final authService = Get.find<AuthService>();
    final isAdmin = await authService.isLoggedInAsAdmin();

    if (!isAdmin && route.currentTreeBranch.last.name != AppConstants.routeLogin) {
      return GetNavConfig.fromRoute(AppConstants.routeLogin);
    }
    return await super.redirectDelegate(route);
  }
}
