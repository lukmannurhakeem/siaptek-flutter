import 'package:flutter/material.dart';

/// A service class that manages navigation throughout a Flutter application.
/// It provides methods for navigation actions and maintains a global navigation key
/// that can be used for navigating without context.
class NavigationService {
  // Singleton instance
  static final NavigationService _instance = NavigationService._internal();

  // Factory constructor
  factory NavigationService() {
    return _instance;
  }

  // Internal constructor
  NavigationService._internal();

  // Global navigation key to use for navigation without context
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigation history
  final List<String> _navigationHistory = [];

  // Get current route name
  String? get currentRoute => _navigationHistory.isNotEmpty ? _navigationHistory.last : null;

  // Get navigation history
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);

  // Push a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    _navigationHistory.add(routeName);
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  // Replace the current route with a new one
  Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.removeLast();
    }
    _navigationHistory.add(routeName);
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  // Push a route and remove all previous routes
  Future<dynamic> navigateToAndRemoveUntil(String routeName, {Object? arguments}) {
    _navigationHistory.clear();
    _navigationHistory.add(routeName);
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  // Push a route and remove routes until a specific route
  Future<dynamic> navigateToAndRemoveUntilRoute(String routeName, String untilRouteName, {Object? arguments}) {
    // Remove history until the specified route
    while (_navigationHistory.isNotEmpty && _navigationHistory.last != untilRouteName) {
      _navigationHistory.removeLast();
    }
    _navigationHistory.add(routeName);
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      ModalRoute.withName(untilRouteName),
      arguments: arguments,
    );
  }

  // Go back to previous route
  void goBack() {
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.removeLast();
    }
    navigatorKey.currentState!.pop();
  }

  // Go back with result
  void goBackWithResult(dynamic result) {
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.removeLast();
    }
    navigatorKey.currentState!.pop(result);
  }

  // Check if can go back
  bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  // Go back to a specific route
  void goBackToRoute(String routeName) {
    // Remove history until the specified route
    while (_navigationHistory.isNotEmpty && _navigationHistory.last != routeName) {
      _navigationHistory.removeLast();
    }
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }
}