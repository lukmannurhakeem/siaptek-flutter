import 'dart:convert';

class JobRegisterModel {
  int? count;
  List<Item>? items;

  JobRegisterModel({this.count, this.items});

  factory JobRegisterModel.fromRawJson(String str) => JobRegisterModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory JobRegisterModel.fromJson(Map<String, dynamic> json) => JobRegisterModel(
    count: json["count"],
    items:
        json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  String? itemId;
  String? jobId;
  String? itemNo;
  String? categoryId;
  String? rfidNo;
  String? locationId;
  String? detailedLocation;
  String? internalNotes;
  String? externalNotes;
  String? manufacturer;
  String? manufacturerAddress;
  DateTime? manufacturerDate;
  DateTime? firstUseDate;
  dynamic outOfServiceDate;
  String? swl;
  String? photoReference;
  String? standardReference;
  String? serialNumber;
  double? tareWeight;
  int? payLoad;
  double? maxGrossWeight;
  String? inspectionStatus;
  String? description;
  String? status;
  DateTime? expiryDateTimeStamp;
  bool? archived;
  bool? canInspectItem;
  bool? isActive;

  Item({
    this.itemId,
    this.jobId,
    this.itemNo,
    this.categoryId,
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
  });

  factory Item.fromRawJson(String str) => Item.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemId: json["itemID"],
    jobId: json["jobID"],
    itemNo: json["itemNo"],
    categoryId: json["categoryID"],
    rfidNo: json["rfidNo"],
    locationId: json["locationID"],
    detailedLocation: json["detailedLocation"],
    internalNotes: json["internalNotes"],
    externalNotes: json["externalNotes"],
    manufacturer: json["manufacturer"],
    manufacturerAddress: json["manufacturerAddress"],
    manufacturerDate:
        json["manufacturerDate"] == null ? null : DateTime.parse(json["manufacturerDate"]),
    firstUseDate: json["firstUseDate"] == null ? null : DateTime.parse(json["firstUseDate"]),
    outOfServiceDate: json["outOfServiceDate"],
    swl: json["swl"],
    photoReference: json["photoReference"],
    standardReference: json["standardReference"],
    serialNumber: json["serialNumber"],
    tareWeight: json["tareWeight"]?.toDouble(),
    payLoad: json["payLoad"],
    maxGrossWeight: json["maxGrossWeight"]?.toDouble(),
    inspectionStatus: json["inspectionStatus"],
    description: json["description"],
    status: json["status"],
    expiryDateTimeStamp:
        json["expiryDateTimeStamp"] == null ? null : DateTime.parse(json["expiryDateTimeStamp"]),
    archived: json["archived"],
    canInspectItem: json["canInspectItem"],
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "itemID": itemId,
    "jobID": jobId,
    "itemNo": itemNo,
    "categoryID": categoryId,
    "rfidNo": rfidNo,
    "locationID": locationId,
    "detailedLocation": detailedLocation,
    "internalNotes": internalNotes,
    "externalNotes": externalNotes,
    "manufacturer": manufacturer,
    "manufacturerAddress": manufacturerAddress,
    "manufacturerDate": manufacturerDate?.toIso8601String(),
    "firstUseDate": firstUseDate?.toIso8601String(),
    "outOfServiceDate": outOfServiceDate,
    "swl": swl,
    "photoReference": photoReference,
    "standardReference": standardReference,
    "serialNumber": serialNumber,
    "tareWeight": tareWeight,
    "payLoad": payLoad,
    "maxGrossWeight": maxGrossWeight,
    "inspectionStatus": inspectionStatus,
    "description": description,
    "status": status,
    "expiryDateTimeStamp": expiryDateTimeStamp?.toIso8601String(),
    "archived": archived,
    "canInspectItem": canInspectItem,
    "isActive": isActive,
  };
}
