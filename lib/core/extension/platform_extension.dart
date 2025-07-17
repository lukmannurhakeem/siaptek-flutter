import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Extension on BuildContext for platform detection (Web-Safe)
extension PlatformExtension on BuildContext {
  // The key is to check kIsWeb FIRST before accessing Platform
  bool get isDesktop {
    if (kIsWeb) return false; // Web is not desktop
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  bool get isMobile {
    if (kIsWeb) return false; // Web is not mobile
    return Platform.isAndroid || Platform.isIOS;
  }

  bool get isWeb => kIsWeb;

  bool get isApple {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  bool get isGoogle {
    if (kIsWeb) return true; // Web runs on Google's browsers mostly
    return Platform.isAndroid;
  }

  bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Get platform-specific spacing
  double get platformSpacing => (isDesktop || isWeb) ? 16.0 : 8.0;

  /// Get platform-specific icon size
  double get platformIconSize => (isDesktop || isWeb) ? 24.0 : 20.0;

  /// Check if screen is large enough for desktop layout
  bool get isLargeScreen => MediaQuery.of(this).size.width > 800;

  /// Combined check for desktop platform AND large screen, or web with large screen
  bool get useDesktopLayout => (isDesktop || (isWeb && isLargeScreen)) && isLargeScreen;

  /// Get platform name for debugging
  String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  /// Get platform-appropriate padding
  EdgeInsets get platformPadding => EdgeInsets.all((isDesktop || isWeb) ? 16.0 : 12.0);
}
