import 'dart:html' as html;

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
import 'package:base_app/providers/planner_provider.dart';
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
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => SiteProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SystemProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => PersonnelProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeHttpService() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: Flavor.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  final httpService = OfflineHttpService(dio);
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
      // Start with landing page first
      home: const PWALandingScreen(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [RouteObserver()],
    );
  }
}

// PWA Landing Screen with Install Button
class PWALandingScreen extends StatefulWidget {
  const PWALandingScreen({super.key});

  @override
  State<PWALandingScreen> createState() => _PWALandingScreenState();
}

class _PWALandingScreenState extends State<PWALandingScreen> {
  bool _isInstalled = false;
  bool _canInstall = false;
  bool _showLanding = true;

  @override
  void initState() {
    super.initState();
    _checkInstallStatus();
    _listenForInstallPrompt();
  }

  void _checkInstallStatus() {
    final isStandalone = html.window.matchMedia('(display-mode: standalone)').matches;
    setState(() {
      _isInstalled = isStandalone;
      // If already installed, skip landing page
      if (isStandalone) {
        _showLanding = false;
      }
    });
  }

  void _listenForInstallPrompt() {
    html.window.addEventListener('beforeinstallprompt', (event) {
      setState(() => _canInstall = true);
    });

    html.window.addEventListener('appinstalled', (event) {
      setState(() {
        _isInstalled = true;
        _canInstall = false;
      });
      // Navigate to main app after install
      Future.delayed(const Duration(milliseconds: 500), () {
        _enterApp();
      });
    });
  }

  void _handleInstall() {
    html.window.dispatchEvent(html.CustomEvent('flutter-install-click'));
  }

  void _enterApp() {
    setState(() => _showLanding = false);
    // Navigate to your splash screen or main app
    Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    // If not showing landing, show your actual app
    if (!_showLanding) {
      // This will be replaced by your actual initial route
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 80, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to My PWA App',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Experience lightning-fast performance and work offline',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Install button (if available)
                  if (_canInstall && !_isInstalled)
                    ElevatedButton.icon(
                      onPressed: _handleInstall,
                      icon: const Icon(Icons.download),
                      label: const Text('Install App'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Continue to app button
                  OutlinedButton.icon(
                    onPressed: _enterApp,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(_isInstalled ? 'Open App' : 'Continue to App'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (!_canInstall && !_isInstalled)
                    const Text(
                      'Install option will appear on supported browsers',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
