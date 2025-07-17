// Create a data class for menu items
import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final int index;
  final Widget? screen;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.index,
    this.screen,
  });
}
