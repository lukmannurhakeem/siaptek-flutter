import 'package:base_app/core/service/flavor_config.dart';
import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/repositories/user/user_impl.dart';
import 'package:base_app/repositories/user/user_repository.dart';

import 'package:dio/dio.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  UserRepository? _userRepository;

  void setupRepositories() {
    final dio = Dio()
      ..options.baseUrl = Flavor.baseUrl
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    final apiClient = ApiClient(dio);
    _userRepository = UserImpl(apiClient);
  }

  UserRepository get userRepository {
    if (_userRepository == null) {
      setupRepositories();
    }
    return _userRepository!;
  }
}
