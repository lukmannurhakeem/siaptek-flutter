class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isSent;

  // Job-specific fields
  final String? jobId;
  final String? jobNumber;
  final String? jobStatus;
  final String? customerId;
  final String? customerName;
  final String? siteId;
  final String? siteName;
  final String? notificationType;

  final Map<String, dynamic>? rawData;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isSent = false,
    this.jobId,
    this.jobNumber,
    this.jobStatus,
    this.customerId,
    this.customerName,
    this.siteId,
    this.siteName,
    this.notificationType,
    this.rawData,
  });

  factory NotificationModel.fromWebSocket(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final timestamp =
        json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now();

    // Generate ID from timestamp and job number
    final id = '${timestamp.millisecondsSinceEpoch}_${data['jobNumber'] ?? ''}';

    return NotificationModel(
      id: id,
      type: json['type'] ?? 'notification',
      title: data['title'] ?? 'Notification',
      message: data['message'] ?? '',
      timestamp: timestamp,
      isRead: data['isRead'] ?? false,
      isSent: data['isSent'] ?? false,
      jobId: data['jobID'],
      jobNumber: data['jobNumber'],
      jobStatus: data['jobStatus'],
      customerId: data['customerID'],
      customerName: data['customerName'],
      siteId: data['siteID'],
      siteName: data['siteName'],
      notificationType: data['notificationType'],
      rawData: data,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isSent: isSent,
      jobId: jobId,
      jobNumber: jobNumber,
      jobStatus: jobStatus,
      customerId: customerId,
      customerName: customerName,
      siteId: siteId,
      siteName: siteName,
      notificationType: notificationType,
      rawData: rawData,
    );
  }

  // Helper to get priority based on notification type
  String get priority {
    switch (notificationType?.toLowerCase()) {
      case 'job_created':
        return 'medium';
      case 'job_updated':
        return 'medium';
      case 'job_completed':
        return 'low';
      case 'job_cancelled':
        return 'high';
      case 'urgent':
        return 'high';
      default:
        return 'medium';
    }
  }

  // Helper to get icon based on notification type
  String get iconType {
    switch (notificationType?.toLowerCase()) {
      case 'job_created':
        return 'work_outline';
      case 'job_updated':
        return 'update';
      case 'job_completed':
        return 'check_circle_outline';
      case 'job_cancelled':
        return 'cancel_outlined';
      default:
        return 'notifications_outlined';
    }
  }
}
