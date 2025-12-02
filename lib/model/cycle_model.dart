class CycleData {
  final String? cycleId;
  final String? reportTypeId;
  final String? customerId;
  final String? siteId;
  final String? unit;
  final int? length;
  final int? minLength;
  final int? maxLength;
  final String? reportTypeName;
  final String? customerName;
  final String? siteName;

  CycleData({
    this.cycleId,
    this.reportTypeId,
    this.customerId,
    this.siteId,
    this.unit,
    this.length,
    this.minLength,
    this.maxLength,
    this.reportTypeName,
    this.customerName,
    this.siteName,
  });

  factory CycleData.fromJson(Map<String, dynamic> json) {
    return CycleData(
      cycleId: json['cycleID'],
      reportTypeId: json['reportTypeID'],
      customerId: json['customerID'],
      siteId: json['siteID'],
      unit: json['unit'],
      length: json['length'],
      minLength: json['minLength'],
      maxLength: json['maxLength'],
      reportTypeName: json['reportTypeName'],
      customerName: json['customerName'],
      siteName: json['siteName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cycleID': cycleId,
      'reportTypeID': reportTypeId,
      'customerID': customerId,
      'siteID': siteId,
      'unit': unit,
      'length': length,
      'minLength': minLength,
      'maxLength': maxLength,
      'reportTypeName': reportTypeName,
      'customerName': customerName,
      'siteName': siteName,
    };
  }

  // Helper getters for backward compatibility with UI
  String? get cycleLength => length != null && unit != null ? '$length $unit' : null;

  String? get categoryName => reportTypeName;

  String? get customerSite =>
      customerName != null && siteName != null
          ? '$customerName - $siteName'
          : customerName ?? siteName;

  String? get dataType => reportTypeName;
}

class CycleModel {
  final List<CycleData>? data;
  final String? message;
  final int? page;
  final int? pageSize;
  final int? totalCount;

  CycleModel({this.data, this.message, this.page, this.pageSize, this.totalCount});

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      data:
          json['data'] != null
              ? (json['data'] as List).map((e) => CycleData.fromJson(e)).toList()
              : null,
      message: json['message'],
      page: json['page'],
      pageSize: json['pageSize'],
      totalCount: json['totalCount'],
    );
  }

  bool get success => data != null;
}
