// Add this model to your models folder: lib/model/report_approval_model.dart

class ReportApprovalModel {
  final List<ReportApprovalData>? data;
  final ApprovalFilter? filter;
  final String? message;

  ReportApprovalModel({this.data, this.filter, this.message});

  factory ReportApprovalModel.fromJson(Map<String, dynamic> json) {
    return ReportApprovalModel(
      data:
          json['data'] != null
              ? (json['data'] as List).map((item) => ReportApprovalData.fromJson(item)).toList()
              : null,
      filter: json['filter'] != null ? ApprovalFilter.fromJson(json['filter']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((item) => item.toJson()).toList(),
      'filter': filter?.toJson(),
      'message': message,
    };
  }
}

class ReportApprovalData {
  final String? reportID;
  final String? reportTypeID;
  final String? reportName;
  final String? itemID;
  final String? itemNo;
  final String? status;
  final String? inspectedBy;
  final String? reportDate;
  final String? regulation;
  final dynamic reportData;
  final String? createdAt;
  final String? updatedAt;
  final String? approvalStatus;
  final String? inspectedOn;
  final String? inspectStatus;
  final String? expiryDate;
  final String? ExpiryDate; // Note: Capital E as per your API

  ReportApprovalData({
    this.reportID,
    this.reportTypeID,
    this.reportName,
    this.itemID,
    this.itemNo,
    this.status,
    this.inspectedBy,
    this.reportDate,
    this.regulation,
    this.reportData,
    this.createdAt,
    this.updatedAt,
    this.approvalStatus,
    this.inspectedOn,
    this.inspectStatus,
    this.expiryDate,
    this.ExpiryDate,
  });

  factory ReportApprovalData.fromJson(Map<String, dynamic> json) {
    return ReportApprovalData(
      reportID: json['reportID'],
      reportTypeID: json['reportTypeID'],
      reportName: json['reportName'],
      itemID: json['itemID'],
      itemNo: json['itemNo'],
      status: json['status'],
      inspectedBy: json['inspectedBy'],
      reportDate: json['reportDate'],
      regulation: json['regulation'],
      reportData: json['reportData'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      approvalStatus: json['approvalStatus'],
      inspectedOn: json['inspectedOn'],
      inspectStatus: json['inspectStatus'],
      expiryDate: json['expiryDate'],
      ExpiryDate: json['ExpiryDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportID': reportID,
      'reportTypeID': reportTypeID,
      'reportName': reportName,
      'itemID': itemID,
      'itemNo': itemNo,
      'status': status,
      'inspectedBy': inspectedBy,
      'reportDate': reportDate,
      'regulation': regulation,
      'reportData': reportData,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'approvalStatus': approvalStatus,
      'inspectedOn': inspectedOn,
      'inspectStatus': inspectStatus,
      'expiryDate': expiryDate,
      'ExpiryDate': ExpiryDate,
    };
  }

  DateTime? get reportDateTime {
    if (reportDate == null) return null;
    try {
      return DateTime.parse(reportDate!);
    } catch (e) {
      return null;
    }
  }

  DateTime? get expiryDateTime {
    if (ExpiryDate == null) return null;
    try {
      return DateTime.parse(ExpiryDate!);
    } catch (e) {
      return null;
    }
  }

  String get displayInspector {
    if (inspectedBy != null && inspectedBy!.isNotEmpty) {
      return inspectedBy!;
    }
    return 'Not Assigned';
  }
}

class ApprovalFilter {
  final bool? isApproved;
  final String? jobID;

  ApprovalFilter({this.isApproved, this.jobID});

  factory ApprovalFilter.fromJson(Map<String, dynamic> json) {
    return ApprovalFilter(isApproved: json['isApproved'], jobID: json['jobID']);
  }

  Map<String, dynamic> toJson() {
    return {'isApproved': isApproved, 'jobID': jobID};
  }
}
