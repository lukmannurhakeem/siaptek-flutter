class ApprovalReportModel {
  final List<ApprovalReport>? data;
  final String? message;

  ApprovalReportModel({this.data, this.message});

  factory ApprovalReportModel.fromJson(Map<String, dynamic> json) {
    return ApprovalReportModel(
      data:
          json['data'] != null
              ? (json['data'] as List).map((e) => ApprovalReport.fromJson(e)).toList()
              : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data?.map((e) => e.toJson()).toList(), 'message': message};
  }
}

class ApprovalReport {
  final String? reportID;
  final String? reportTypeID;
  final String? reportName;
  final String? itemID;
  final String? itemNo;
  final String? status;
  final String? inspectedBy;
  final DateTime? reportDate;
  final String? regulation;
  final dynamic reportData;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? approvalStatus; // pending, approved, rejected
  final DateTime? inspectedOn;
  final String? inspectStatus;

  ApprovalReport({
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
  });

  factory ApprovalReport.fromJson(Map<String, dynamic> json) {
    return ApprovalReport(
      reportID: json['reportID'] as String?,
      reportTypeID: json['reportTypeID'] as String?,
      reportName: json['reportName'] as String?,
      itemID: json['itemID'] as String?,
      itemNo: json['itemNo'] as String?,
      status: json['status'] as String?,
      inspectedBy: json['inspectedBy'] as String?,
      reportDate:
          json['reportDate'] != null && json['reportDate'] != '0001-01-01T00:00:00Z'
              ? DateTime.parse(json['reportDate'] as String)
              : null,
      regulation: json['regulation'] as String?,
      reportData: json['reportData'],
      createdAt:
          json['createdAt'] != null && json['createdAt'] != '0001-01-01T00:00:00Z'
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null && json['updatedAt'] != '0001-01-01T00:00:00Z'
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      approvalStatus: json['approvalStatus'] as String?,
      inspectedOn:
          json['inspectedOn'] != null && json['inspectedOn'] != '0001-01-01T00:00:00Z'
              ? DateTime.parse(json['inspectedOn'] as String)
              : null,
      inspectStatus: json['inspectStatus'] as String?,
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
      'reportDate': reportDate?.toIso8601String(),
      'regulation': regulation,
      'reportData': reportData,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'approvalStatus': approvalStatus,
      'inspectedOn': inspectedOn?.toIso8601String(),
      'inspectStatus': inspectStatus,
    };
  }
}
