import 'dart:convert';

class GetCompanyDivision {
  String? divisionid;
  String? customerid;
  String? divisionname;
  String? divisioncode;
  String? logo;
  String? address;
  String? telephone;
  String? website;
  String? email;
  String? fax;
  String? culture;
  String? timezone;

  GetCompanyDivision({
    this.divisionid,
    this.customerid,
    this.divisionname,
    this.divisioncode,
    this.logo,
    this.address,
    this.telephone,
    this.website,
    this.email,
    this.fax,
    this.culture,
    this.timezone,
  });

  factory GetCompanyDivision.fromRawJson(String str) =>
      GetCompanyDivision.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetCompanyDivision.fromJson(Map<String, dynamic> json) {
    return GetCompanyDivision(
      divisionid: json["divisionid"]?.toString(),
      customerid: json["customerid"]?.toString(),
      divisionname: json["divisionname"]?.toString(),
      divisioncode: json["divisioncode"]?.toString(),
      logo: json["logo"]?.toString(),
      address: json["address"]?.toString(),
      telephone: json["telephone"]?.toString(),
      website: json["website"]?.toString(),
      email: json["email"]?.toString(),
      fax: json["fax"]?.toString(),
      culture: json["culture"]?.toString(),
      timezone: json["timezone"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "divisionid": divisionid,
    "customerid": customerid,
    "divisionname": divisionname,
    "divisioncode": divisioncode,
    "logo": logo,
    "address": address,
    "telephone": telephone,
    "website": website,
    "email": email,
    "fax": fax,
    "culture": culture,
    "timezone": timezone,
  };
}
