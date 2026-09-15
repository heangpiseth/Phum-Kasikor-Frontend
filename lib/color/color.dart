import 'package:flutter/material.dart';

/// Central palette for Phum Kasikor. Import this file instead of placing
/// hard-coded color values directly in screens and widgets.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF237D32);
  static const primaryDark = Color(0xFF165B23);
  static const primaryLight = Color(0xFFE9F6EA);
  static const secondary = Color(0xFFF4B942);
  static const secondaryLight = Color(0xFFFFF5D7);
  static const creamLight = Color(0xFFFFF2C5);

  // Surfaces
  static const background = Color(0xFFFCFDF9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F5F1);
  static const border = Color(0xFFE0E8E0);
  static const borderStrong = Color(0xFFCBD7CC);

  // Text
  static const textPrimary = Color(0xFF1E2B20);
  static const textSecondary = Color(0xFF718074);
  static const textHint = Color(0xFF9BA69D);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textGrey = Color(0xFF718074);
  static const textDark = Color(0xFF1E2B20);
  static const danger = Color(0xFFD94343);
  static const star = Color(0xFFF4B942);

  // Status
  static const success = Color(0xFF2E9B45);
  static const warning = Color(0xFFF4A62A);
  static const error = Color(0xFFD94343);
  static const info = Color(0xFF2787C8);

  // Feature accents
  static const mapBackground = Color(0xFFE0F3D5);
  static const mapRoad = Color(0xFF90C897);
  static const aquaLight = Color(0xFFC8F1F5);
  static const Color accentOrange = Color(0xFFEF6C00); // "seasonal pick" tag

  static const Color divider = Color(0xFFE0E0E0);
}

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.textHint),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
  );
}
