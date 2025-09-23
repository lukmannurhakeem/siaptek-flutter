import 'package:base_app/core/service/flavor_config.dart';
import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/repositories/category/category_impl.dart';
import 'package:base_app/repositories/category/category_repository.dart';
import 'package:base_app/repositories/customer/customer_impl.dart';
import 'package:base_app/repositories/customer/customer_repository.dart';
import 'package:base_app/repositories/job/job_impl.dart';
import 'package:base_app/repositories/job/job_repository.dart';
import 'package:base_app/repositories/personnel/personnel_impl.dart';
import 'package:base_app/repositories/personnel/personnel_repository.dart';
import 'package:base_app/repositories/site/site_impl.dart';
import 'package:base_app/repositories/site/site_repository.dart';
import 'package:base_app/repositories/system/system.impl.dart';
import 'package:base_app/repositories/system/system_repository.dart';
import 'package:base_app/repositories/user/user_impl.dart';
import 'package:base_app/repositories/user/user_repository.dart';
import 'package:dio/dio.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  UserRepository? _userRepository;
  SiteRepository? _siteRepository;
  CustomerRepository? _customerRepository;
  SystemRepository? _systemRepository;
  JobRepository? _jobRepository;
  CategoryRepository? _categoryRepository;
  PersonnelRepository? _personnelRepository;

  void setupRepositories() {
    final dio =
        Dio()
          ..options.baseUrl = Flavor.baseUrl
          ..options.headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

    final apiClient = ApiClient(dio);
    _userRepository = UserImpl(apiClient);
    _siteRepository = SiteImpl(apiClient);
    _customerRepository = CustomerImpl(apiClient);
    _systemRepository = SystemImpl(apiClient);
    _jobRepository = JobImpl(apiClient);
    _categoryRepository = CategoryImpl(apiClient);
    _personnelRepository = PersonnelImpl(apiClient);
  }

  UserRepository get userRepository {
    if (_userRepository == null) {
      setupRepositories();
    }
    return _userRepository!;
  }

  SiteRepository get siteRepository {
    if (_siteRepository == null) {
      setupRepositories();
    }
    return _siteRepository!;
  }

  CustomerRepository get customerRepository {
    if (_customerRepository == null) {
      setupRepositories();
    }
    return _customerRepository!;
  }

  SystemRepository get systemRepository {
    if (_systemRepository == null) {
      setupRepositories();
    }
    return _systemRepository!;
  }

  JobRepository get jobRepository {
    if (_jobRepository == null) {
      setupRepositories();
    }
    return _jobRepository!;
  }

  CategoryRepository get categoryRepository {
    if (_categoryRepository == null) {
      setupRepositories();
    }
    return _categoryRepository!;
  }

  PersonnelRepository get personnelRepository {
    if (_personnelRepository == null) {
      setupRepositories();
    }
    return _personnelRepository!;
  }
}
