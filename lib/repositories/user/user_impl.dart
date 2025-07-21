import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/core/service/local_storage.dart';
import 'package:base_app/model/user_login_model.dart';
import 'package:base_app/model/user_refresh_token.dart';
import 'package:base_app/model/user_verify_token.dart';
import 'package:base_app/repositories/user/user_repository.dart';
import 'package:base_app/route/endpoint.dart';

class UserImpl implements UserRepository {
  final ApiClient _api;
  UserImpl(this._api);

  @override
  Future<UserLoginModel> userLogin(String name, String password) async {
    final response = await _api.post(
      Endpoint.login,
      data: {
        "email": name,
        "password": password,
      },
    );

    _api.setAccessToken(response.data['access_token']);
    await LocalStorageService.setString('access_token', '${_api.accessToken}');
    _api.setRefreshToken(response.data['refresh_token']);
    await LocalStorageService.setString('refresh_token', '${_api.refreshToken}');

    return UserLoginModel.fromJson(response.data);
  }

  @override
  Future<UserVerifyTokenModel> userVerifyToken() async {
    final response = await _api.get(
      Endpoint.verifyToken,
      requiresAuth: true,
    );
    return UserVerifyTokenModel.fromJson(response.data);
  }

  @override
  Future<UserRefreshTokenModel> userRefreshToken() async {
    final response = await _api.post(
      Endpoint.refreshToken,
      data: {
        'refresh_token':  LocalStorageService.getString('refresh_token'),
      },
    );

    _api.setAccessToken(response.data['access_token']);
    await LocalStorageService.setString('access_token', '${_api.accessToken}');
    _api.setRefreshToken(response.data['refresh_token']);
    await LocalStorageService.setString('refresh_token', '${_api.refreshToken}');

    return UserRefreshTokenModel.fromJson(response.data);
  }

  @override
  Future<void> userLogout() async {
    await _api.post(
      Endpoint.logout,
      data: {
        'refresh_token': _api.refreshToken,
      },
    );
  }

  @override
  String? getAccessToken() => _api.accessToken;

  @override
  String? getRefreshToken() => _api.refreshToken;
}
