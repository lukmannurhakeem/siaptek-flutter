import 'dart:async';

import 'package:base_app/core/service/local_storage.dart';
import 'package:base_app/core/service/local_storage_constant.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/core/service/websocket_service.dart';
import 'package:base_app/model/user_login_model.dart';
import 'package:base_app/repositories/user/user_repository.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthenticateProvider extends ChangeNotifier {
  final UserRepository _userRepository = ServiceLocator().userRepository;

  // WebSocket integration
  late final WebSocketService _wsService;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _systemNoticeSubscription;

  UserLoginModel? _user;
  bool _isWebSocketConnected = false;

  UserLoginModel? get user => _user;

  bool get isWebSocketConnected => _isWebSocketConnected;

  bool get isAdmin => _user?.user?.userGroup?.toLowerCase() == 'admin';

  String get userGroup => LocalStorageService.getString(LocalStorageConstant.userGroup);

  AuthenticateProvider() {
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    try {
      _wsService = ServiceLocator().webSocketService;

      // Listen to connection status
      _connectionSubscription = _wsService.connectionStatus.listen((isConnected) {
        _isWebSocketConnected = isConnected;
        debugPrint('🔌 WebSocket ${isConnected ? "Connected" : "Disconnected"}');
        notifyListeners();
      });

      // Listen to system notices
      _systemNoticeSubscription = _wsService.systemNotices.listen((data) {
        debugPrint('📢 System notice: $data');
      });
    } catch (e) {
      debugPrint('⚠️ WebSocket service not available: $e');
    }
  }

  Future<UserLoginModel?> login(BuildContext context, String name, String password) async {
    if (name.trim().isEmpty || password.trim().isEmpty) {
      CommonSnackbar.showError(context, 'Email and password must not be empty');
      return null;
    }

    UserLoginModel? loginResult;

    try {
      debugPrint('🔐 Starting login for: $name');

      // CRITICAL: Store result but don't navigate yet
      loginResult = await _userRepository.userLogin(name, password);

      debugPrint('✅ Login successful, processing user data...');

      // Validate we got a proper user object
      if (loginResult.accessToken == null || loginResult.accessToken!.isEmpty) {
        throw Exception('Invalid login response - no access token');
      }

      // Now we can safely assign to _user
      _user = loginResult;

      // Store tokens (already saved in repository, but update if needed)
      if (_user!.accessToken != null) {
        await LocalStorageService.setString(LocalStorageConstant.accessToken, _user!.accessToken!);
        ServiceLocator().offlineHttpService.resetRefreshAttempts();
      }

      if (_user!.refreshToken != null) {
        await LocalStorageService.setString(
          LocalStorageConstant.refreshToken,
          _user!.refreshToken!,
        );
      }

      // Store user info
      await LocalStorageService.setString(
        LocalStorageConstant.userFirstName,
        _user?.user?.firstName ?? '',
      );
      await LocalStorageService.setString(
        LocalStorageConstant.userLastName,
        _user?.user?.lastName ?? '',
      );
      await LocalStorageService.setString(LocalStorageConstant.userEmail, _user?.user?.email ?? '');
      await LocalStorageService.setString(
        LocalStorageConstant.userGroup,
        _user?.user?.userGroup ?? '',
      );

      // Store user ID and connect WebSocket
      if (_user?.user?.id != null) {
        final userId = _user!.user!.id.toString();
        await LocalStorageService.setString(LocalStorageConstant.userId, userId);
        debugPrint('🔗 Connecting WebSocket for user ID: $userId');
        _wsService.connect(userId);
      } else {
        debugPrint('⚠️ User ID is null, cannot connect WebSocket');
      }

      notifyListeners();

      // ONLY navigate if everything succeeded
      debugPrint('🎉 Login complete, navigating to home...');
      NavigationService().replaceTo(
        AppRoutes.home,
        arguments: {
          'showWelcomeDialog': true,
          'userName': '${_user?.user?.firstName ?? ''} ${_user?.user?.lastName ?? ''}',
        },
      );

      return _user;
    } on DioException catch (e) {
      debugPrint('❌ DioException in login');
      debugPrint('   Status: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      debugPrint('   Type: ${e.type}');

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String errorMessage = 'Login failed. Please try again.';

      // Handle authentication errors
      if (statusCode == 401 || statusCode == 403) {
        errorMessage = 'Invalid email or password';

        if (responseData is Map) {
          final serverMsg =
              responseData['error']?.toString() ??
              responseData['message']?.toString() ??
              responseData['detail']?.toString();

          if (serverMsg != null && serverMsg.isNotEmpty) {
            final lower = serverMsg.toLowerCase();
            if (lower.contains('credential') ||
                lower.contains('password') ||
                lower.contains('email') ||
                lower.contains('invalid') ||
                lower.contains('incorrect')) {
              errorMessage = serverMsg;
            }
          }
        }
      } else if (statusCode == 404) {
        errorMessage = 'Account not found';
      } else if (statusCode == 422) {
        errorMessage = 'Invalid email or password format';
      } else if (statusCode == 429) {
        errorMessage = 'Too many attempts. Try again later';
      } else if (statusCode == null ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      } else if (statusCode != null && statusCode >= 500) {
        errorMessage = 'Server error. Try again later';
      } else if (responseData is Map) {
        final serverMsg = responseData['error']?.toString() ?? responseData['message']?.toString();
        if (serverMsg != null && serverMsg.isNotEmpty) {
          errorMessage = serverMsg;
        }
      }

      debugPrint('   📢 Showing error: $errorMessage');

      // Make sure we show the error
      if (context.mounted) {
        CommonSnackbar.showError(context, errorMessage);
      }

      // CRITICAL: Return null to indicate failure
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in login');
      debugPrint('   Type: ${e.runtimeType}');
      debugPrint('   Error: $e');
      debugPrint('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

      String errorMessage = '${e.toString()}';

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') || errorStr.contains('network')) {
        errorMessage = 'Network error. Check your connection';
      } else if (errorStr.contains('format')) {
        errorMessage = 'Invalid server response';
      } else if (errorStr.contains('timeout')) {
        errorMessage = 'Request timeout';
      }

      if (context.mounted) {
        CommonSnackbar.showError(context, errorMessage);
      }

      // CRITICAL: Return null to indicate failure
      return null;
    }
  }

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
    debugPrint('🔍 Starting token verification...');

    try {
      final storageAccessToken = LocalStorageService.getString(LocalStorageConstant.accessToken);
      final refreshToken = LocalStorageService.getString(LocalStorageConstant.refreshToken);

      // 🔥 FIX: If no tokens at all, go straight to login
      if (storageAccessToken.isEmpty && refreshToken.isEmpty) {
        debugPrint('⚠️ No tokens found, redirecting to login');
        await _clearTokens();
        NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        return;
      }

      // 🔥 FIX: If we have refresh token but no access token, try refresh first
      if (storageAccessToken.isEmpty && refreshToken.isNotEmpty) {
        debugPrint('⚠️ No access token but have refresh token, attempting refresh...');
        final refreshSuccess = await _attemptTokenRefresh();
        if (!refreshSuccess) {
          await _clearTokens();
          NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        }
        return;
      }

      debugPrint('🔍 Token found, verifying...');

      try {
        final verifyResponse = await _userRepository.userVerifyToken();

        if (verifyResponse.valid == true) {
          debugPrint('✅ Token is valid, proceeding to home');

          // Reset refresh attempts on successful verification
          ServiceLocator().offlineHttpService.resetRefreshAttempts();

          // 🔥 RECONNECT WEBSOCKET ON APP RESTART
          await _reconnectWebSocket();
          NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
          return;
        } else {
          debugPrint('⚠️ Token invalid, attempting refresh...');
          final refreshSuccess = await _attemptTokenRefresh();
          if (!refreshSuccess) {
            await _clearTokens();
            NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
          }
        }
      } on DioException catch (verifyError) {
        final statusCode = verifyError.response?.statusCode;
        debugPrint('❌ Token verification failed with status: $statusCode');

        // 🔥 FIX: Check if it's a user-related error
        if (statusCode != null && (statusCode >= 500 || statusCode == 401 || statusCode == 403)) {
          final responseData = verifyError.response?.data;
          if (responseData is Map) {
            final errorMessage = responseData['error']?.toString().toLowerCase() ?? '';
            debugPrint('🔥 Verify error message: $errorMessage');

            if (errorMessage.contains('user not found') ||
                errorMessage.contains('invalid user') ||
                errorMessage.contains('user does not exist')) {
              debugPrint('💀 User not found error - clearing tokens and logging out');
              await _clearTokens();
              NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
              return;
            }
          }
        }

        // If not a user-not-found error, try to refresh
        debugPrint('⚠️ Verification failed, attempting refresh...');
        final refreshSuccess = await _attemptTokenRefresh();
        if (!refreshSuccess) {
          await _clearTokens();
          NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        }
      } catch (verifyError) {
        debugPrint('❌ Unexpected verification error: $verifyError');
        // On any unexpected error, try to refresh
        final refreshSuccess = await _attemptTokenRefresh();
        if (!refreshSuccess) {
          await _clearTokens();
          NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
        }
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in verifyToken: $e');
      // On any unexpected error, go to login
      await _clearTokens();
      NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
    }
  }

  // 🔥 Returns true if refresh succeeded, false otherwise
  Future<bool> _attemptTokenRefresh() async {
    debugPrint('🔄 Attempting token refresh...');

    try {
      final refreshResponse = await _userRepository.userRefreshToken();

      if (refreshResponse.accessToken?.isNotEmpty == true) {
        debugPrint('✅ Token refreshed successfully');

        await LocalStorageService.setString(
          LocalStorageConstant.accessToken,
          refreshResponse.accessToken!,
        );

        if (refreshResponse.refreshToken?.isNotEmpty == true) {
          await LocalStorageService.setString(
            LocalStorageConstant.refreshToken,
            refreshResponse.refreshToken!,
          );
        }

        // Reset refresh attempts after successful refresh
        ServiceLocator().offlineHttpService.resetRefreshAttempts();

        await _reconnectWebSocket();
        NavigationService().navigateToAndRemoveUntil(AppRoutes.home);
        return true;
      } else {
        debugPrint('❌ Token refresh returned empty token');
        return false;
      }
    } on DioException catch (refreshError) {
      final statusCode = refreshError.response?.statusCode;
      debugPrint('❌ Token refresh failed with status: $statusCode');

      // 🔥 FIX: Handle "User not found" during refresh
      if (statusCode != null) {
        final responseData = refreshError.response?.data;
        if (responseData is Map) {
          final errorMessage = responseData['error']?.toString().toLowerCase() ?? '';
          debugPrint('🔥 Refresh error message: $errorMessage');

          if (errorMessage.contains('user not found') ||
              errorMessage.contains('invalid user') ||
              errorMessage.contains('user does not exist')) {
            debugPrint('💀 User not found during refresh - will clear tokens');
            return false;
          }
        }
      }

      debugPrint('❌ Refresh failed for other reasons');
      return false;
    } catch (refreshError) {
      debugPrint('❌ Unexpected refresh error: $refreshError');
      return false;
    }
  }

  // 🔥 Reconnect WebSocket from stored user ID
  Future<void> _reconnectWebSocket() async {
    try {
      final storedUserId = LocalStorageService.getString(LocalStorageConstant.userId);

      if (storedUserId.isNotEmpty) {
        debugPrint('🔗 Reconnecting WebSocket for user ID: $storedUserId');
        _wsService.connect(storedUserId);
      } else {
        debugPrint('⚠️ No stored user ID found for WebSocket reconnection');
        debugPrint('   This might be a first-time login or data was cleared');
      }
    } catch (e) {
      debugPrint('❌ Failed to reconnect WebSocket: $e');
    }
  }

  Future<void> _clearTokens() async {
    debugPrint('🧹 Clearing tokens and disconnecting WebSocket');

    try {
      // Disconnect WebSocket before clearing tokens
      _wsService.disconnect();
    } catch (e) {
      debugPrint('⚠️ Error disconnecting WebSocket: $e');
    }

    await LocalStorageService.remove(LocalStorageConstant.accessToken);
    await LocalStorageService.remove(LocalStorageConstant.refreshToken);
    await LocalStorageService.remove(LocalStorageConstant.userGroup);
    await LocalStorageService.remove(LocalStorageConstant.userFirstName);
    await LocalStorageService.remove(LocalStorageConstant.userLastName);
    await LocalStorageService.remove(LocalStorageConstant.userEmail);
    await LocalStorageService.remove(LocalStorageConstant.userId);

    _user = null;
  }

  Future<void> logout(BuildContext context) async {
    try {
      debugPrint('👋 Logging out user');

      // Disconnect WebSocket first
      _wsService.disconnect();
      debugPrint('🔌 WebSocket disconnected');

      await _userRepository.userLogout();

      await LocalStorageService.remove(LocalStorageConstant.accessToken);
      await LocalStorageService.remove(LocalStorageConstant.refreshToken);
      await LocalStorageService.remove(LocalStorageConstant.userGroup);
      await LocalStorageService.remove(LocalStorageConstant.userFirstName);
      await LocalStorageService.remove(LocalStorageConstant.userLastName);
      await LocalStorageService.remove(LocalStorageConstant.userEmail);
      await LocalStorageService.remove(LocalStorageConstant.userId);

      _user = null;
      notifyListeners();

      NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
      debugPrint('✅ Logout complete');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      CommonSnackbar.showError(context, e.toString());
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _systemNoticeSubscription?.cancel();
    super.dispose();
  }
}
