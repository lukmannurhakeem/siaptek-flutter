import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _userId;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final String baseWsUrl;
  final Duration reconnectDelay;
  final Duration pingInterval;

  // Stream controllers for different message types
  final _jobUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _systemNoticeController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _generalMessageController = StreamController<Map<String, dynamic>>.broadcast();

  // Expose streams
  Stream<Map<String, dynamic>> get jobUpdates => _jobUpdateController.stream;

  Stream<Map<String, dynamic>> get systemNotices => _systemNoticeController.stream;

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  Stream<Map<String, dynamic>> get generalMessages => _generalMessageController.stream;

  WebSocketService({
    required this.baseWsUrl,
    this.reconnectDelay = const Duration(seconds: 3),
    this.pingInterval = const Duration(seconds: 30),
  });

  bool get isConnected => _isConnected;

  String? get currentUserId => _userId;

  WebSocketChannel _connectChannel(String url) {
    if (kIsWeb) {
      return HtmlWebSocketChannel.connect(url);
    } else {
      return IOWebSocketChannel.connect(url);
    }
  }

  void connect(String userId) {
    _userId = userId;
    _reconnectTimer?.cancel();

    final url = '$baseWsUrl/api/v1/notifications/ws?userID=$userId';
    debugPrint('🔗 WS connecting: $url');

    try {
      _channel = _connectChannel(url);

      // ✅ Set connected immediately after channel is created
      _isConnected = true;
      _connectionStatusController.add(true);
      _startPingTimer();
      debugPrint('✅ WS Connected for user: $userId');

      _channel!.stream.listen(
        (event) {
          _handleIncoming(event);
        },
        onError: (err) {
          debugPrint('❌ WS Error: $err');
          _handleDisconnection();
        },
        onDone: () {
          debugPrint('🔌 WS Closed');
          _handleDisconnection();
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('❌ WS Connection failed: $e');
      _handleDisconnection();
    }
  }

  void _handleDisconnection() {
    if (_isConnected) {
      _isConnected = false;
      _connectionStatusController.add(false);
      _pingTimer?.cancel();
    }
    _reconnect();
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, (timer) {
      if (_isConnected) {
        send({'type': 'ping'});
      }
    });
  }

  void _reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      if (_userId != null && !_isConnected) {
        debugPrint('♻️ WS Reconnecting...');
        connect(_userId!);
      }
    });
  }

  void send(dynamic data) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (e) {
        debugPrint('❌ Failed to send WS message: $e');
      }
    }
  }

  void _handleIncoming(dynamic event) {
    debugPrint("📩 WS Message: $event");

    try {
      final json = jsonDecode(event.toString());
      _broadcastToProviders(json);
    } catch (e) {
      debugPrint("⚠️ Incoming WS is not JSON: $e");
    }
  }

  void _broadcastToProviders(Map<String, dynamic> json) {
    final type = json['type'];

    switch (type) {
      case 'job_update':
        debugPrint("📣 Broadcasting job update");
        _jobUpdateController.add(json);
        break;
      case 'system_notice':
        debugPrint("📣 Broadcasting system notice");
        _systemNoticeController.add(json);
        break;
      case 'pong':
        debugPrint("🏓 Pong received");
        break;
      default:
        debugPrint("📦 General message: $type");
        _generalMessageController.add(json);
    }
  }

  void disconnect() {
    debugPrint('🔌 Disconnecting WebSocket');
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _userId = null;
    _connectionStatusController.add(false);
  }

  void dispose() {
    disconnect();
    _jobUpdateController.close();
    _systemNoticeController.close();
    _connectionStatusController.close();
    _generalMessageController.close();
  }
}
