import 'dart:convert';

class ViewUserModel {
  int? count;
  List<Datum>? data;

  ViewUserModel({this.count, this.data});

  factory ViewUserModel.fromRawJson(String str) => ViewUserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ViewUserModel.fromJson(Map<String, dynamic> json) => ViewUserModel(
    count: json["count"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  Personnel? personnel;
  ContactInfo? contactInfo;
  Company? company;
  List<Availability>? availability;
  Qualification? qualification;

  Datum({this.personnel, this.contactInfo, this.company, this.availability, this.qualification});

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    personnel: json["personnel"] == null ? null : Personnel.fromJson(json["personnel"]),
    contactInfo: json["contactInfo"] == null ? null : ContactInfo.fromJson(json["contactInfo"]),
    company: json["company"] == null ? null : Company.fromJson(json["company"]),
    availability:
        json["availability"] == null
            ? []
            : List<Availability>.from(json["availability"]!.map((x) => Availability.fromJson(x))),
    qualification:
        json["qualification"] == null ? null : Qualification.fromJson(json["qualification"]),
  );

  Map<String, dynamic> toJson() => {
    "personnel": personnel?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "company": company?.toJson(),
    "availability":
        availability == null ? [] : List<dynamic>.from(availability!.map((x) => x.toJson())),
    "qualification": qualification?.toJson(),
  };
}

class Availability {
  String? availabilityId;
  String? personnelId;
  String? dayOfWeek;
  DateTime? startTime;
  DateTime? endTime;
  DateTime? createdAt;
  DateTime? updatedAt;

  Availability({
    this.availabilityId,
    this.personnelId,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  factory Availability.fromRawJson(String str) => Availability.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
    availabilityId: json["availabilityID"],
    personnelId: json["personnelID"],
    dayOfWeek: json["dayOfWeek"],
    startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
    endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "availabilityID": availabilityId,
    "personnelID": personnelId,
    "dayOfWeek": dayOfWeek,
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Company {
  String? companyId;
  String? personnelId;
  String? associatedLogin;
  String? employeeNumber;
  String? jobTitle;
  String? generalNotes;
  DateTime? createdAt;
  DateTime? updatedAt;

  Company({
    this.companyId,
    this.personnelId,
    this.associatedLogin,
    this.employeeNumber,
    this.jobTitle,
    this.generalNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory Company.fromRawJson(String str) => Company.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    companyId: json["companyID"],
    personnelId: json["personnelID"],
    associatedLogin: json["associatedLogin"],
    employeeNumber: json["employeeNumber"],
    jobTitle: json["jobTitle"],
    generalNotes: json["generalNotes"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "companyID": companyId,
    "personnelID": personnelId,
    "associatedLogin": associatedLogin,
    "employeeNumber": employeeNumber,
    "jobTitle": jobTitle,
    "generalNotes": generalNotes,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class ContactInfo {
  String? contactId;
  String? personnelId;
  String? workAddress;
  String? workMobilePhone;
  String? workPhone;
  String? workEmail;
  String? workSecondaryEmail;
  String? homeAddress;
  String? homePhone;
  String? personalEmail;
  String? personalSecondaryEmail;
  DateTime? createdAt;
  DateTime? updatedAt;

  ContactInfo({
    this.contactId,
    this.personnelId,
    this.workAddress,
    this.workMobilePhone,
    this.workPhone,
    this.workEmail,
    this.workSecondaryEmail,
    this.homeAddress,
    this.homePhone,
    this.personalEmail,
    this.personalSecondaryEmail,
    this.createdAt,
    this.updatedAt,
  });

  factory ContactInfo.fromRawJson(String str) => ContactInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    contactId: json["contactID"],
    personnelId: json["personnelID"],
    workAddress: json["workAddress"],
    workMobilePhone: json["workMobilePhone"],
    workPhone: json["workPhone"],
    workEmail: json["workEmail"],
    workSecondaryEmail: json["workSecondaryEmail"],
    homeAddress: json["homeAddress"],
    homePhone: json["homePhone"],
    personalEmail: json["personalEmail"],
    personalSecondaryEmail: json["personalSecondaryEmail"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "contactID": contactId,
    "personnelID": personnelId,
    "workAddress": workAddress,
    "workMobilePhone": workMobilePhone,
    "workPhone": workPhone,
    "workEmail": workEmail,
    "workSecondaryEmail": workSecondaryEmail,
    "homeAddress": homeAddress,
    "homePhone": homePhone,
    "personalEmail": personalEmail,
    "personalSecondaryEmail": personalSecondaryEmail,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Personnel {
  String? personnelId;
  String? divisionId;
  String? title;
  String? firstName;
  String? middleName;
  String? lastName;
  String? signatureFile;
  bool? isArchived;
  bool? isHiddenFromPlanner;
  String? miscNotes;
  DateTime? createdAt;
  DateTime? updatedAt;

  Personnel({
    this.personnelId,
    this.divisionId,
    this.title,
    this.firstName,
    this.middleName,
    this.lastName,
    this.signatureFile,
    this.isArchived,
    this.isHiddenFromPlanner,
    this.miscNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory Personnel.fromRawJson(String str) => Personnel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Personnel.fromJson(Map<String, dynamic> json) => Personnel(
    personnelId: json["personnelID"],
    divisionId: json["divisionID"],
    title: json["title"],
    firstName: json["firstName"],
    middleName: json["middleName"],
    lastName: json["lastName"],
    signatureFile: json["signatureFile"],
    isArchived: json["isArchived"],
    isHiddenFromPlanner: json["isHiddenFromPlanner"],
    miscNotes: json["miscNotes"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "personnelID": personnelId,
    "divisionID": divisionId,
    "title": title,
    "firstName": firstName,
    "middleName": middleName,
    "lastName": lastName,
    "signatureFile": signatureFile,
    "isArchived": isArchived,
    "isHiddenFromPlanner": isHiddenFromPlanner,
    "miscNotes": miscNotes,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Qualification {
  String? qualificationId;
  String? personnelId;
  String? iratCert;
  String? eddyQualification;
  String? magneticQualification;
  String? liquidQualification;
  String? ultrasonicQualification;
  DateTime? createdAt;
  DateTime? updatedAt;

  Qualification({
    this.qualificationId,
    this.personnelId,
    this.iratCert,
    this.eddyQualification,
    this.magneticQualification,
    this.liquidQualification,
    this.ultrasonicQualification,
    this.createdAt,
    this.updatedAt,
  });

  factory Qualification.fromRawJson(String str) => Qualification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Qualification.fromJson(Map<String, dynamic> json) => Qualification(
    qualificationId: json["qualificationID"],
    personnelId: json["personnelID"],
    iratCert: json["iratCert"],
    eddyQualification: json["eddyQualification"],
    magneticQualification: json["magneticQualification"],
    liquidQualification: json["liquidQualification"],
    ultrasonicQualification: json["ultrasonicQualification"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "qualificationID": qualificationId,
    "personnelID": personnelId,
    "iratCert": iratCert,
    "eddyQualification": eddyQualification,
    "magneticQualification": magneticQualification,
    "liquidQualification": liquidQualification,
    "ultrasonicQualification": ultrasonicQualification,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
