import 'dart:async';

import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final _wsService = ServiceLocator().webSocketService;
  final List<NotificationModel> _notifications = [];
  StreamSubscription? _wsGeneralSubscription;
  StreamSubscription? _wsJobSubscription;
  StreamSubscription? _wsSystemSubscription;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _listenToWebSocket();
  }

  void _listenToWebSocket() {
    // Listen to general messages (your main notification channel)
    _wsGeneralSubscription = _wsService.generalMessages.listen((data) {
      debugPrint('📩 General WebSocket message received: ${data['type']}');
      _handleWebSocketMessage(data);
    });

    // Listen to job updates
    _wsJobSubscription = _wsService.jobUpdates.listen((data) {
      debugPrint('📩 Job update received');
      _handleWebSocketMessage(data);
    });

    // Listen to system notices
    _wsSystemSubscription = _wsService.systemNotices.listen((data) {
      debugPrint('📩 System notice received');
      _handleWebSocketMessage(data);
    });
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    try {
      final type = data['type'];
      debugPrint('🔔 Processing notification type: $type');

      // Handle your specific notification structure
      if (type == 'notification') {
        final notification = NotificationModel.fromWebSocket(data);
        _addNotification(notification);
        debugPrint('✅ Notification added: ${notification.title}');
      } else {
        // Handle other message types if needed
        debugPrint('⚠️ Unhandled message type: $type');
      }
    } catch (e) {
      debugPrint('❌ Error processing notification: $e');
    }
  }

  void _addNotification(NotificationModel notification) {
    // Check if notification already exists (prevent duplicates)
    if (!_notifications.any((n) => n.id == notification.id)) {
      _notifications.insert(0, notification);
      notifyListeners();
      debugPrint('📬 Notification added to list. Total: ${_notifications.length}');
    } else {
      debugPrint('⚠️ Duplicate notification ignored: ${notification.id}');
    }
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      debugPrint('✅ Notification marked as read: $notificationId');
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
    debugPrint('✅ All notifications marked as read');
  }

  void clearNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
    debugPrint('🗑️ Notification cleared: $notificationId');
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
    debugPrint('🗑️ All notifications cleared');
  }

  // Get notifications by job ID
  List<NotificationModel> getNotificationsByJob(String jobId) {
    return _notifications.where((n) => n.jobId == jobId).toList();
  }

  // Get notifications by customer ID
  List<NotificationModel> getNotificationsByCustomer(String customerId) {
    return _notifications.where((n) => n.customerId == customerId).toList();
  }

  @override
  void dispose() {
    _wsGeneralSubscription?.cancel();
    _wsJobSubscription?.cancel();
    _wsSystemSubscription?.cancel();
    super.dispose();
  }
}
