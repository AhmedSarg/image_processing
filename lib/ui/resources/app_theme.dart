import 'package:flutter/material.dart';

import 'app_colors.dart';

class ThemeManager {
  static ThemeData get lightTheme => ThemeData(
        colorScheme: const LightColors(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.normal,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: AppColors.lightOnPrimary,
          ),
        ),
      );
  static ThemeData get darkTheme => ThemeData(
        colorScheme: const DarkColors(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.normal,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: AppColors.darkOnPrimary,
          ),
        ),
      );
}
