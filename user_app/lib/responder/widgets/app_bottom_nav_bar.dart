import 'package:flutter/material.dart';
import '../constants/app_strings.dart';

/// Reusable bottom navigation bar used across the main shell.
/// Drives tab switching without managing state itself.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: AppStrings.navHome,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavItem(
      label: AppStrings.navRescue,
      icon: Icons.location_on_outlined,
      activeIcon: Icons.location_on,
    ),
    _NavItem(
      label: AppStrings.navSafetyTips,
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield,
    ),
    _NavItem(
      label: AppStrings.navProfile,
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
      items: _navItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.label,
            ),
          )
          .toList(growable: false),
    );
  }
}

/// Private data class for each bottom nav item.
/// No logic – purely holds display values.
@immutable
class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
