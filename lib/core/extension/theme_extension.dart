import 'package:INSPECT/core/theme/app_color.dart';
import 'package:INSPECT/core/theme/app_spacing.dart';
import 'package:INSPECT/core/theme/app_topology.dart';
import 'package:INSPECT/widget/common_loading.dart';
import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  AppColors get colors =>
      Theme.of(this).brightness == Brightness.light
          ? const AppColors.light()
          : const AppColors.dark();

  AppSpacing get spacing => const AppSpacing();

  AppTopology get topology => AppTopology.create();

  // SizedBox spacing helpers - Vertical
  SizedBox get vXxs => SizedBox(height: spacing.xxs);

  SizedBox get vXs => SizedBox(height: spacing.xs);

  SizedBox get vS => SizedBox(height: spacing.s);

  SizedBox get vM => SizedBox(height: spacing.m);

  SizedBox get vL => SizedBox(height: spacing.l);

  SizedBox get vXl => SizedBox(height: spacing.xl);

  SizedBox get vXxl => SizedBox(height: spacing.xxl);

  // SizedBox spacing helpers - Horizontal
  SizedBox get hXxs => SizedBox(width: spacing.xxs);

  SizedBox get hXs => SizedBox(width: spacing.xs);

  SizedBox get hS => SizedBox(width: spacing.s);

  SizedBox get hM => SizedBox(width: spacing.m);

  SizedBox get hL => SizedBox(width: spacing.l);

  SizedBox get hXl => SizedBox(width: spacing.xl);

  SizedBox get hXxl => SizedBox(width: spacing.xxl);

  // Custom spacing methods
  SizedBox vSpace(double height) => SizedBox(height: height);

  SizedBox hSpace(double width) => SizedBox(width: width);

  SizedBox squareSpace(double size) => SizedBox(width: size, height: size);

  // Common UI helpers using your theme system
  Widget get divider =>
      Divider(height: spacing.xs, thickness: 1, color: colors.divider.withOpacity(0.5));

  Widget get loadingIndicator => CommonLoading();

  // Common padding helpers
  EdgeInsets get paddingAll => spacing.paddingL;

  EdgeInsets get paddingHorizontal => spacing.horizontalM;

  EdgeInsets get paddingVertical => spacing.verticalM;

  // Screen size helpers
  Size get screenSize => MediaQuery.of(this).size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isTablet => screenWidth > 600;

  bool get isMobile => screenWidth <= 600;

  // Safe area helpers
  EdgeInsets get safeArea => MediaQuery.of(this).padding;

  double get statusBarHeight => safeArea.top;

  double get bottomBarHeight => safeArea.bottom;
}
