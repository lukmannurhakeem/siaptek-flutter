import 'package:INSPECT/core/service/local_storage.dart';
import 'package:INSPECT/core/service/local_storage_constant.dart';
import 'package:INSPECT/route/endpoint.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add access token to all requests that require auth
    final token = LocalStorageService.getString(LocalStorageConstant.accessToken);
    if (token.isNotEmpty && !options.path.contains('login')) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If we get a 401 (Unauthorized), try to refresh the token
    if (err.response?.statusCode == 401) {
      try {
        // Get refresh token
        final refreshToken = LocalStorageService.getString(LocalStorageConstant.refreshToken);

        if (refreshToken.isEmpty) {
          return handler.reject(err); // No refresh token, can't recover
        }

        // Try to refresh the access token
        final response = await _dio.post(
          Endpoint.refreshToken,
          data: {'refresh_token': refreshToken},
        );

        // Save new tokens
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await LocalStorageService.setString(LocalStorageConstant.accessToken, newAccessToken);
        await LocalStorageService.setString(LocalStorageConstant.refreshToken, newRefreshToken);

        // Retry the original request with new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(options);
        return handler.resolve(retryResponse);
      } catch (e) {
        // Token refresh failed, user needs to login again
        print('Token refresh failed: $e');

        // Clear tokens
        await LocalStorageService.remove(LocalStorageConstant.accessToken);
        await LocalStorageService.remove(LocalStorageConstant.refreshToken);

        return handler.reject(err);
      }
    }

    super.onError(err, handler);
  }
}
