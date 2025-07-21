import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final int index;
  final Widget? screen;
  final List<MenuItem>? children;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.index,
    this.screen,
    this.children,
  });
}
