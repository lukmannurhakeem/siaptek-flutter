// To parse this JSON data, do
//
//     final getSiteModel = getSiteModelFromJson(jsonString);

import 'dart:convert';

GetSiteModel getSiteModelFromJson(String str) => GetSiteModel.fromJson(json.decode(str));

String getSiteModelToJson(GetSiteModel data) => json.encode(data.toJson());

class GetSiteModel {
  List<Site>? sites;
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  GetSiteModel({this.sites, this.total, this.page, this.limit, this.totalPages});

  factory GetSiteModel.fromJson(Map<String, dynamic> json) => GetSiteModel(
    sites:
        json["sites"] == null ? [] : List<Site>.from(json["sites"]!.map((x) => Site.fromJson(x))),
    total: json["total"],
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "sites": sites == null ? [] : List<dynamic>.from(sites!.map((x) => x.toJson())),
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
  };
}

class Site {
  int? id;
  String? siteCode;
  String? customerId;
  String? siteName;
  String? area;
  String? description;
  String? notes;
  String? division;
  String? logo;
  String? address;
  bool? archived;
  DateTime? createdAt;
  DateTime? updatedAt;

  Site({
    this.id,
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

  factory Site.fromJson(Map<String, dynamic> json) => Site(
    id: json["id"],
    siteCode: json["siteCode"],
    customerId: json["customerId"],
    siteName: json["siteName"],
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
    "id": id,
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
