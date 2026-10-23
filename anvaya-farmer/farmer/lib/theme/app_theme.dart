import 'package:flutter/material.dart';

/// Centralized design tokens matching the Aegis / Anvaya reference UI.
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1B1D1C);
  static const Color cardDark = Color(0xFF131514);
  static const Color buttonDark = Color(0xFF141715);
  static const Color inputBackground = Color(0xFF222423);
  static const Color bottomNavBackground = Color(0xFF0B120E);

  // Accents - Exact Neon Green from Reference UI
  static const Color primaryGreen = Color(0xFF00E659); // Luminous tech green
  static const Color deepGreenGlow = Color(0xFF0A3319);
  static const Color borderGreen = Color(0x3300E659);
  static const Color inputBorder = Color(0xFF2E3230);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF7E8280);

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color divider = Color(0xFF2C2F2D);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
    );
  }
}
