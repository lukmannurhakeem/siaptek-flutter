import 'package:flutter/material.dart';

class AppSpacing {
  final double xxs;
  final double xs;
  final double s;
  final double m;
  final double l;
  final double xl;
  final double xxl;

  const AppSpacing({
    this.xxs = 2.0,
    this.xs = 4.0,
    this.s = 8.0,
    this.m = 16.0,
    this.l = 24.0,
    this.xl = 32.0,
    this.xxl = 48.0,
  });

  // Existing padding/margin helpers
  EdgeInsets get paddingXs => EdgeInsets.all(xs);
  EdgeInsets get paddingS => EdgeInsets.all(s);
  EdgeInsets get paddingM => EdgeInsets.all(m);
  EdgeInsets get paddingL => EdgeInsets.all(l);

  EdgeInsets get horizontalS => EdgeInsets.symmetric(horizontal: s);
  EdgeInsets get horizontalM => EdgeInsets.symmetric(horizontal: m);
  EdgeInsets get horizontalL => EdgeInsets.symmetric(horizontal: l);

  EdgeInsets get verticalS => EdgeInsets.symmetric(vertical: s);
  EdgeInsets get verticalM => EdgeInsets.symmetric(vertical: m);
  EdgeInsets get verticalL => EdgeInsets.symmetric(vertical: l);

  // SizedBox helpers for vertical spacing
  SizedBox get vXxs => SizedBox(height: xxs);
  SizedBox get vXs => SizedBox(height: xs);
  SizedBox get vS => SizedBox(height: s);
  SizedBox get vM => SizedBox(height: m);
  SizedBox get vL => SizedBox(height: l);
  SizedBox get vXl => SizedBox(height: xl);
  SizedBox get vXxl => SizedBox(height: xxl);

  // SizedBox helpers for horizontal spacing
  SizedBox get hXxs => SizedBox(width: xxs);
  SizedBox get hXs => SizedBox(width: xs);
  SizedBox get hS => SizedBox(width: s);
  SizedBox get hM => SizedBox(width: m);
  SizedBox get hL => SizedBox(width: l);
  SizedBox get hXl => SizedBox(width: xl);
  SizedBox get hXxl => SizedBox(width: xxl);

  // Custom SizedBox methods
  SizedBox vertical(double height) => SizedBox(height: height);
  SizedBox horizontal(double width) => SizedBox(width: width);
  SizedBox square(double size) => SizedBox(width: size, height: size);
}
