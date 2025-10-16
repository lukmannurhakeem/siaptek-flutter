import 'package:base_app/core/service/local_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class OfflineHttpService {
  final Dio _dio;
  static const String _queueKey = 'pending_requests';
  static const String _cachePrefix = 'cache_';

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

    // Start auto-sync on connectivity changes
    _startAutoSync();
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

  // Get authorization header
  Map<String, dynamic> _getAuthHeaders() {
    final token = LocalStorageService.getString('access_token');
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
      print('Cache save error: $e');
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
      print('Cache read error: $e');
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
      print('Queue add error: $e');
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
      print('Queue remove error: $e');
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

    // Try online request first
    if (isOnline) {
      try {
        final opts = options ?? Options();
        if (requiresAuth) {
          opts.headers = {...?opts.headers, ..._getAuthHeaders()};
        }

        final response = await _dio.get(path, queryParameters: queryParameters, options: opts);

        // Cache successful response
        await _saveToCache(cacheKey, response.data);
        return response;
      } catch (e) {
        print('Online request failed, trying cache: $e');
        // Fall through to cache
      }
    }

    // Use cache if offline or request failed
    final cachedData = _getFromCache(cacheKey);
    if (cachedData != null) {
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
        final opts = options ?? Options();
        if (requiresAuth) {
          opts.headers = {...?opts.headers, ..._getAuthHeaders()};
        }

        return await _dio.post(path, data: data, queryParameters: queryParameters, options: opts);
      } catch (e) {
        print('Online POST failed: $e');
        // Fall through to queue
      }
    }

    // Queue request for later sync
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
        final opts = options ?? Options();
        if (requiresAuth) {
          opts.headers = {...?opts.headers, ..._getAuthHeaders()};
        }

        return await _dio.put(path, data: data, queryParameters: queryParameters, options: opts);
      } catch (e) {
        print('Online PUT failed: $e');
      }
    }

    // Queue request
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
        final opts = options ?? Options();
        if (requiresAuth) {
          opts.headers = {...?opts.headers, ..._getAuthHeaders()};
        }

        return await _dio.delete(path, data: data, queryParameters: queryParameters, options: opts);
      } catch (e) {
        print('Online DELETE failed: $e');
      }
    }

    // Queue request
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

    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'message': 'Request queued for sync', 'queued': true, 'requestId': requestId},
      statusCode: 202,
      statusMessage: 'Queued',
    );
  }

  // Sync all pending requests
  Future<SyncResult> syncPendingRequests() async {
    final queue = _getQueue();
    int success = 0;
    int failed = 0;
    List<String> failedIds = [];

    for (final request in queue) {
      try {
        final opts = Options();
        if (request['requiresAuth'] == true) {
          opts.headers = _getAuthHeaders();
        }

        switch (request['method']) {
          case 'POST':
            await _dio.post(
              request['path'],
              data: request['data'],
              queryParameters: request['queryParameters'],
              options: opts,
            );
            break;
          case 'PUT':
            await _dio.put(
              request['path'],
              data: request['data'],
              queryParameters: request['queryParameters'],
              options: opts,
            );
            break;
          case 'DELETE':
            await _dio.delete(
              request['path'],
              data: request['data'],
              queryParameters: request['queryParameters'],
              options: opts,
            );
            break;
        }

        await _removeFromQueue(request['id']);
        success++;
      } catch (e) {
        print('Sync failed for ${request['id']}: $e');
        failed++;
        failedIds.add(request['id']);
      }
    }

    return SyncResult(total: queue.length, success: success, failed: failed, failedIds: failedIds);
  }

  // Get pending requests count
  int getPendingCount() {
    return _getQueue().length;
  }

  // Clear all pending requests
  Future<bool> clearPendingRequests() async {
    return await LocalStorageService.remove(_queueKey);
  }

  // Auto-sync when connectivity changes
  void _startAutoSync() {
    Connectivity().onConnectivityChanged.listen((result) async {
      final isConnected = !result.contains(ConnectivityResult.none);
      if (isConnected && getPendingCount() > 0) {
        print('Connection restored, syncing pending requests...');
        final result = await syncPendingRequests();
        print('Sync completed: ${result.success}/${result.total} successful');
      }
    });
  }

  // Manual sync trigger
  Future<SyncResult> syncNow() async {
    final isOnline = await _isOnline();
    if (!isOnline) {
      throw Exception('Cannot sync: Device is offline');
    }
    return await syncPendingRequests();
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
