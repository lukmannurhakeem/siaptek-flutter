import 'dart:convert';

class GetCategoryModel {
  List<Datum>? data;
  String? message;
  Pagination? pagination;
  bool? success;

  GetCategoryModel({this.data, this.message, this.pagination, this.success});

  factory GetCategoryModel.fromRawJson(String str) => GetCategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetCategoryModel.fromJson(Map<String, dynamic> json) => GetCategoryModel(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    message: json["message"],
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
    "pagination": pagination?.toJson(),
    "success": success,
  };
}

class Datum {
  String? categoryId;
  dynamic parentId;
  String? categoryName;
  String? categoryCode;
  String? description;
  String? descriptionTemplate;
  int? replacementPeriod;
  String? instructions;
  String? notes;
  bool? canHaveChildItems;
  bool? isWithdrawn;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? siteId;
  String? regulationId;
  String? checklistId;
  String? plannedMaintenanceId;

  Datum({
    this.categoryId,
    this.parentId,
    this.categoryName,
    this.categoryCode,
    this.description,
    this.descriptionTemplate,
    this.replacementPeriod,
    this.instructions,
    this.notes,
    this.canHaveChildItems,
    this.isWithdrawn,
    this.createdAt,
    this.updatedAt,
    this.siteId,
    this.regulationId,
    this.checklistId,
    this.plannedMaintenanceId,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    categoryId: json["categoryId"],
    parentId: json["parentId"],
    categoryName: json["categoryName"],
    categoryCode: json["categoryCode"],
    description: json["description"],
    descriptionTemplate: json["descriptionTemplate"],
    replacementPeriod: json["replacementPeriod"],
    instructions: json["instructions"],
    notes: json["notes"],
    canHaveChildItems: json["canHaveChildItems"],
    isWithdrawn: json["isWithdrawn"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    siteId: json["siteId"],
    regulationId: json["regulationId"],
    checklistId: json["checklistId"],
    plannedMaintenanceId: json["plannedMaintenanceId"],
  );

  Map<String, dynamic> toJson() => {
    "categoryId": categoryId,
    "parentId": parentId,
    "categoryName": categoryName,
    "categoryCode": categoryCode,
    "description": description,
    "descriptionTemplate": descriptionTemplate,
    "replacementPeriod": replacementPeriod,
    "instructions": instructions,
    "notes": notes,
    "canHaveChildItems": canHaveChildItems,
    "isWithdrawn": isWithdrawn,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "siteId": siteId,
    "regulationId": regulationId,
    "checklistId": checklistId,
    "plannedMaintenanceId": plannedMaintenanceId,
  };
}

class Pagination {
  int? count;
  int? limit;
  int? offset;
  int? total;

  Pagination({this.count, this.limit, this.offset, this.total});

  factory Pagination.fromRawJson(String str) => Pagination.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    count: json["count"],
    limit: json["limit"],
    offset: json["offset"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "limit": limit,
    "offset": offset,
    "total": total,
  };
}
