import 'package:INSPECT/model/get_company_division.dart';
import 'package:INSPECT/screens/auth/forgot_password_screen.dart';
import 'package:INSPECT/screens/auth/login_screen.dart';
import 'package:INSPECT/screens/categories/categories_create_screen.dart';
import 'package:INSPECT/screens/categories/categories_screen.dart';
import 'package:INSPECT/screens/categories/category_details.dart';
import 'package:INSPECT/screens/customer/customer_create_screen.dart';
import 'package:INSPECT/screens/customer/customer_screen.dart';
import 'package:INSPECT/screens/dashboard/dashboard_screen.dart';
import 'package:INSPECT/screens/home_screen.dart';
import 'package:INSPECT/screens/job/job_add_new_details_screen.dart';
import 'package:INSPECT/screens/job/job_add_new_screen.dart';
import 'package:INSPECT/screens/job/job_item_create/job_item_create_screen.dart';
import 'package:INSPECT/screens/job/job_item_details/job_item_details_screen.dart';
import 'package:INSPECT/screens/job/job_item_details/report_field_screen.dart';
import 'package:INSPECT/screens/job/job_register/job_register_screen.dart';
import 'package:INSPECT/screens/job/job_screen.dart';
import 'package:INSPECT/screens/personnel/personnel_create_screen.dart';
import 'package:INSPECT/screens/personnel/personnel_detail_screen.dart';
import 'package:INSPECT/screens/personnel/personnel_screen.dart';
import 'package:INSPECT/screens/personnel/personnel_team_create_screen.dart';
import 'package:INSPECT/screens/personnel/personnel_team_screen.dart';
import 'package:INSPECT/screens/planner/planner_screen.dart';
import 'package:INSPECT/screens/planner/team_planner_screen.dart';
import 'package:INSPECT/screens/profile/profile_screen.dart';
import 'package:INSPECT/screens/settings/access/acccess_view_screen.dart';
import 'package:INSPECT/screens/settings/access/accesss_create_screen.dart';
import 'package:INSPECT/screens/settings/company/division_crete_screen.dart';
import 'package:INSPECT/screens/settings/report_setup/create_cycle_screen.dart';
import 'package:INSPECT/screens/settings/report_setup/report_create_screen.dart';
import 'package:INSPECT/screens/settings/report_setup/report_types_detail_screen.dart';
import 'package:INSPECT/screens/site/site_create_new_screen.dart';
import 'package:INSPECT/screens/site/site_detail_screen.dart';
import 'package:INSPECT/screens/site/site_screen.dart';
import 'package:INSPECT/screens/splash_screen.dart';
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
  static const String jobItemCreateScreen = '/jobItemCreateScreen';

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

  static const String accessScreen = '/accessScreen';
  static const String accessView = '/accessView';

  static const String reportFieldsScreen = '/reportFieldsScreen ';

  static const String createCycle = '/createCycle';

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
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobRegisterScreen(jobId: args?['jobId']),
          settings: settings,
        );

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
          builder: (_) => JobItemDetailsScreen(item: args?['item'] ?? ''),
          settings: settings,
        );

      case jobItemCreateScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => JobItemCreateScreen(jobId: args?['jobId']),
          settings: settings,
        );

      case personnel:
        return MaterialPageRoute(builder: (_) => const PersonnelScreen(), settings: settings);

      case createPersonnel:
        return MaterialPageRoute(builder: (_) => const PersonnelCreateScreen(), settings: settings);

      case teamPersonnel:
        return MaterialPageRoute(builder: (_) => const PersonnelTeamScreen(), settings: settings);

      case createTeamPersonnel:
        final teamId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => PersonnelCreateTeamScreen(teamPersonnelId: teamId),
          settings: settings,
        );

      case personnelDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PersonnelDetailScreen(personnelId: args?['personnelId']),
          settings: settings,
        );

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

      case createCycle:
        return MaterialPageRoute(builder: (_) => const CreateCycleScreen(), settings: settings);

      case companyCreateDivision:
        final args = settings.arguments;

        // Check if editing an existing division (GetCompanyDivision object passed)
        if (args is GetCompanyDivision) {
          return MaterialPageRoute(
            builder: (_) => CompanyCreateDivision(division: args),
            settings: settings,
          );
        }
        // Check if creating with a customer ID (Map passed)
        else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CompanyCreateDivision(id: args['id'] as String?),
            settings: settings,
          );
        }
        // Default create mode (no arguments)
        else {
          return MaterialPageRoute(
            builder: (_) => const CompanyCreateDivision(),
            settings: settings,
          );
        }

      case reportCreate:
        return MaterialPageRoute(builder: (_) => const ReportCreateScreen(), settings: settings);

      case reportTypeDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReportTypesDetails(reportTypeID: args?['reportTypeID'] ?? ''),
          settings: settings,
        );

      case accessScreen:
        return MaterialPageRoute(builder: (_) => const AccessScreen(), settings: settings);

      case accessView:
        return MaterialPageRoute(builder: (_) => const AccessViewScreen(), settings: settings);

      case reportFieldsScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder:
              (_) => ReportFieldsScreen(
                reportTypeId: args?['reportTypeId'] ?? '',
                reportName: args?['reportName'] ?? 'Report Details',
                item: args?['item'],
              ),
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
