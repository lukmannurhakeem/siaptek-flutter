import 'package:base_app/core/service/flavor_config.dart';
import 'package:base_app/core/service/local_storage.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/core/theme/app_theme.dart';
import 'package:base_app/providers/authenticate_provider.dart';
import 'package:base_app/providers/category_provider.dart';
import 'package:base_app/providers/customer_provider.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/providers/site_provider.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env.dev");

  // Initialize local storage (required for offline feature)
  await LocalStorageService.init();

  mainCommon(FlavorType.dev);
}

void mainCommon(FlavorType flavor) async {
  Flavor.appFlavor = flavor;

  if (Flavor.shouldShowLogs) {
    print('Running ${Flavor.title} with base URL: ${Flavor.baseUrl}');
  }

  // Initialize offline-enabled HTTP service
  await _initializeHttpService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticateProvider()),
        ChangeNotifierProvider(create: (_) => SiteProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SystemProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => PersonnelProvider()),
        // Add more providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

/// Initialize HTTP service with automatic offline support
Future<void> _initializeHttpService() async {
  // Create Dio instance with base configuration
  final dio = Dio(
    BaseOptions(
      baseUrl: Flavor.baseUrl, // Use flavor-based base URL
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  // Optional: Add auth interceptor for automatic token refresh
  // Uncomment the line below if you want automatic token refresh on 401 errors
  // dio.interceptors.add(AuthInterceptor(dio));

  // Initialize UnifiedHttpService with automatic offline support
  final httpService = OfflineHttpService(dio);

  // Register in service locator for global access
  ServiceLocator().registerHttpService(httpService);

  if (Flavor.shouldShowLogs) {
    print('✅ HTTP Service initialized with offline support');
  }
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
