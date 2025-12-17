import 'package:INSPECT/model/user_login_model.dart';
import 'package:INSPECT/model/user_refresh_token.dart';
import 'package:INSPECT/model/user_verify_token.dart';
import 'package:INSPECT/model/view_user_model.dart';

abstract class UserRepository {
  Future<UserLoginModel> userLogin(String name, String password);

  Future<UserVerifyTokenModel> userVerifyToken();

  Future<UserRefreshTokenModel> userRefreshToken();

  Future<void> userLogout();

  String? getAccessToken();

  String? getRefreshToken();

  Future<Map<String, dynamic>> userRegister(Map<String, dynamic> registerData);

  Future<ViewUserModel> fetchUserAccess();
}
