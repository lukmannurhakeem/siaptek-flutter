import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  final Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  ApiClient(this._dio) {
    _dio.options.connectTimeout = const Duration(milliseconds: 5000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 3000);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptors
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
      ),
    );
  }

  // Token management methods
  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  String? get accessToken => _accessToken;

  void setRefreshToken(String token) {
    _refreshToken = token;
  }

  void clearRefreshToken() {
    _refreshToken = null;
  }

  String? get refreshToken => _refreshToken;

  // Helper method to create options with authorization header
  Options _createOptionsWithAuth({Options? options}) {
    final newOptions = options ?? Options();

    if (_accessToken != null) {
      newOptions.headers = {
        ...?newOptions.headers,
        'Authorization': 'Bearer $_accessToken',
      };
    }

    return newOptions;
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    try {
      final requestOptions = requiresAuth ? _createOptionsWithAuth(options: options) : options;

      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    try {
      final requestOptions = requiresAuth ? _createOptionsWithAuth(options: options) : options;

      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    try {
      final requestOptions = requiresAuth ? _createOptionsWithAuth(options: options) : options;

      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    try {
      final requestOptions = requiresAuth ? _createOptionsWithAuth(options: options) : options;

      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException error) {
    String errorMessage = 'An error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'Bad response: ${error.response?.statusCode}';
        if (error.response?.data != null) {
          errorMessage += ' - ${error.response?.data}';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Unknown error: ${error.message}';
        break;
      default:
        errorMessage = 'Something went wrong';
        break;
    }

    return Exception(errorMessage);
  }
}
