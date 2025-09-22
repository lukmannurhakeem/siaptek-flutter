import 'dart:convert';

class CreateCategoryModel {
  Data? data;
  String? message;
  bool? success;

  CreateCategoryModel({this.data, this.message, this.success});

  factory CreateCategoryModel.fromRawJson(String str) =>
      CreateCategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CreateCategoryModel.fromJson(Map<String, dynamic> json) => CreateCategoryModel(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {"data": data?.toJson(), "message": message, "success": success};
}

class Data {
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
  String? regulationId;
  String? checklistId;
  String? plannedMaintenanceId;

  Data({
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
    this.regulationId,
    this.checklistId,
    this.plannedMaintenanceId,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
    "regulationId": regulationId,
    "checklistId": checklistId,
    "plannedMaintenanceId": plannedMaintenanceId,
  };
}
