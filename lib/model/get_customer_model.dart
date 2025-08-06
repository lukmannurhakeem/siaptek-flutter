import 'dart:convert';

class GetCustomerModel {
  List<Customer>? customers;
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  GetCustomerModel({this.customers, this.total, this.page, this.limit, this.totalPages});

  factory GetCustomerModel.fromRawJson(String str) => GetCustomerModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetCustomerModel.fromJson(Map<String, dynamic> json) => GetCustomerModel(
    customers:
        json["customers"] == null
            ? []
            : List<Customer>.from(json["customers"]!.map((x) => Customer.fromJson(x))),
    total: json["total"],
    page: json["page"],
    limit: json["limit"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "customers": customers == null ? [] : List<dynamic>.from(customers!.map((x) => x.toJson())),
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
  };
}

class Customer {
  int? id;
  String? customerid;
  String? customername;
  String? sitecode;
  String? accountCode;
  String? agent;
  String? notes;
  String? division;
  String? logo;
  String? address;
  bool? archived;
  DateTime? createdAt;
  DateTime? updatedAt;

  Customer({
    this.id,
    this.customerid,
    this.customername,
    this.sitecode,
    this.accountCode,
    this.agent,
    this.notes,
    this.division,
    this.logo,
    this.address,
    this.archived,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromRawJson(String str) => Customer.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["id"],
    customerid: json["customerid"],
    customername: json["customername"],
    sitecode: json["sitecode"],
    accountCode: json["account_code"],
    agent: json["agent"],
    notes: json["notes"],
    division: json["division"],
    logo: json["logo"],
    address: json["address"],
    archived: json["archived"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "customerid": customerid,
    "customername": customername,
    "sitecode": sitecode,
    "account_code": accountCode,
    "agent": agent,
    "notes": notes,
    "division": division,
    "logo": logo,
    "address": address,
    "archived": archived,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
