import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// A single settings row that supports both regular taps and toggle switches.
class SettingsTileWidget extends StatelessWidget {
  const SettingsTileWidget({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.toggleValue,
    this.onToggleChanged,
    this.isDestructive = false,
  })  : assert(
          (toggleValue == null) == (onToggleChanged == null),
          'Provide both toggleValue and onToggleChanged together, or neither.',
        );

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// When non-null, renders a [Switch] instead of a trailing arrow.
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  /// If true, the tile text and icon display in red (e.g. Log Out).
  final bool isDestructive;

  Color get _tileColor =>
      isDestructive ? AppColors.error : AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    final Widget trailing = toggleValue != null
        ? Switch(
            value: toggleValue!,
            onChanged: onToggleChanged,
            activeThumbColor: AppColors.primary,
          )
        : Icon(
            Icons.chevron_right,
            color: isDestructive ? AppColors.error : AppColors.navUnselected,
          );

    return ListTile(
      leading: Icon(icon, color: _tileColor),
      title: Text(
        label,
        style: TextStyle(
          color: _tileColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: toggleValue == null ? onTap : null,
    );
  }
}
