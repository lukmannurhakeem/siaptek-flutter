import 'package:INSPECT/core/service/local_storage.dart';
import 'package:INSPECT/core/service/local_storage_constant.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/core/service/service_locator.dart';
import 'package:INSPECT/repositories/user/user_repository.dart';
import 'package:INSPECT/route/route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class OfflineHttpService {
  final Dio _dio;

  UserRepository get _userRepository => ServiceLocator().userRepository;

  static const String _queueKey = 'pending_requests';
  static const String _cachePrefix = 'cache_';

  bool _isRefreshing = false;
  int _refreshAttempts = 0;
  static const int _maxRefreshAttempts = 3;

  OfflineHttpService(this._dio) {
    _dio.options.connectTimeout = const Duration(milliseconds: 5000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 3000);
    _dio.options.headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
      ),
    );

    // Add token refresh interceptor
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = LocalStorageService.getString(LocalStorageConstant.accessToken);
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;

          // Handle authentication errors (401, 403)
          if (statusCode == 401 || statusCode == 403) {
            debugPrint('🔒 Auth error detected: $statusCode');

            if (_isRefreshing) {
              debugPrint('⏳ Already refreshing token, queuing request...');
              return handler.next(error);
            }

            if (_refreshAttempts >= _maxRefreshAttempts) {
              debugPrint('❌ Max refresh attempts reached, logging out...');
              await _handleLogout('Maximum token refresh attempts exceeded');
              return handler.next(error);
            }

            _isRefreshing = true;
            _refreshAttempts++;

            debugPrint(
              '🔄 Attempting token refresh (attempt $_refreshAttempts/$_maxRefreshAttempts)',
            );
            final refreshed = await _refreshAccessToken();

            _isRefreshing = false;

            if (refreshed) {
              _refreshAttempts = 0;

              try {
                final options = error.requestOptions;
                final newToken = LocalStorageService.getString(LocalStorageConstant.accessToken);
                options.headers['Authorization'] = 'Bearer $newToken';

                debugPrint('✅ Retrying original request with new token');
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                debugPrint('❌ Retry failed: $e');
                return handler.next(error);
              }
            } else {
              debugPrint('❌ Token refresh failed, logging out...');
              await _handleLogout('Session expired. Please login again.');
              return handler.next(error);
            }
          }

          // Handle server errors (500+) - could indicate user not found or other critical errors
          if (statusCode != null && statusCode >= 500) {
            debugPrint('🔥 Server error detected: $statusCode');

            // Check if it's an auth-related server error
            final responseData = error.response?.data;
            if (responseData is Map) {
              final errorMessage = responseData['error']?.toString().toLowerCase() ?? '';

              // If error mentions user/auth issues, logout
              if (errorMessage.contains('user not found') ||
                  errorMessage.contains('invalid user') ||
                  errorMessage.contains('user does not exist') ||
                  errorMessage.contains('authentication') ||
                  errorMessage.contains('unauthorized')) {
                debugPrint('❌ Auth-related server error, logging out...');
                await _handleLogout('User session invalid. Please login again.');
                return handler.next(error);
              }
            }
          }

          handler.next(error);
        },
      ),
    );

    _startAutoSync();
  }

  // Handle logout and navigation
  Future<void> _handleLogout(String reason) async {
    try {
      debugPrint('🚪 Forcing logout: $reason');

      // Clear all tokens
      await LocalStorageService.remove(LocalStorageConstant.accessToken);
      await LocalStorageService.remove(LocalStorageConstant.refreshToken);
      await LocalStorageService.remove(LocalStorageConstant.userGroup);
      await LocalStorageService.remove(LocalStorageConstant.userFirstName);
      await LocalStorageService.remove(LocalStorageConstant.userLastName);
      await LocalStorageService.remove(LocalStorageConstant.userEmail);
      await LocalStorageService.remove(LocalStorageConstant.userId);

      // Reset refresh attempts
      _refreshAttempts = 0;
      _isRefreshing = false;

      // Disconnect WebSocket if available
      try {
        ServiceLocator().webSocketService.disconnect();
        debugPrint('🔌 WebSocket disconnected');
      } catch (e) {
        debugPrint('⚠️ Could not disconnect WebSocket: $e');
      }

      // Navigate to login with error message
      NavigationService().navigateToAndRemoveUntil(
        AppRoutes.login,
        arguments: {'errorMessage': reason},
      );

      debugPrint('✅ Logged out and redirected to login');
    } catch (e) {
      debugPrint('❌ Error during forced logout: $e');
      // Even if there's an error, still try to navigate to login
      NavigationService().navigateToAndRemoveUntil(AppRoutes.login);
    }
  }

  // Refresh Access Token using UserRepository
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = LocalStorageService.getString(LocalStorageConstant.refreshToken);

      if (refreshToken.isEmpty) {
        debugPrint('❌ No refresh token available');
        return false;
      }

      debugPrint('🔄 Refreshing access token...');

      // 🔥 IMPORTANT: This call should NOT trigger the interceptor's refresh logic
      // The interceptor should let this error pass through
      final refreshResponse = await _userRepository.userRefreshToken();

      if (refreshResponse.accessToken?.isNotEmpty == true) {
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

        debugPrint('✅ Token refreshed successfully');
        return true;
      }

      debugPrint('❌ Token refresh returned empty token');
      return false;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      debugPrint('❌ Token refresh failed with status: $statusCode');

      // 🔥 FIX: If refresh fails with 500 (user not found), force logout immediately
      if (statusCode != null && statusCode >= 500) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          final errorMessage = responseData['error']?.toString().toLowerCase() ?? 'Server error';
          debugPrint('🔥 Refresh server error: $errorMessage');

          // Force logout for user-related errors
          if (errorMessage.contains('user not found') ||
              errorMessage.contains('invalid user') ||
              errorMessage.contains('user does not exist')) {
            debugPrint('💀 User not found during refresh - forcing logout');

            // Use a delayed navigation to ensure it happens after the current execution
            Future.microtask(() async {
              await _handleLogout('Your account could not be found. Please login again.');
            });
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Token refresh failed: $e');
      return false;
    }
  }

  // Check connectivity
  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Generate cache key from request
  String _generateCacheKey(String path, Map<String, dynamic>? queryParams) {
    final query = queryParams?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? '';
    return _cachePrefix + path + (query.isNotEmpty ? '?$query' : '');
  }

  // Get authorization header (for backward compatibility)
  Map<String, dynamic> _getAuthHeaders() {
    final token = LocalStorageService.getString(LocalStorageConstant.accessToken);
    if (token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }

  // Save to cache
  Future<void> _saveToCache(String cacheKey, dynamic data) async {
    try {
      if (data != null) {
        await LocalStorageService.setJson(cacheKey, {
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('❌ Cache save error: $e');
    }
  }

  // Get from cache
  dynamic _getFromCache(String cacheKey) {
    try {
      final cached = LocalStorageService.getJson(cacheKey);
      if (cached != null) {
        return cached['data'];
      }
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
    }
    return null;
  }

  // Add request to queue
  Future<void> _addToQueue(Map<String, dynamic> request) async {
    try {
      final queue = LocalStorageService.getJsonList(_queueKey);
      queue.add(request);
      await LocalStorageService.setJsonList(_queueKey, queue);
    } catch (e) {
      debugPrint('❌ Queue add error: $e');
    }
  }

  // Get pending queue
  List<Map<String, dynamic>> _getQueue() {
    return LocalStorageService.getJsonList(_queueKey);
  }

  // Remove from queue
  Future<void> _removeFromQueue(String requestId) async {
    try {
      final queue = _getQueue();
      queue.removeWhere((req) => req['id'] == requestId);
      await LocalStorageService.setJsonList(_queueKey, queue);
    } catch (e) {
      debugPrint('❌ Queue remove error: $e');
    }
  }

  // GET request - automatically uses cache when offline
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    final isOnline = await _isOnline();
    final cacheKey = _generateCacheKey(path, queryParameters);

    if (isOnline) {
      try {
        final opts = options ?? Options();
        final response = await _dio.get(path, queryParameters: queryParameters, options: opts);
        await _saveToCache(cacheKey, response.data);
        return response;
      } catch (e) {
        debugPrint('❌ Online request failed, trying cache: $e');
      }
    }

    final cachedData = _getFromCache(cacheKey);
    if (cachedData != null) {
      debugPrint('📦 Serving from cache: $path');
      return Response(
        requestOptions: RequestOptions(path: path),
        data: cachedData,
        statusCode: 200,
        statusMessage: 'From Cache',
      );
    }

    throw Exception('No cached data available and device is offline');
  }

  // POST request - automatically queues when offline
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        return await _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      } catch (e) {
        debugPrint('❌ Online POST failed: $e');
      }
    }

    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    await _addToQueue({
      'id': requestId,
      'method': 'POST',
      'path': path,
      'data': data,
      'queryParameters': queryParameters,
      'requiresAuth': requiresAuth,
      'timestamp': DateTime.now().toIso8601String(),
    });

    debugPrint('📥 Request queued: POST $path');
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Request queued for sync', 'queued': true, 'requestId': requestId},
      statusCode: 202,
      statusMessage: 'Queued',
    );
  }

  // PUT request - automatically queues when offline
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
      } catch (e) {
        debugPrint('❌ Online PUT failed: $e');
      }
    }

    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    await _addToQueue({
      'id': requestId,
      'method': 'PUT',
      'path': path,
      'data': data,
      'queryParameters': queryParameters,
      'requiresAuth': requiresAuth,
      'timestamp': DateTime.now().toIso8601String(),
    });

    debugPrint('📥 Request queued: PUT $path');
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Request queued for sync', 'queued': true, 'requestId': requestId},
      statusCode: 202,
      statusMessage: 'Queued',
    );
  }

  // DELETE request - automatically queues when offline
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    final isOnline = await _isOnline();

    if (isOnline) {
      try {
        return await _dio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      } catch (e) {
        debugPrint('❌ Online DELETE failed: $e');
      }
    }

    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    await _addToQueue({
      'id': requestId,
      'method': 'DELETE',
      'path': path,
      'data': data,
      'queryParameters': queryParameters,
      'requiresAuth': requiresAuth,
      'timestamp': DateTime.now().toIso8601String(),
    });

    debugPrint('📥 Request queued: DELETE $path');
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Request queued for sync', 'queued': true, 'requestId': requestId},
      statusCode: 202,
      statusMessage: 'Queued',
    );
  }

  // GET binary data (PDF, images, etc.)
  Future<Response<List<int>>> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    final isOnline = await _isOnline();

    if (!isOnline) {
      throw Exception('Cannot download file: Device is offline');
    }

    try {
      final opts = options ?? Options();
      opts.responseType = ResponseType.bytes;
      opts.headers = {...?opts.headers, 'Accept': 'application/pdf, application/octet-stream, */*'};

      final response = await _dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: opts,
      );

      return response as Response<List<int>>;
    } on DioException catch (e) {
      throw Exception('Failed to download binary data: ${e.message}');
    }
  }

  // Sync all pending requests
  Future<SyncResult> syncPendingRequests() async {
    final queue = _getQueue();
    int success = 0;
    int failed = 0;
    List<String> failedIds = [];

    debugPrint('🔄 Syncing ${queue.length} pending requests...');

    for (final request in queue) {
      try {
        switch (request['method']) {
          case 'POST':
            await _dio.post(
              request['path'],
              data: request['data'],
              queryParameters: request['queryParameters'],
            );
            break;
          case 'PUT':
            await _dio.put(
              request['path'],
              data: request['data'],
              queryParameters: request['queryParameters'],
            );
            break;
          case 'DELETE':
            await _dio.delete(
              request['path'],
              data: request['data'],
              queryParameters: request['queryParameters'],
            );
            break;
        }

        await _removeFromQueue(request['id']);
        success++;
        debugPrint('✅ Synced: ${request['method']} ${request['path']}');
      } catch (e) {
        debugPrint('❌ Sync failed for ${request['id']}: $e');
        failed++;
        failedIds.add(request['id']);
      }
    }

    debugPrint('📊 Sync complete: $success/${queue.length} successful, $failed failed');
    return SyncResult(total: queue.length, success: success, failed: failed, failedIds: failedIds);
  }

  int getPendingCount() => _getQueue().length;

  Future<bool> clearPendingRequests() async {
    return await LocalStorageService.remove(_queueKey);
  }

  // Auto-sync when connectivity changes
  void _startAutoSync() {
    Connectivity().onConnectivityChanged.listen((result) async {
      final isConnected = !result.contains(ConnectivityResult.none);
      if (isConnected && getPendingCount() > 0) {
        debugPrint('🌐 Connection restored, syncing pending requests...');
        final result = await syncPendingRequests();
        debugPrint('📊 Sync result: ${result.success}/${result.total} successful');
      }
    });
  }

  Future<SyncResult> syncNow() async {
    final isOnline = await _isOnline();
    if (!isOnline) {
      throw Exception('Cannot sync: Device is offline');
    }
    return await syncPendingRequests();
  }

  // Reset refresh attempts (call this after successful login)
  void resetRefreshAttempts() {
    _refreshAttempts = 0;
    _isRefreshing = false;
    debugPrint('🔄 Refresh attempts reset');
  }
}

class SyncResult {
  final int total;
  final int success;
  final int failed;
  final List<String> failedIds;

  SyncResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.failedIds,
  });

  bool get isSuccess => failed == 0 && total > 0;

  bool get hasFailures => failed > 0;

  bool get isEmpty => total == 0;
}
