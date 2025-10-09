// To parse this JSON data, do
//
//     final itemReportModel = itemReportModelFromJson(jsonString);

import 'dart:convert';

List<ItemReportModel> itemReportModelFromJson(String str) =>
    List<ItemReportModel>.from(json.decode(str).map((x) => ItemReportModel.fromJson(x)));

String itemReportModelToJson(List<ItemReportModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ItemReportModel {
  String? reportId;
  String? reportTypeId;
  String? reportName;
  String? itemId;
  String? itemNo;
  String? status;
  String? inspectedBy;
  DateTime? reportDate;
  String? regulation;
  ReportData? reportData;
  DateTime? createdAt;
  DateTime? updatedAt;

  ItemReportModel({
    this.reportId,
    this.reportTypeId,
    this.reportName,
    this.itemId,
    this.itemNo,
    this.status,
    this.inspectedBy,
    this.reportDate,
    this.regulation,
    this.reportData,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemReportModel.fromJson(Map<String, dynamic> json) => ItemReportModel(
    reportId: json["reportID"],
    reportTypeId: json["reportTypeID"],
    reportName: json["reportName"],
    itemId: json["itemID"],
    itemNo: json["itemNo"],
    status: json["status"],
    inspectedBy: json["inspectedBy"],
    reportDate: json["reportDate"] == null ? null : DateTime.parse(json["reportDate"]),
    regulation: json["regulation"],
    reportData: json["reportData"] == null ? null : ReportData.fromJson(json["reportData"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "reportID": reportId,
    "reportTypeID": reportTypeId,
    "reportName": reportName,
    "itemID": itemId,
    "itemNo": itemNo,
    "status": status,
    "inspectedBy": inspectedBy,
    "reportDate": reportDate?.toIso8601String(),
    "regulation": regulation,
    "reportData": reportData?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class ReportData {
  Field? field1;
  Field? field2;

  ReportData({this.field1, this.field2});

  factory ReportData.fromJson(Map<String, dynamic> json) => ReportData(
    field1: json["field1"] == null ? null : Field.fromJson(json["field1"]),
    field2: json["field2"] == null ? null : Field.fromJson(json["field2"]),
  );

  Map<String, dynamic> toJson() => {"field1": field1?.toJson(), "field2": field2?.toJson()};
}

class Field {
  String? value;

  Field({this.value});

  factory Field.fromJson(Map<String, dynamic> json) => Field(value: json["value"]);

  Map<String, dynamic> toJson() => {"value": value};
}
