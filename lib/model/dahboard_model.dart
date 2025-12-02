// dashboard_model.dart
class DashboardModel {
  final CustomerData? customer;
  final List<SiteData>? sites;
  final List<JobData>? jobs;
  final List<ItemData>? jobItems;
  final List<ReportData>? reports;
  final StatisticsData? statistics;

  DashboardModel({
    this.customer,
    this.sites,
    this.jobs,
    this.jobItems,
    this.reports,
    this.statistics,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      customer: json['customer'] != null ? CustomerData.fromJson(json['customer']) : null,
      sites:
          json['sites'] != null
              ? (json['sites'] as List).map((site) => SiteData.fromJson(site)).toList()
              : null,
      jobs:
          json['jobs'] != null
              ? (json['jobs'] as List).map((job) => JobData.fromJson(job)).toList()
              : null,
      jobItems:
          json['jobItems'] != null
              ? (json['jobItems'] as List).map((item) => ItemData.fromJson(item)).toList()
              : null,
      reports:
          json['reports'] != null
              ? (json['reports'] as List).map((report) => ReportData.fromJson(report)).toList()
              : null,
      statistics: json['statistics'] != null ? StatisticsData.fromJson(json['statistics']) : null,
    );
  }
}

class CustomerData {
  final String? customerId;
  final String? customerName;
  final String? siteCode;
  final String? accountCode;
  final String? agent;
  final String? notes;
  final String? division;
  final String? logo;
  final String? address;
  final String? email;
  final bool? archived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerData({
    this.customerId,
    this.customerName,
    this.siteCode,
    this.accountCode,
    this.agent,
    this.notes,
    this.division,
    this.logo,
    this.address,
    this.email,
    this.archived,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      customerId: json['customerId'],
      customerName: json['customerName'],
      siteCode: json['siteCode'],
      accountCode: json['accountCode'],
      agent: json['agent'],
      notes: json['notes'],
      division: json['division'],
      logo: json['logo'],
      address: json['address'],
      email: json['email'],
      archived: json['archived'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class SiteData {
  final String? siteId;
  final String? siteCode;
  final String? siteName;
  final String? customerId;
  final String? area;
  final String? description;
  final String? notes;
  final String? division;
  final String? logo;
  final String? address;
  final bool? archived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SiteData({
    this.siteId,
    this.siteCode,
    this.siteName,
    this.customerId,
    this.area,
    this.description,
    this.notes,
    this.division,
    this.logo,
    this.address,
    this.archived,
    this.createdAt,
    this.updatedAt,
  });

  factory SiteData.fromJson(Map<String, dynamic> json) {
    return SiteData(
      siteId: json['siteId'],
      siteCode: json['siteCode'],
      siteName: json['siteName'],
      customerId: json['customerId'],
      area: json['area'],
      description: json['description'],
      notes: json['notes'],
      division: json['division'],
      logo: json['logo'],
      address: json['address'],
      archived: json['archived'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class JobData {
  final String? jobId;
  final String? jobNo;
  final String? jobName;
  final String? customerId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobData({
    this.jobId,
    this.jobNo,
    this.jobName,
    this.customerId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(
      jobId: json['jobId'],
      jobNo: json['jobNo'],
      jobName: json['jobName'],
      customerId: json['customerId'],
      status: json['status'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class ItemData {
  final String? itemId;
  final String? jobId;
  final String? jobNo;
  final String? itemNo;
  final String? categoryId;
  final String? categoryName;
  final String? rfidNo;
  final String? locationId;
  final String? detailedLocation;
  final String? internalNotes;
  final String? externalNotes;
  final String? manufacturer;
  final String? manufacturerAddress;
  final DateTime? manufacturerDate;
  final DateTime? firstUseDate;
  final DateTime? outOfServiceDate;
  final String? swl;
  final String? photoReference;
  final String? standardReference;
  final String? serialNumber;
  final double? tareWeight;
  final double? payLoad;
  final double? maxGrossWeight;
  final String? inspectionStatus;
  final String? description;
  final String? status;
  final DateTime? expiryDateTimeStamp;
  final bool? archived;
  final bool? canInspectItem;
  final bool? isActive;
  final bool? isApproved;

  ItemData({
    this.itemId,
    this.jobId,
    this.jobNo,
    this.itemNo,
    this.categoryId,
    this.categoryName,
    this.rfidNo,
    this.locationId,
    this.detailedLocation,
    this.internalNotes,
    this.externalNotes,
    this.manufacturer,
    this.manufacturerAddress,
    this.manufacturerDate,
    this.firstUseDate,
    this.outOfServiceDate,
    this.swl,
    this.photoReference,
    this.standardReference,
    this.serialNumber,
    this.tareWeight,
    this.payLoad,
    this.maxGrossWeight,
    this.inspectionStatus,
    this.description,
    this.status,
    this.expiryDateTimeStamp,
    this.archived,
    this.canInspectItem,
    this.isActive,
    this.isApproved,
  });

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      itemId: json['itemId'],
      jobId: json['jobId'],
      jobNo: json['jobNo'],
      itemNo: json['itemNo'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      rfidNo: json['rfidNo'],
      locationId: json['locationId'],
      detailedLocation: json['detailedLocation'],
      internalNotes: json['internalNotes'],
      externalNotes: json['externalNotes'],
      manufacturer: json['manufacturer'],
      manufacturerAddress: json['manufacturerAddress'],
      manufacturerDate:
          json['manufacturerDate'] != null ? DateTime.parse(json['manufacturerDate']) : null,
      firstUseDate: json['firstUseDate'] != null ? DateTime.parse(json['firstUseDate']) : null,
      outOfServiceDate:
          json['outOfServiceDate'] != null ? DateTime.parse(json['outOfServiceDate']) : null,
      swl: json['swl'],
      photoReference: json['photoReference'],
      standardReference: json['standardReference'],
      serialNumber: json['serialNumber'],
      tareWeight: json['tareWeight']?.toDouble(),
      payLoad: json['payLoad']?.toDouble(),
      maxGrossWeight: json['maxGrossWeight']?.toDouble(),
      inspectionStatus: json['inspectionStatus'],
      description: json['description'],
      status: json['status'],
      expiryDateTimeStamp:
          json['expiryDateTimeStamp'] != null ? DateTime.parse(json['expiryDateTimeStamp']) : null,
      archived: json['archived'],
      canInspectItem: json['canInspectItem'],
      isActive: json['isActive'],
      isApproved: json['isApproved'],
    );
  }
}

class ReportData {
  final String? reportId;
  final String? reportTypeId;
  final String? reportTypeName;
  final String? itemId;
  final String? itemNo;
  final String? status;
  final String? inspectedBy;
  final String? inspectorName;
  final DateTime? reportDate;
  final String? regulation;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? approvalStatus;
  final DateTime? inspectedOn;
  final String? inspectStatus;
  final DateTime? expiryDate;

  ReportData({
    this.reportId,
    this.reportTypeId,
    this.reportTypeName,
    this.itemId,
    this.itemNo,
    this.status,
    this.inspectedBy,
    this.inspectorName,
    this.reportDate,
    this.regulation,
    this.createdAt,
    this.updatedAt,
    this.approvalStatus,
    this.inspectedOn,
    this.inspectStatus,
    this.expiryDate,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      reportId: json['reportId'],
      reportTypeId: json['reportTypeId'],
      reportTypeName: json['reportTypeName'],
      itemId: json['itemId'],
      itemNo: json['itemNo'],
      status: json['status'],
      inspectedBy: json['inspectedBy'],
      inspectorName: json['inspectorName'],
      reportDate: json['reportDate'] != null ? DateTime.parse(json['reportDate']) : null,
      regulation: json['regulation'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      approvalStatus: json['approvalStatus'],
      inspectedOn: json['inspectedOn'] != null ? DateTime.parse(json['inspectedOn']) : null,
      inspectStatus: json['inspectStatus'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }
}

class StatisticsData {
  final int? totalSites;
  final int? activeSites;
  final int? totalJobs;
  final int? activeJobs;
  final int? completedJobs;
  final int? totalItems;
  final int? activeItems;
  final int? totalReports;
  final int? pendingReports;
  final int? approvedReports;
  final int? totalNotifications;
  final int? unreadNotifications;
  final Map<String, dynamic>? jobsByStatus;
  final Map<String, dynamic>? itemsByStatus;
  final Map<String, dynamic>? reportsByStatus;
  final Map<String, dynamic>? notificationsByType;

  StatisticsData({
    this.totalSites,
    this.activeSites,
    this.totalJobs,
    this.activeJobs,
    this.completedJobs,
    this.totalItems,
    this.activeItems,
    this.totalReports,
    this.pendingReports,
    this.approvedReports,
    this.totalNotifications,
    this.unreadNotifications,
    this.jobsByStatus,
    this.itemsByStatus,
    this.reportsByStatus,
    this.notificationsByType,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      totalSites: json['totalSites'],
      activeSites: json['activeSites'],
      totalJobs: json['totalJobs'],
      activeJobs: json['activeJobs'],
      completedJobs: json['completedJobs'],
      totalItems: json['totalItems'],
      activeItems: json['activeItems'],
      totalReports: json['totalReports'],
      pendingReports: json['pendingReports'],
      approvedReports: json['approvedReports'],
      totalNotifications: json['totalNotifications'],
      unreadNotifications: json['unreadNotifications'],
      jobsByStatus: json['jobsByStatus'],
      itemsByStatus: json['itemsByStatus'],
      reportsByStatus: json['reportsByStatus'],
      notificationsByType: json['notificationsByType'],
    );
  }
}

// Response wrapper models
class DashboardResponse {
  final bool success;
  final String message;
  final DashboardModel data;

  DashboardResponse({required this.success, required this.message, required this.data});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DashboardModel.fromJson(json['data'] ?? {}),
    );
  }
}

class StatisticsResponse {
  final bool success;
  final String message;
  final StatisticsData data;

  StatisticsResponse({required this.success, required this.message, required this.data});

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StatisticsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ItemsResponse {
  final bool success;
  final String message;
  final List<ItemData> data;
  final int count;

  ItemsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.count,
  });

  factory ItemsResponse.fromJson(Map<String, dynamic> json) {
    return ItemsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((item) => ItemData.fromJson(item)).toList() ?? [],
      count: json['count'] ?? 0,
    );
  }
}
