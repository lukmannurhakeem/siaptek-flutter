import 'package:base_app/screens/auth/forgot_password_screen.dart';
import 'package:base_app/screens/auth/login_screen.dart';
import 'package:base_app/screens/categories/categories_create_screen.dart';
import 'package:base_app/screens/categories/categories_screen.dart';
import 'package:base_app/screens/categories/category_details.dart';
import 'package:base_app/screens/customer/customer_create_screen.dart';
import 'package:base_app/screens/customer/customer_screen.dart';
import 'package:base_app/screens/dashboard/dashboard_screen.dart';
import 'package:base_app/screens/home_screen.dart';
import 'package:base_app/screens/job/job_add_new_details_screen.dart';
import 'package:base_app/screens/job/job_add_new_screen.dart';
import 'package:base_app/screens/job/job_item_details/job_item_details_screen.dart';
import 'package:base_app/screens/job/job_register/job_register_screen.dart';
import 'package:base_app/screens/job/job_screen.dart';
import 'package:base_app/screens/personnel/personnel_create_screen.dart';
import 'package:base_app/screens/personnel/personnel_detail_screen.dart';
import 'package:base_app/screens/personnel/personnel_screen.dart';
import 'package:base_app/screens/personnel/personnel_team_create_screen.dart';
import 'package:base_app/screens/personnel/personnel_team_screen.dart';
import 'package:base_app/screens/planner/planner_screen.dart';
import 'package:base_app/screens/planner/team_planner_screen.dart';
import 'package:base_app/screens/profile/profile_screen.dart';
import 'package:base_app/screens/settings/company/division_crete_screen.dart';
import 'package:base_app/screens/settings/report_setup/report_create_screen.dart';
import 'package:base_app/screens/settings/report_setup/report_types_detail_screen.dart';
import 'package:base_app/screens/site/site_create_new_screen.dart';
import 'package:base_app/screens/site/site_detail_screen.dart';
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
  static const String jobRegister = '/jobRegister';
  static const String jobAddNewScreen = '/jobAddNewScreen';
  static const String jobAddNewDetailsScreen = '/jobAddNewDetailsScreen';
  static const String jobItemDetails = '/jobItemOverview';

  static const String personnel = '/personnel';
  static const String teamPersonnel = '/teamPersonnel';
  static const String createPersonnel = '/createPersonnel';
  static const String createTeamPersonnel = '/createTeamPersonnel';
  static const String personnelDetails = '/personnelDetails';
  static const String site = '/site';
  static const String siteDetails = '/siteDetails';
  static const String createSite = '/createSite';
  static const String categories = '/categories';
  static const String createCategories = '/createCategories';
  static const String categoryDetails = '/categoryDetails';
  static const String profile = '/profile';
  static const String customer = '/customer';
  static const String createCustomer = '/createCustomer';

  static const String companyCreateDivision = '/companyCreateDivision';
  static const String reportCreate = '/reportCreate';
  static const String reportTypeDetails = '/reportTypeDetails';

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

      case jobRegister:
        return MaterialPageRoute(builder: (_) => const JobRegisterScreen(), settings: settings);

      case jobAddNewScreen:
        return MaterialPageRoute(builder: (_) => const JobAddNewScreen(), settings: settings);

      case jobAddNewDetailsScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => JobAddNewDetailsScreen(
                customer: args?['customer'] ?? '',
                site: args?['site'] ?? '',
              ),
          settings: settings,
        );

      case jobItemDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => JobItemDetailsScreen(item: args?['item'] ?? '', site: args?['site'] ?? ''),
          settings: settings,
        );

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

      case personnelDetails:
        return MaterialPageRoute(builder: (_) => const PersonnelDetailScreen(), settings: settings);

      case site:
        return MaterialPageRoute(builder: (_) => const SiteScreen(), settings: settings);

      case siteDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SiteDetailsScreen(sideModel: args?['siteModel']),
          settings: settings,
        );

      case createSite:
        return MaterialPageRoute(builder: (_) => const SiteCreateNewScreen(), settings: settings);

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen(), settings: settings);

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen(), settings: settings);

      case createCategories:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CategoriesCreateScreen(categoryId: args?['categoryId'] ?? ''),
          settings: settings,
        );

      case categoryDetails:
        return MaterialPageRoute(builder: (_) => const CategoryDetails(), settings: settings);

      case customer:
        return MaterialPageRoute(builder: (_) => const CustomerScreen(), settings: settings);

      case createCustomer:
        return MaterialPageRoute(
          builder: (_) => const CustomerCreateNewScreen(),
          settings: settings,
        );

      case companyCreateDivision:
        return MaterialPageRoute(builder: (_) => const CompanyCreateDivision(), settings: settings);

      case reportCreate:
        return MaterialPageRoute(builder: (_) => const ReportCreateScreen(), settings: settings);

      case reportTypeDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReportTypesDetails(reportTypeID: args?['reportTypeID'] ?? ''),
          settings: settings,
        );

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
