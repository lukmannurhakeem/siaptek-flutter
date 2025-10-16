import 'package:base_app/core/service/local_storage.dart';
import 'package:base_app/core/service/local_storage_constant.dart';
import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/user_login_model.dart';
import 'package:base_app/model/user_refresh_token.dart';
import 'package:base_app/model/user_verify_token.dart';
import 'package:base_app/model/view_user_model.dart';
import 'package:base_app/repositories/user/user_repository.dart';
import 'package:base_app/route/endpoint.dart';

class UserImpl implements UserRepository {
  final OfflineHttpService _api;

  UserImpl(this._api);

  @override
  Future<UserLoginModel> userLogin(String name, String password) async {
    // Login should always be online (no queueing for authentication)
    final response = await _api.post(
      Endpoint.login,
      data: {"email": name, "password": password},
      requiresAuth: false, // No auth needed for login
    );

    // Save tokens to local storage
    final accessToken = response.data['access_token'];
    final refreshToken = response.data['refresh_token'];

    await LocalStorageService.setString(LocalStorageConstant.accessToken, accessToken);
    await LocalStorageService.setString(LocalStorageConstant.refreshToken, refreshToken);

    return UserLoginModel.fromJson(response.data);
  }

  @override
  Future<UserVerifyTokenModel> userVerifyToken() async {
    // Token verification should always be online
    final response = await _api.get(Endpoint.verifyToken, requiresAuth: true);
    return UserVerifyTokenModel.fromJson(response.data);
  }

  @override
  Future<UserRefreshTokenModel> userRefreshToken() async {
    // Token refresh should always be online
    final response = await _api.post(
      Endpoint.refreshToken,
      data: {'refresh_token': LocalStorageService.getString(LocalStorageConstant.refreshToken)},
      requiresAuth: false,
    );

    // Update tokens in local storage
    final accessToken = response.data['access_token'];
    final refreshToken = response.data['refresh_token'];

    await LocalStorageService.setString(LocalStorageConstant.accessToken, accessToken);
    await LocalStorageService.setString(LocalStorageConstant.refreshToken, refreshToken);

    return UserRefreshTokenModel.fromJson(response.data);
  }

  @override
  Future<void> userLogout() async {
    // Logout should always be online
    try {
      await _api.post(
        Endpoint.logout,
        data: {'refresh_token': LocalStorageService.getString(LocalStorageConstant.refreshToken)},
        requiresAuth: false,
      );
    } finally {
      // Clear tokens even if request fails
      await LocalStorageService.remove(LocalStorageConstant.accessToken);
      await LocalStorageService.remove(LocalStorageConstant.refreshToken);
    }
  }

  @override
  String? getAccessToken() {
    return LocalStorageService.getString(LocalStorageConstant.accessToken);
  }

  @override
  String? getRefreshToken() {
    return LocalStorageService.getString(LocalStorageConstant.refreshToken);
  }

  @override
  Future<Map<String, dynamic>> userRegister(Map<String, dynamic> registerData) async {
    final response = await _api.post(Endpoint.userRegister, data: registerData, requiresAuth: true);

    // Check if queued (offline)
    if (response.statusCode == 202 && response.data['queued'] == true) {
      return {
        'message': 'User registration saved locally. Will sync when online.',
        'queued': true,
        'requestId': response.data['requestId'],
      };
    }

    return response.data;
  }

  @override
  Future<ViewUserModel> fetchUserAccess() async {
    final response = await _api.get(
      Endpoint.userRegister, // Add this endpoint to your Endpoint class
      requiresAuth: true,
    );
    return ViewUserModel.fromJson(response.data);
  }
}

// Note: Authentication endpoints (login, refresh, logout, verify)
// are intentionally NOT queued when offline. They should always
// require an active connection for security reasons.
