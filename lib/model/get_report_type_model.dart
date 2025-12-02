import 'dart:convert';

class GetReportTypeModel {
  List<Datum>? data;
  String? message;

  GetReportTypeModel({this.data, this.message});

  factory GetReportTypeModel.fromRawJson(String str) =>
      GetReportTypeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetReportTypeModel.fromJson(Map<String, dynamic> json) {
    try {
      return GetReportTypeModel(
        data:
            json["data"] == null
                ? null
                : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        message: json["message"],
      );
    } catch (e) {
      print('❌ Error parsing GetReportTypeModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
  };
}

class Datum {
  ReportType? reportType;
  List<CompetencyReport>? competencyReports;
  List<ReportTypeDate>? reportTypeDates;
  List<StatusRuleReport>? statusRuleReports;
  List<ReportField>? reportFields;
  List<ActionReport>? actionReports;

  Datum({
    this.reportType,
    this.competencyReports,
    this.reportTypeDates,
    this.statusRuleReports,
    this.reportFields,
    this.actionReports,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) {
    try {
      return Datum(
        reportType: json["reportType"] == null ? null : ReportType.fromJson(json["reportType"]),
        competencyReports:
            json["competencyReports"] == null
                ? null // ✅ Changed from [] to null
                : (json["competencyReports"] is List)
                ? List<CompetencyReport>.from(
                  json["competencyReports"]!.map((x) => CompetencyReport.fromJson(x)),
                )
                : null,
        reportTypeDates:
            json["reportTypeDates"] == null
                ? null // ✅ Changed from [] to null
                : (json["reportTypeDates"] is List)
                ? List<ReportTypeDate>.from(
                  json["reportTypeDates"]!.map((x) => ReportTypeDate.fromJson(x)),
                )
                : null,
        statusRuleReports:
            json["statusRuleReports"] == null
                ? null // ✅ Changed from [] to null
                : (json["statusRuleReports"] is List)
                ? List<StatusRuleReport>.from(
                  json["statusRuleReports"]!.map((x) => StatusRuleReport.fromJson(x)),
                )
                : null,
        reportFields:
            json["reportFields"] == null
                ? null // ✅ Changed from [] to null
                : (json["reportFields"] is List)
                ? List<ReportField>.from(json["reportFields"]!.map((x) => ReportField.fromJson(x)))
                : null,
        actionReports:
            json["actionReports"] == null
                ? null // ✅ Changed from [] to null
                : (json["actionReports"] is List)
                ? List<ActionReport>.from(
                  json["actionReports"]!.map((x) => ActionReport.fromJson(x)),
                )
                : null,
      );
    } catch (e) {
      print('❌ Error parsing Datum: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "reportType": reportType?.toJson(),
    "competencyReports":
        competencyReports == null
            ? null
            : List<dynamic>.from(competencyReports!.map((x) => x.toJson())),
    "reportTypeDates":
        reportTypeDates == null
            ? null
            : List<dynamic>.from(reportTypeDates!.map((x) => x.toJson())),
    "statusRuleReports":
        statusRuleReports == null
            ? null
            : List<dynamic>.from(statusRuleReports!.map((x) => x.toJson())),
    "reportFields":
        reportFields == null ? null : List<dynamic>.from(reportFields!.map((x) => x.toJson())),
    "actionReports":
        actionReports == null ? null : List<dynamic>.from(actionReports!.map((x) => x.toJson())),
  };
}

class ActionReport {
  String? actionReportId;
  String? reportTypeId;
  String? description;
  bool? isArchive;
  String? applyAction;
  String? match;
  String? actionType;
  String? sourceTable;
  String? sourceField;
  String? destinationTable;
  String? destinationField;
  DateTime? createdAt;
  DateTime? updatedAt;

  ActionReport({
    this.actionReportId,
    this.reportTypeId,
    this.description,
    this.isArchive,
    this.applyAction,
    this.match,
    this.actionType,
    this.sourceTable,
    this.sourceField,
    this.destinationTable,
    this.destinationField,
    this.createdAt,
    this.updatedAt,
  });

  factory ActionReport.fromRawJson(String str) => ActionReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ActionReport.fromJson(Map<String, dynamic> json) => ActionReport(
    actionReportId: json["actionReportID"],
    reportTypeId: json["reportTypeID"],
    description: json["description"],
    isArchive: json["isArchive"],
    applyAction: json["applyAction"],
    match: json["match"],
    actionType: json["actionType"],
    sourceTable: json["sourceTable"],
    sourceField: json["sourceField"],
    destinationTable: json["destinationTable"],
    destinationField: json["destinationField"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "actionReportID": actionReportId,
    "reportTypeID": reportTypeId,
    "description": description,
    "isArchive": isArchive,
    "applyAction": applyAction,
    "match": match,
    "actionType": actionType,
    "sourceTable": sourceTable,
    "sourceField": sourceField,
    "destinationTable": destinationTable,
    "destinationField": destinationField,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class CompetencyReport {
  String? competencyReportId;
  String? reportTypeId;
  String? internalExternal;
  String? name;
  bool? canCreate;
  DateTime? createdAt;
  DateTime? updatedAt;

  CompetencyReport({
    this.competencyReportId,
    this.reportTypeId,
    this.internalExternal,
    this.name,
    this.canCreate,
    this.createdAt,
    this.updatedAt,
  });

  factory CompetencyReport.fromRawJson(String str) => CompetencyReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CompetencyReport.fromJson(Map<String, dynamic> json) => CompetencyReport(
    competencyReportId: json["competencyReportID"],
    reportTypeId: json["reportTypeID"],
    internalExternal: json["internalExternal"],
    name: json["name"],
    canCreate: json["canCreate"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "competencyReportID": competencyReportId,
    "reportTypeID": reportTypeId,
    "internalExternal": internalExternal,
    "name": name,
    "canCreate": canCreate,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class ReportField {
  String? reportFieldId;
  String? reportTypeId;
  String? labelText;
  String? name;
  String? fieldType;
  dynamic defaultValue;
  String? section;
  String? onlyAvailable;
  bool? isRequired;
  String? permissionField;
  bool? doNotCopy;
  String? infoText;
  bool? isArchive;
  DateTime? createdAt;
  DateTime? updatedAt;

  ReportField({
    this.reportFieldId,
    this.reportTypeId,
    this.labelText,
    this.name,
    this.fieldType,
    this.defaultValue,
    this.section,
    this.onlyAvailable,
    this.isRequired,
    this.permissionField,
    this.doNotCopy,
    this.infoText,
    this.isArchive,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportField.fromRawJson(String str) => ReportField.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportField.fromJson(Map<String, dynamic> json) => ReportField(
    reportFieldId: json["reportFieldID"],
    reportTypeId: json["reportTypeID"],
    labelText: json["labelText"],
    name: json["name"],
    fieldType: json["fieldType"],
    defaultValue: json["defaultValue"],
    section: json["section"],
    onlyAvailable: json["onlyAvailable"],
    isRequired: json["isRequired"],
    permissionField: json["permissionField"],
    doNotCopy: json["doNotCopy"],
    infoText: json["infoText"],
    isArchive: json["isArchive"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "reportFieldID": reportFieldId,
    "reportTypeID": reportTypeId,
    "labelText": labelText,
    "name": name,
    "fieldType": fieldType,
    "defaultValue": defaultValue,
    "section": section,
    "onlyAvailable": onlyAvailable,
    "isRequired": isRequired,
    "permissionField": permissionField,
    "doNotCopy": doNotCopy,
    "infoText": infoText,
    "isArchive": isArchive,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class DefaultValueClass {
  int? max;
  int? min;
  double? step;
  int? value;
  bool? isReadOnly;

  DefaultValueClass({this.max, this.min, this.step, this.value, this.isReadOnly});

  factory DefaultValueClass.fromRawJson(String str) => DefaultValueClass.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DefaultValueClass.fromJson(Map<String, dynamic> json) => DefaultValueClass(
    max: json["max"],
    min: json["min"],
    step: json["step"]?.toDouble(),
    value: json["value"],
    isReadOnly: json["isReadOnly"],
  );

  Map<String, dynamic> toJson() => {
    "max": max,
    "min": min,
    "step": step,
    "value": value,
    "isReadOnly": isReadOnly,
  };
}

class ReportType {
  String? reportTypeId;
  String? jobId;
  String? reportName;
  String? description;
  String? documentCode;
  bool? isExternalReport;
  bool? defaultAsDraft;
  bool? archived;
  bool? updateItemStatus;
  bool? updateItemDates;
  String? batchReportType;
  bool? isStatusRequired;
  String? possibleStatus;
  String? permission;
  String? categoryId;
  String? fieldsId;
  String? documentTemplate;
  String? labelTemplate;
  String? actionReportId;
  String? competencyId;
  DateTime? createdAt;
  DateTime? updatedAt;

  ReportType({
    this.reportTypeId,
    this.jobId,
    this.reportName,
    this.description,
    this.documentCode,
    this.isExternalReport,
    this.defaultAsDraft,
    this.archived,
    this.updateItemStatus,
    this.updateItemDates,
    this.batchReportType,
    this.isStatusRequired,
    this.possibleStatus,
    this.permission,
    this.categoryId,
    this.fieldsId,
    this.documentTemplate,
    this.labelTemplate,
    this.actionReportId,
    this.competencyId,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportType.fromRawJson(String str) => ReportType.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportType.fromJson(Map<String, dynamic> json) => ReportType(
    reportTypeId: json["reportTypeID"],
    jobId: json["jobID"],
    reportName: json["reportName"],
    description: json["description"],
    documentCode: json["documentCode"],
    isExternalReport: json["isExternalReport"],
    defaultAsDraft: json["defaultAsDraft"],
    archived: json["archived"],
    updateItemStatus: json["updateItemStatus"],
    updateItemDates: json["updateItemDates"],
    batchReportType: json["batchReportType"],
    isStatusRequired: json["isStatusRequired"],
    possibleStatus: json["possibleStatus"],
    permission: json["permission"],
    categoryId: json["categoryID"],
    fieldsId: json["fieldsID"],
    documentTemplate: json["documentTemplate"],
    labelTemplate: json["labelTemplate"],
    actionReportId: json["actionReportID"],
    competencyId: json["competencyID"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "reportTypeID": reportTypeId,
    "jobID": jobId,
    "reportName": reportName,
    "description": description,
    "documentCode": documentCode,
    "isExternalReport": isExternalReport,
    "defaultAsDraft": defaultAsDraft,
    "archived": archived,
    "updateItemStatus": updateItemStatus,
    "updateItemDates": updateItemDates,
    "batchReportType": batchReportType,
    "isStatusRequired": isStatusRequired,
    "possibleStatus": possibleStatus,
    "permission": permission,
    "categoryID": categoryId,
    "fieldsID": fieldsId,
    "documentTemplate": documentTemplate,
    "labelTemplate": labelTemplate,
    "actionReportID": actionReportId,
    "competencyID": competencyId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class ReportTypeDate {
  String? reportTypeDateId;
  String? reportTypeId;
  String? name;
  String? applyCycle;
  bool? isRequired;
  bool? disableFreeType;
  DateTime? createdAt;
  DateTime? updatedAt;

  ReportTypeDate({
    this.reportTypeDateId,
    this.reportTypeId,
    this.name,
    this.applyCycle,
    this.isRequired,
    this.disableFreeType,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportTypeDate.fromRawJson(String str) => ReportTypeDate.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReportTypeDate.fromJson(Map<String, dynamic> json) => ReportTypeDate(
    reportTypeDateId: json["reportTypeDateID"],
    reportTypeId: json["reportTypeID"],
    name: json["name"],
    applyCycle: json["applyCycle"],
    isRequired: json["isRequired"],
    disableFreeType: json["disableFreeType"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "reportTypeDateID": reportTypeDateId,
    "reportTypeID": reportTypeId,
    "name": name,
    "applyCycle": applyCycle,
    "isRequired": isRequired,
    "disableFreeType": disableFreeType,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class StatusRuleReport {
  String? statusRuleReportId;
  String? reportTypeId;
  String? status;
  String? field;
  String? statusRuleReportOperator;
  String? value;
  DateTime? createdAt;
  DateTime? updatedAt;

  StatusRuleReport({
    this.statusRuleReportId,
    this.reportTypeId,
    this.status,
    this.field,
    this.statusRuleReportOperator,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  factory StatusRuleReport.fromRawJson(String str) => StatusRuleReport.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StatusRuleReport.fromJson(Map<String, dynamic> json) => StatusRuleReport(
    statusRuleReportId: json["statusRuleReportID"],
    reportTypeId: json["reportTypeID"],
    status: json["status"],
    field: json["field"],
    statusRuleReportOperator: json["operator"],
    value: json["value"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "statusRuleReportID": statusRuleReportId,
    "reportTypeID": reportTypeId,
    "status": status,
    "field": field,
    "operator": statusRuleReportOperator,
    "value": value,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
