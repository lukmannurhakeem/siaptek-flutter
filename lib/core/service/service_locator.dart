import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/repositories/category/category_impl.dart';
import 'package:base_app/repositories/category/category_repository.dart';
import 'package:base_app/repositories/customer/customer_impl.dart';
import 'package:base_app/repositories/customer/customer_repository.dart';
import 'package:base_app/repositories/job/job_impl.dart';
import 'package:base_app/repositories/job/job_repository.dart';
import 'package:base_app/repositories/personnel/personnel_impl.dart';
import 'package:base_app/repositories/personnel/personnel_repository.dart';
import 'package:base_app/repositories/planner/planner_impl.dart';
import 'package:base_app/repositories/planner/planner_repository.dart';
import 'package:base_app/repositories/site/site_impl.dart';
import 'package:base_app/repositories/site/site_repository.dart';
import 'package:base_app/repositories/system/system.impl.dart';
import 'package:base_app/repositories/system/system_repository.dart';
import 'package:base_app/repositories/user/user_impl.dart';
import 'package:base_app/repositories/user/user_repository.dart';

/// Simple service locator without external dependencies
/// Manages singleton instances of services and repositories
class ServiceLocator {
  // Singleton instance
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  // Services
  OfflineHttpService? _httpService;

  // Repositories (lazy initialization)
  CustomerRepository? _customerRepository;
  PlannerRepository? _plannerRepository;
  JobRepository? _jobRepository;
  SiteRepository? _siteRepository;
  SystemRepository? _systemRepository;
  CategoryRepository? _categoryRepository;
  PersonnelRepository? _personnelRepository;
  UserRepository? _userRepository;

  // Register HTTP Service (called from main.dart)
  void registerHttpService(OfflineHttpService service) {
    _httpService = service;
  }

  // Get HTTP Service
  OfflineHttpService get httpService {
    if (_httpService == null) {
      throw Exception('HttpService not initialized. Call registerHttpService() first.');
    }
    return _httpService!;
  }

  // Get Customer Repository
  UserRepository get userRepository {
    _userRepository ??= UserImpl(httpService);
    return _userRepository!;
  }

  PlannerRepository get plannerRepository {
    _plannerRepository ??= PlannerImpl(httpService);
    return _plannerRepository!;
  }

  // Get Customer Repository
  CustomerRepository get customerRepository {
    _customerRepository ??= CustomerImpl(httpService);
    return _customerRepository!;
  }

  // Get Job Repository
  JobRepository get jobRepository {
    _jobRepository ??= JobImpl(httpService);
    return _jobRepository!;
  }

  // Get Site Repository
  SiteRepository get siteRepository {
    _siteRepository ??= SiteImpl(httpService);
    return _siteRepository!;
  }

  // Get System Repository
  SystemRepository get systemRepository {
    _systemRepository ??= SystemImpl(httpService);
    return _systemRepository!;
  }

  // Get Category Repository
  CategoryRepository get categoryRepository {
    _categoryRepository ??= CategoryImpl(httpService);
    return _categoryRepository!;
  }

  // Get Personnel Repository
  PersonnelRepository get personnelRepository {
    _personnelRepository ??= PersonnelImpl(httpService);
    return _personnelRepository!;
  }

  // Reset all instances (useful for testing or logout)
  void reset() {
    _httpService = null;
    _customerRepository = null;
    _jobRepository = null;
    _siteRepository = null;
    _systemRepository = null;
    _categoryRepository = null;
    _personnelRepository = null;
    _plannerRepository = null;
  }
}

// Usage in your code:
//
// In Providers:
// final _jobRepository = ServiceLocator().jobRepository;
// final _httpService = ServiceLocator().httpService;
//
// In Repositories:
// class JobRepository {
//   final UnifiedHttpService _http;
//   JobRepository(this._http);
//
//   Future<JobModel> fetchJobs() async {
//     final response = await _http.get('/jobs', requiresAuth: true);
//     return JobModel.fromJson(response.data);
//   }
// }
