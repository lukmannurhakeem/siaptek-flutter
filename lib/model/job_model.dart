import 'dart:convert';

class JobModel {
  int? count;
  List<Datum>? data;
  bool? success;

  JobModel({this.count, this.data, this.success});

  factory JobModel.fromRawJson(String str) => JobModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
    count: json["count"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "success": success,
  };
}

class Datum {
  String? jobId;
  String? jobNo;
  String? customerid;
  String? customerName;
  String? siteId;
  String? siteName;
  DateTime? createdDate;
  String? purchaseOrderNo;
  String? procedureNo;
  String? divisionId;
  int? allocatedDuration;
  DateTime? estimatedStartDate;
  DateTime? estimatedEndDate;
  bool? isEngineerComplete;
  String? offshoreLocation;
  String? authenticator;
  String? issuingAuthName;
  String? issuingAuthSignature;
  String? clientName;
  String? clientSignature;
  bool? startJobNow;

  Datum({
    this.jobId,
    this.jobNo,
    this.customerid,
    this.customerName,
    this.siteId,
    this.siteName,
    this.createdDate,
    this.purchaseOrderNo,
    this.procedureNo,
    this.divisionId,
    this.allocatedDuration,
    this.estimatedStartDate,
    this.estimatedEndDate,
    this.isEngineerComplete,
    this.offshoreLocation,
    this.authenticator,
    this.issuingAuthName,
    this.issuingAuthSignature,
    this.clientName,
    this.clientSignature,
    this.startJobNow,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    jobId: json["jobID"],
    jobNo: json["jobNo"],
    customerid: json["customerid"],
    customerName: json["customerName"],
    siteId: json["siteID"],
    siteName: json["siteName"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    purchaseOrderNo: json["purchaseOrderNo"],
    procedureNo: json["procedureNo"],
    divisionId: json["divisionID"],
    allocatedDuration: json["allocatedDuration"],
    estimatedStartDate:
        json["estimatedStartDate"] == null ? null : DateTime.parse(json["estimatedStartDate"]),
    estimatedEndDate:
        json["estimatedEndDate"] == null ? null : DateTime.parse(json["estimatedEndDate"]),
    isEngineerComplete: json["isEngineerComplete"],
    offshoreLocation: json["offshoreLocation"],
    authenticator: json["authenticator"],
    issuingAuthName: json["issuingAuthName"],
    issuingAuthSignature: json["issuingAuthSignature"],
    clientName: json["clientName"],
    clientSignature: json["clientSignature"],
    startJobNow: json["startJobNow"],
  );

  Map<String, dynamic> toJson() => {
    "jobID": jobId,
    "jobNo": jobNo,
    "customerid": customerid,
    "customerName": customerName,
    "siteID": siteId,
    "siteName": siteName,
    "createdDate": createdDate?.toIso8601String(),
    "purchaseOrderNo": purchaseOrderNo,
    "procedureNo": procedureNo,
    "divisionID": divisionId,
    "allocatedDuration": allocatedDuration,
    "estimatedStartDate": estimatedStartDate?.toIso8601String(),
    "estimatedEndDate": estimatedEndDate?.toIso8601String(),
    "isEngineerComplete": isEngineerComplete,
    "offshoreLocation": offshoreLocation,
    "authenticator": authenticator,
    "issuingAuthName": issuingAuthName,
    "issuingAuthSignature": issuingAuthSignature,
    "clientName": clientName,
    "clientSignature": clientSignature,
    "startJobNow": startJobNow,
  };
}
