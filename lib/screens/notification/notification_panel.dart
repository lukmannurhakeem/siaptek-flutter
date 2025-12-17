import 'package:INSPECT/providers/notification_provider.dart';
import 'package:INSPECT/screens/notification/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, provider, child) {
                        return Row(
                          children: [
                            TextButton(
                              onPressed:
                                  provider.notifications.isEmpty ? null : provider.markAllAsRead,
                              child: const Text('Mark all read'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed:
                                  provider.notifications.isEmpty
                                      ? null
                                      : () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text('Clear All'),
                                                content: const Text(
                                                  'Are you sure you want to clear all notifications?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      provider.clearAllNotifications();
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Clear'),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Notifications List
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      itemCount: provider.notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notification = provider.notifications[index];
                        return NotificationTile(notification: notification);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
