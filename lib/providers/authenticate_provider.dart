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

  Future<void> verifyToken(BuildContext context) async {
    try {
      final storageAccessToken = LocalStorageService.getString(LocalStorageConstant.accessToken);

      if (storageAccessToken.isNotEmpty) {
        final data = await _userRepository.userVerifyToken();

        if (data.valid == true) {
          NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
        } else {
          await _userRepository.userRefreshToken();
          NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
        }
      }
    } catch (e) {
      final data = await _userRepository.userRefreshToken();

      if (data.accessToken?.isNotEmpty == true) {
        await LocalStorageService.setString(
          LocalStorageConstant.accessToken,
          '${data.accessToken}',
        );
        await LocalStorageService.setString(
          LocalStorageConstant.refreshToken,
          '${data.refreshToken}',
        );
        NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
      } else {
        NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        CommonSnackbar.showError(context, '$e');
      }
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
