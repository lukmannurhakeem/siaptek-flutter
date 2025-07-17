import 'package:base_app/core/theme/app_color.dart';
import 'package:base_app/core/theme/app_spacing.dart';
import 'package:base_app/core/theme/app_topology.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const AppColors _lightColors = AppColors.light();
  static const AppColors _darkColors = AppColors.dark();
  static const AppSpacing _spacing = AppSpacing();
  static final AppTopology _typography = AppTopology.create();

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: _lightColors.primary,
        onPrimary: _lightColors.onPrimary,
        secondary: _lightColors.secondary,
        onSecondary: _lightColors.onSecondary,
        surface: _lightColors.surface,
        onSurface: _lightColors.onSurface,
        background: _lightColors.background,
        onBackground: _lightColors.onBackground,
        error: _lightColors.error,
        onError: _lightColors.onError,
      ),

      // Typography
      textTheme: _typography.textTheme.apply(
        bodyColor: _lightColors.onBackground,
        displayColor: _lightColors.onBackground,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightColors.surface,
        foregroundColor: _lightColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _typography.textTheme.titleLarge?.copyWith(
          color: _lightColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        // systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: _lightColors.surface,
        elevation: 2,
        margin: _spacing.paddingM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightColors.primary,
          foregroundColor: _lightColors.onPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: _spacing.l,
            vertical: _spacing.m,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: _typography.textTheme.labelLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _lightColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _lightColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _lightColors.primary, width: 2),
        ),
        contentPadding: _spacing.paddingM,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: _lightColors.divider,
        thickness: 1,
        space: _spacing.m,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: _darkColors.primary,
        onPrimary: _darkColors.onPrimary,
        secondary: _darkColors.secondary,
        onSecondary: _darkColors.onSecondary,
        surface: _darkColors.surface,
        onSurface: _darkColors.onSurface,
        background: _darkColors.background,
        onBackground: _darkColors.onBackground,
        error: _darkColors.error,
        onError: _darkColors.onError,
      ),

      // Typography
      textTheme: _typography.textTheme.apply(
        bodyColor: _darkColors.onBackground,
        displayColor: _darkColors.onBackground,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkColors.surface,
        foregroundColor: _darkColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _typography.textTheme.titleLarge?.copyWith(
          color: _darkColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        // systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: _darkColors.surface,
        elevation: 2,
        margin: _spacing.paddingM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkColors.primary,
          foregroundColor: _darkColors.onPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: _spacing.l,
            vertical: _spacing.m,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: _typography.textTheme.labelLarge,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _darkColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _darkColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _darkColors.primary, width: 2),
        ),
        contentPadding: _spacing.paddingM,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: _darkColors.divider,
        thickness: 1,
        space: _spacing.m,
      ),
    );
  }
}
