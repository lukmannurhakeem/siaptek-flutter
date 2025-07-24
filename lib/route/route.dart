import 'package:base_app/screens/auth/forgot_password_screen.dart';
import 'package:base_app/screens/auth/login_screen.dart';
import 'package:base_app/screens/categories/categories_screen.dart';
import 'package:base_app/screens/dashboard/dashboard_screen.dart';
import 'package:base_app/screens/home_screen.dart';
import 'package:base_app/screens/job/job_screen.dart';
import 'package:base_app/screens/personnel/personnel_create_screen.dart';
import 'package:base_app/screens/personnel/personnel_screen.dart';
import 'package:base_app/screens/personnel/personnel_team_create_screen.dart';
import 'package:base_app/screens/personnel/personnel_team_screen.dart';
import 'package:base_app/screens/planner/planner_screen.dart';
import 'package:base_app/screens/planner/team_planner_screen.dart';
import 'package:base_app/screens/site/site_screen.dart';
import 'package:base_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';

/// A class that centralizes application routes and provides route generation.
class AppRoutes {
  // Route names as constants
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String planner = '/planner';
  static const String teamPlanner = '/teamPlanner';
  static const String job = '/job';
  static const String personnel = '/personnel';
  static const String teamPersonnel = '/teamPersonnel';
  static const String createPersonnel = '/createPersonnel';
  static const String createTeamPersonnel = '/createTeamPersonnel';
  static const String site = '/site';
  static const String categories = '/categories';

  // Route generator function
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen(), settings: settings);

      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => HomeScreen(
                showWelcomeDialog: args?['showWelcomeDialog'] ?? false,
                userName: args?['userName'],
              ),
          settings: settings,
        );

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen(), settings: settings);

      case planner:
        return MaterialPageRoute(builder: (_) => const PlannerScreen(), settings: settings);

      case teamPlanner:
        return MaterialPageRoute(builder: (_) => const TeamPlannerScreen(), settings: settings);

      case job:
        return MaterialPageRoute(builder: (_) => const JobScreen(), settings: settings);

      case personnel:
        return MaterialPageRoute(builder: (_) => const PersonnelScreen(), settings: settings);

      case createPersonnel:
        return MaterialPageRoute(builder: (_) => const PersonnelCreateScreen(), settings: settings);

      case teamPersonnel:
        return MaterialPageRoute(builder: (_) => const PersonnelTeamScreen(), settings: settings);

      case createTeamPersonnel:
        return MaterialPageRoute(
          builder: (_) => const PersonnelCreateTeamScreen(),
          settings: settings,
        );

      case site:
        return MaterialPageRoute(builder: (_) => const SiteScreen(), settings: settings);

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen(), settings: settings);

      default:
        // If the route is not defined, show an error page
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('Route not found')),
              ),
          settings: settings,
        );
    }
  }
}
