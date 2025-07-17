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

  Future<void> verifyToken(BuildContext context) async {
    try {
      final token = _userRepository.getAccessToken();

      if (token == null || token.isEmpty) {
        NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        return;
      }

      final data = await _userRepository.userVerifyToken();

      if (data.valid == true) {
        NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
      } else {
        await _userRepository.userRefreshToken();
        NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
      }
    } catch (e) {
      NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
      CommonSnackbar.showError(context, 'Session expired. Please log in again.');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _userRepository.userLogout();
      NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    }
  }
}
