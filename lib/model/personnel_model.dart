class PersonnelModel {
  final int count;
  final List<PersonnelData> data;

  PersonnelModel({required this.count, required this.data});

  factory PersonnelModel.fromJson(Map<String, dynamic> json) {
    return PersonnelModel(
      count: json['count'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)?.map((item) => PersonnelData.fromJson(item)).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'count': count, 'data': data.map((item) => item.toJson()).toList()};
  }
}

class PersonnelData {
  final Personnel personnel;
  final ContactInfo contactInfo;
  final Company company;
  final List<Availability> availability;
  final Qualification qualification;

  PersonnelData({
    required this.personnel,
    required this.contactInfo,
    required this.company,
    required this.availability,
    required this.qualification,
  });

  factory PersonnelData.fromJson(Map<String, dynamic> json) {
    return PersonnelData(
      personnel: Personnel.fromJson(json['personnel'] ?? {}),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      company: Company.fromJson(json['company'] ?? {}),
      availability:
          (json['availability'] as List<dynamic>?)
              ?.map((item) => Availability.fromJson(item))
              .toList() ??
          [],
      qualification: Qualification.fromJson(json['qualification'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personnel': personnel.toJson(),
      'contactInfo': contactInfo.toJson(),
      'company': company.toJson(),
      'availability': availability.map((item) => item.toJson()).toList(),
      'qualification': qualification.toJson(),
    };
  }

  // Helper method to get full name
  String get fullName {
    final parts =
        [
          personnel.title,
          personnel.firstName,
          personnel.middleName,
          personnel.lastName,
        ].where((part) => part.isNotEmpty).toList();

    return parts.join(' ');
  }

  // Helper method to get display name (without title for shorter display)
  String get displayName {
    final parts =
        [
          personnel.firstName,
          personnel.middleName,
          personnel.lastName,
        ].where((part) => part.isNotEmpty).toList();

    return parts.join(' ');
  }
}

class Personnel {
  final String personnelID;
  final String divisionID;
  final String title;
  final String firstName;
  final String middleName;
  final String lastName;
  final String signatureFile;
  final bool isArchived;
  final bool isHiddenFromPlanner;
  final String miscNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Personnel({
    required this.personnelID,
    required this.divisionID,
    required this.title,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.signatureFile,
    required this.isArchived,
    required this.isHiddenFromPlanner,
    required this.miscNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      personnelID: json['personnelID'] ?? '',
      divisionID: json['divisionID'] ?? '',
      title: json['title'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      signatureFile: json['signatureFile'] ?? '',
      isArchived: json['isArchived'] ?? false,
      isHiddenFromPlanner: json['isHiddenFromPlanner'] ?? false,
      miscNotes: json['miscNotes'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personnelID': personnelID,
      'divisionID': divisionID,
      'title': title,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'signatureFile': signatureFile,
      'isArchived': isArchived,
      'isHiddenFromPlanner': isHiddenFromPlanner,
      'miscNotes': miscNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ContactInfo {
  final String contactID;
  final String personnelID;
  final String workAddress;
  final String workMobilePhone;
  final String workPhone;
  final String workEmail;
  final String workSecondaryEmail;
  final String homeAddress;
  final String homePhone;
  final String personalEmail;
  final String personalSecondaryEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContactInfo({
    required this.contactID,
    required this.personnelID,
    required this.workAddress,
    required this.workMobilePhone,
    required this.workPhone,
    required this.workEmail,
    required this.workSecondaryEmail,
    required this.homeAddress,
    required this.homePhone,
    required this.personalEmail,
    required this.personalSecondaryEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      contactID: json['contactID'] ?? '',
      personnelID: json['personnelID'] ?? '',
      workAddress: json['workAddress'] ?? '',
      workMobilePhone: json['workMobilePhone'] ?? '',
      workPhone: json['workPhone'] ?? '',
      workEmail: json['workEmail'] ?? '',
      workSecondaryEmail: json['workSecondaryEmail'] ?? '',
      homeAddress: json['homeAddress'] ?? '',
      homePhone: json['homePhone'] ?? '',
      personalEmail: json['personalEmail'] ?? '',
      personalSecondaryEmail: json['personalSecondaryEmail'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactID': contactID,
      'personnelID': personnelID,
      'workAddress': workAddress,
      'workMobilePhone': workMobilePhone,
      'workPhone': workPhone,
      'workEmail': workEmail,
      'workSecondaryEmail': workSecondaryEmail,
      'homeAddress': homeAddress,
      'homePhone': homePhone,
      'personalEmail': personalEmail,
      'personalSecondaryEmail': personalSecondaryEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Company {
  final String companyID;
  final String personnelID;
  final String associatedLogin;
  final String employeeNumber;
  final String jobTitle;
  final String generalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Company({
    required this.companyID,
    required this.personnelID,
    required this.associatedLogin,
    required this.employeeNumber,
    required this.jobTitle,
    required this.generalNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyID: json['companyID'] ?? '',
      personnelID: json['personnelID'] ?? '',
      associatedLogin: json['associatedLogin'] ?? '',
      employeeNumber: json['employeeNumber'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      generalNotes: json['generalNotes'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyID': companyID,
      'personnelID': personnelID,
      'associatedLogin': associatedLogin,
      'employeeNumber': employeeNumber,
      'jobTitle': jobTitle,
      'generalNotes': generalNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Availability {
  final String availabilityID;
  final String personnelID;
  final String dayOfWeek;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Availability({
    required this.availabilityID,
    required this.personnelID,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      availabilityID: json['availabilityID'] ?? '',
      personnelID: json['personnelID'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availabilityID': availabilityID,
      'personnelID': personnelID,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to get formatted time range
  String get timeRange {
    final startFormatted =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endFormatted =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startFormatted - $endFormatted';
  }
}

class Qualification {
  final String qualificationID;
  final String personnelID;
  final String iratCert;
  final String eddyQualification;
  final String magneticQualification;
  final String liquidQualification;
  final String ultrasonicQualification;
  final DateTime createdAt;
  final DateTime updatedAt;

  Qualification({
    required this.qualificationID,
    required this.personnelID,
    required this.iratCert,
    required this.eddyQualification,
    required this.magneticQualification,
    required this.liquidQualification,
    required this.ultrasonicQualification,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Qualification.fromJson(Map<String, dynamic> json) {
    return Qualification(
      qualificationID: json['qualificationID'] ?? '',
      personnelID: json['personnelID'] ?? '',
      iratCert: json['iratCert'] ?? '',
      eddyQualification: json['eddyQualification'] ?? '',
      magneticQualification: json['magneticQualification'] ?? '',
      liquidQualification: json['liquidQualification'] ?? '',
      ultrasonicQualification: json['ultrasonicQualification'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qualificationID': qualificationID,
      'personnelID': personnelID,
      'iratCert': iratCert,
      'eddyQualification': eddyQualification,
      'magneticQualification': magneticQualification,
      'liquidQualification': liquidQualification,
      'ultrasonicQualification': ultrasonicQualification,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
