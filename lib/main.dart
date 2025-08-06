import 'package:base_app/core/service/flavor_config.dart';
import 'package:base_app/core/service/local_storage.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/core/theme/app_theme.dart';
import 'package:base_app/providers/authenticate_provider.dart';
import 'package:base_app/providers/customer_provider.dart';
import 'package:base_app/providers/site_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.dev");
  await LocalStorageService.init();
  mainCommon(FlavorType.dev);
}

void mainCommon(FlavorType flavor) async {
  Flavor.appFlavor = flavor;

  if (Flavor.shouldShowLogs) {
    print('Running ${Flavor.title} with base URL: ${Flavor.baseUrl}');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticateProvider()),
        ChangeNotifierProvider(create: (_) => SiteProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        // Add more providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: navigationService.navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [RouteObserver()],
    );
  }
}
