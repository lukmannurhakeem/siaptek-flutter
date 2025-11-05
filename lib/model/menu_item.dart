import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final int index;
  final Widget? screen;
  final Widget Function()? builder;
  final List<MenuItem>? children;

  MenuItem({
    required this.title,
    required this.icon,
    required this.index,
    this.screen,
    this.builder,
    this.children,
  });
}
