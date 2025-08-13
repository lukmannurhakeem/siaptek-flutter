// To parse this JSON data, do
//
//     final getSiteCustomerByCustomerId = getSiteCustomerByCustomerIdFromJson(jsonString);

import 'dart:convert';

GetSiteByCustomerIdModel getSiteCustomerByCustomerIdFromJson(String str) =>
    GetSiteByCustomerIdModel.fromJson(json.decode(str));

String getSiteCustomerByCustomerIdToJson(GetSiteByCustomerIdModel data) =>
    json.encode(data.toJson());

class GetSiteByCustomerIdModel {
  String? customerId;
  List<SiteCustomer>? siteCustomers;
  int? total;

  GetSiteByCustomerIdModel({this.customerId, this.siteCustomers, this.total});

  factory GetSiteByCustomerIdModel.fromJson(Map<String, dynamic> json) => GetSiteByCustomerIdModel(
    customerId: json["customer_id"],
    siteCustomers:
        json["sites"] ==
                null // Changed from "SiteCustomers" to "sites" to match your JSON
            ? []
            : List<SiteCustomer>.from(json["sites"]!.map((x) => SiteCustomer.fromJson(x))),
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "customer_id": customerId,
    "sites": // Changed from "SiteCustomers" to "sites"
        siteCustomers == null ? [] : List<dynamic>.from(siteCustomers!.map((x) => x.toJson())),
    "total": total,
  };
}

class SiteCustomer {
  String? siteid; // Changed from SiteCustomerid to match JSON
  String? siteCode; // Changed from SiteCustomerCode to match JSON
  String? customerId;
  String? siteName; // Changed from SiteCustomerName to match JSON
  String? area;
  String? description;
  String? notes;
  String? division;
  String? logo;
  String? address;
  bool? archived;
  DateTime? createdAt;
  DateTime? updatedAt;

  SiteCustomer({
    this.siteid,
    this.siteCode,
    this.customerId,
    this.siteName,
    this.area,
    this.description,
    this.notes,
    this.division,
    this.logo,
    this.address,
    this.archived,
    this.createdAt,
    this.updatedAt,
  });

  factory SiteCustomer.fromJson(Map<String, dynamic> json) => SiteCustomer(
    siteid: json["siteid"],
    // Changed to match JSON field name
    siteCode: json["siteCode"],
    // Changed to match JSON field name
    customerId: json["customerId"],
    siteName: json["siteName"],
    // Changed to match JSON field name
    area: json["area"],
    description: json["description"],
    notes: json["notes"],
    division: json["division"],
    logo: json["logo"],
    address: json["address"],
    archived: json["archived"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "siteid": siteid,
    "siteCode": siteCode,
    "customerId": customerId,
    "siteName": siteName,
    "area": area,
    "description": description,
    "notes": notes,
    "division": division,
    "logo": logo,
    "address": address,
    "archived": archived,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
