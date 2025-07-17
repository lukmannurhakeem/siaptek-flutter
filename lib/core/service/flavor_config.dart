import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum FlavorType {
  dev,
  staging,
  prod,
}

class Flavor {
  static FlavorType? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title => dotenv.env['APP_NAME'] ?? 'SettlePayz';

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  static bool get isProduction => appFlavor == FlavorType.prod;
  static bool get isDevelopment => appFlavor == FlavorType.dev;
  static bool get isStaging => appFlavor == FlavorType.staging;

  static bool get shouldShowLogs => !isProduction;
}

/// A widget that shows a banner in the corner of the screen indicating the current app flavor.
/// Only shows in non-production environments.
class FlavorBanner extends StatelessWidget {
  final Widget child;

  const FlavorBanner({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't show banner in production
    if (Flavor.isProduction) {
      return child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        message: Flavor.name.toUpperCase(),
        location: BannerLocation.topEnd,
        color: _getBannerColor(),
        child: child,
      ),
    );
  }

  Color _getBannerColor() {
    switch (Flavor.appFlavor) {
      case FlavorType.dev:
        return Colors.blue;
      case FlavorType.staging:
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
}
