import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../rescue_tracking/rescue_tracking_screen.dart';
import '../safety_tips/safety_tips_screen.dart';
import '../profile/profile_screen.dart';

/// The root scaffold that houses the bottom navigation and all four tabs.
/// Each tab is kept alive via [IndexedStack] to preserve scroll / map state.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _activeTabIndex = AppTabIndex.home;

  static const List<Widget> _tabScreens = [
    HomeScreen(),
    RescueTrackingScreen(),
    SafetyTipsScreen(),
    ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    if (index == _activeTabIndex) return;
    setState(() => _activeTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _activeTabIndex,
        children: _tabScreens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _activeTabIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
