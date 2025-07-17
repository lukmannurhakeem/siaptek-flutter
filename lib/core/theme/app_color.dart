import 'package:flutter/material.dart';

class AppColors {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color error;
  final Color onError;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color divider;

  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.error,
    required this.onError,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.divider,
  });

  // Named constructors for light and dark themes
  const AppColors.light()
      : primary = const Color(0xFF312783),
        onPrimary = const Color(0xFFFFFFFF),
        secondary = const Color(0xFF9E99C5),
        onSecondary = const Color(0xFFFFFFFF),
        background = const Color(0xFFEFE4D2),
        onBackground = const Color(0xFFEFE4D2),
        surface = Colors.white,
        onSurface = Colors.black,
        error = const Color(0xFFB00020),
        onError = Colors.white,
        success = const Color(0xFF4CAF50),
        onSuccess = Colors.white,
        warning = const Color(0xFFFFC107),
        onWarning = Colors.black,
        info = const Color(0xFF2196F3),
        onInfo = Colors.white,
        divider = Colors.grey;

  const AppColors.dark()
      : primary = const Color(0xFF312783),
        onPrimary = const Color(0xFF2C3639),
        secondary = const Color(0xFF9E99C5),
        onSecondary = const Color(0xFF2C3639),
        background = const Color(0xFF2C3639),
        onBackground = const Color(0xFF2C3639),
        surface = const Color(0xFF1E1E1E),
        onSurface = Colors.white,
        error = const Color(0xFFB00020),
        onError = Colors.black,
        success = const Color(0xFF81C784), // Lighter green for dark theme
        onSuccess = Colors.black,
        warning = const Color(0xFFFFD54F), // Lighter yellow for dark theme
        onWarning = Colors.black,
        info = const Color(0xFF64B5F6), // Lighter blue for dark theme
        onInfo = Colors.black,
        divider = Colors.grey;

  // ==================== STATIC INSTANCES ====================

  static const AppColors lightTheme = AppColors.light();
  static const AppColors darkTheme = AppColors.dark();

  // ==================== COMMON COLORS ====================

  // Neutral colors
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Grey scale
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ==================== HELPER METHODS ====================

  /// Get the appropriate color scheme based on brightness
  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? lightTheme : darkTheme;
  }

  /// Get color based on current brightness
  static Color adaptive(Brightness brightness, Color lightColor, Color darkColor) {
    return brightness == Brightness.light ? lightColor : darkColor;
  }

  /// Get primary color based on brightness
  static Color primaryFor(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme.primary : darkTheme.primary;
  }

  /// Get surface color based on brightness
  static Color surfaceFor(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme.surface : darkTheme.surface;
  }

  /// Get background color based on brightness
  static Color backgroundFor(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme.background : darkTheme.background;
  }

  /// Convert this color scheme to a Flutter ColorScheme
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: brightness == Brightness.light ? grey100 : grey800,
      onSurfaceVariant: brightness == Brightness.light ? grey700 : grey300,
      outline: divider,
    );
  }

  // ==================== EXTENSION COLORS ====================

  /// Additional colors that don't fit into Material Design's ColorScheme
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF81C784);
  static const Color warningLight = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFFFFD54F);
  static const Color infoLight = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF64B5F6);

  /// Get success color for brightness
  static Color successFor(Brightness brightness) {
    return brightness == Brightness.light ? successLight : successDark;
  }

  /// Get warning color for brightness
  static Color warningFor(Brightness brightness) {
    return brightness == Brightness.light ? warningLight : warningDark;
  }

  /// Get info color for brightness
  static Color infoFor(Brightness brightness) {
    return brightness == Brightness.light ? infoLight : infoDark;
  }
}
