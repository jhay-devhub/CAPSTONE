import 'package:flutter/material.dart';

/// Central color palette for the user app.
/// Change values here to update the entire UI consistently.
abstract final class AppColors {
  // Primary brand color – emergency red
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFF9A0007);
  static const Color primaryLight = Color(0xFFFF6659);

  // Accent
  static const Color accent = Color(0xFF1565C0);

  // Backgrounds
  static const Color scaffold = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);

  // Bottom navigation
  static const Color navSelected = primary;
  static const Color navUnselected = Color(0xFF9E9E9E);

  // HELP button
  static const Color helpButton = primary;
  static const Color helpButtonShadow = Color(0x80D32F2F);

  // Dividers / borders
  static const Color divider = Color(0xFFE0E0E0);
}
