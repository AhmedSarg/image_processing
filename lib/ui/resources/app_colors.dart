import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF6200EE); // Purple 500
  static const Color lightOnPrimary = Color(0xFFFFFFFF); // White
  static const Color lightSecondary = Color(0xFF03DAC6); // Teal 200
  static const Color lightOnSecondary = Color(0xFF000000); // Black
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightOnSurface = Color(0xFF000000); // Black
  static const Color lightError = Color(0xFFB00020); // Red 800
  static const Color lightOnError = Color(0xFFFFFFFF); // White
  // static const Color lightPrimaryVariant = Color(0xFF3700B3); // Purple 700

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFFBB86FC); // Purple 200
  static const Color darkOnPrimary = Color(0xFF000000); // Black
  static const Color darkSecondary = Color(0xFF03DAC6); // Teal 200
  static const Color darkOnSecondary = Color(0xFF000000); // Black
  static const Color darkSurface = Color(0xFF121212); // Black
  static const Color darkOnSurface = Color(0xFFFFFFFF); // White
  static const Color darkError = Color(0xFFCF6679); // Red 400
  static const Color darkOnError = Color(0xFF000000);
}

class LightColors extends ColorScheme {
  const LightColors({
    super.brightness = Brightness.light,
    super.primary = AppColors.lightPrimary,
    super.onPrimary = AppColors.lightOnPrimary,
    super.secondary = AppColors.lightSecondary,
    super.onSecondary = AppColors.lightOnSecondary,
    super.error = AppColors.lightError,
    super.onError = AppColors.lightOnError,
    super.surface = AppColors.lightSurface,
    super.onSurface = AppColors.lightOnSurface,
    super.background = AppColors.lightSurface,
    super.onBackground = AppColors.lightOnSurface,
  });
}

class DarkColors extends ColorScheme {
  const DarkColors({
    super.brightness = Brightness.dark,
    super.primary = AppColors.darkPrimary,
    super.onPrimary = AppColors.darkOnPrimary,
    super.secondary = AppColors.darkSecondary,
    super.onSecondary = AppColors.darkOnSecondary,
    super.error = AppColors.darkError,
    super.onError = AppColors.darkOnError,
    super.surface = AppColors.darkSurface,
    super.onSurface = AppColors.darkOnSurface,
    super.background = AppColors.darkSurface,
    super.onBackground = AppColors.darkOnSurface,
  });
}
