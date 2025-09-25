import 'package:base_app/core/service/local_storage.dart';
import 'package:base_app/core/service/local_storage_constant.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/user_login_model.dart';
import 'package:base_app/repositories/user/user_repository.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_snackbar.dart';
import 'package:flutter/material.dart';

class AuthenticateProvider extends ChangeNotifier {
  final UserRepository _userRepository = ServiceLocator().userRepository;

  UserLoginModel? _user;

  UserLoginModel? get user => _user;

  Future<UserLoginModel?> login(BuildContext context, String name, String password) async {
    if (name.trim().isEmpty || password.trim().isEmpty) {
      CommonSnackbar.showError(context, 'Email and password must not be empty');
    } else {
      try {
        _user = await _userRepository.userLogin(name, password);

        await LocalStorageService.setString(
          LocalStorageConstant.userFirstName,
          _user!.user!.firstName ?? '',
        );
        await LocalStorageService.setString(
          LocalStorageConstant.userLastName,
          _user!.user!.lastName ?? '',
        );
        await LocalStorageService.setString(
          LocalStorageConstant.userEmail,
          _user!.user!.email ?? '',
        );
        NavigationService().replaceTo(
          AppRoutes.home,
          arguments: {
            'showWelcomeDialog': true,
            'userName': '${_user?.user?.firstName ?? ''} ${_user?.user?.lastName ?? ''}',
          },
        );
      } catch (e) {
        CommonSnackbar.showError(context, e.toString());
      }
    }

    return _user;
  }

  // Added register method
  Future<bool> registerUser(BuildContext context, Map<String, dynamic> registerData) async {
    try {
      await _userRepository.userRegister(registerData);
      return true;
    } catch (e) {
      CommonSnackbar.showError(context, 'Failed to register user: ${e.toString()}');
      return false;
    }
  }

  Future<void> verifyToken(BuildContext context) async {
    try {
      final storageAccessToken = LocalStorageService.getString(LocalStorageConstant.accessToken);

      // No token → go to login
      if (storageAccessToken.isEmpty) {
        NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        return;
      }

      // Verify existing token
      final verifyResponse = await _userRepository.userVerifyToken();

      if (verifyResponse.valid == true) {
        // Token valid → go to home
        NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
        return;
      }

      // Token invalid → try refresh
      try {
        final refreshResponse = await _userRepository.userRefreshToken();

        if (refreshResponse.accessToken?.isNotEmpty == true) {
          await LocalStorageService.setString(
            LocalStorageConstant.accessToken,
            refreshResponse.accessToken!,
          );
          await LocalStorageService.setString(
            LocalStorageConstant.refreshToken,
            refreshResponse.refreshToken ?? '',
          );
          NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
        } else {
          // Refresh failed → go to login
          await _clearTokens();
          NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        }
      } catch (e) {
        // Refresh request error → go to login
        await _clearTokens();
        NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
      }
    } catch (e) {
      // Verify request error → try refresh
      try {
        final refreshResponse = await _userRepository.userRefreshToken();

        if (refreshResponse.accessToken?.isNotEmpty == true) {
          await LocalStorageService.setString(
            LocalStorageConstant.accessToken,
            refreshResponse.accessToken!,
          );
          await LocalStorageService.setString(
            LocalStorageConstant.refreshToken,
            refreshResponse.refreshToken ?? '',
          );
          NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
        } else {
          await _clearTokens();
          NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
          CommonSnackbar.showError(context, e.toString());
        }
      } catch (e2) {
        await _clearTokens();
        NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        CommonSnackbar.showError(context, e2.toString());
      }
    }
  }

  Future<void> _clearTokens() async {
    await LocalStorageService.remove(LocalStorageConstant.accessToken);
    await LocalStorageService.remove(LocalStorageConstant.refreshToken);
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _userRepository.userLogout();
      await LocalStorageService.remove(LocalStorageConstant.accessToken);
      await LocalStorageService.remove(LocalStorageConstant.refreshToken);
      NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    }
  }
}
