// core/config/app_theme.dart
// LB-Sentry | Theme Configuration

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFF9A0007);
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color accent = Color(0xFFFF6D00);
  static const Color background = Color(0xFFFFFFFF); // White background
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color secondaryBg = Color(0xFFF5F5F5);

  // Status Colors
  static const Color dispatched = Color(0xFFD32F2F);
  static const Color onTheWay = Color(0xFFE65100);
  static const Color arrived = Color(0xFFF9A825);
  static const Color resolved = Color(0xFF2E7D32);

  // Agency colors
  static const Color bfpRed = Color(0xFFD32F2F);
  static const Color pnpBlue = Color(0xFF1565C0);
  static const Color mdrrmoGreen = Color(0xFF2E7D32);

  // Neutral
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color divider = Color(0xFFE0E0E0);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      useMaterial3: true, dialogTheme: DialogThemeData(backgroundColor: Colors.white),
    );
  }
}
