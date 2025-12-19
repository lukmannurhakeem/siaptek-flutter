import 'dart:convert';

class GetAgentModel {
  List<Agent>? agents;
  String? message;
  Pagination? pagination;

  GetAgentModel({this.agents, this.message, this.pagination});

  factory GetAgentModel.fromRawJson(String str) => GetAgentModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GetAgentModel.fromJson(Map<String, dynamic> json) => GetAgentModel(
    agents: json["data"] == null
        ? []
        : List<Agent>.from(json["data"]!.map((x) => Agent.fromJson(x))),
    message: json["message"],
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "data": agents == null ? [] : List<dynamic>.from(agents!.map((x) => x.toJson())),
    "message": message,
    "pagination": pagination?.toJson(),
  };
}

class Agent {
  String? agentid;
  String? agentname;
  String? accountcode;
  String? notes;
  String? address;
  String? status;

  Agent({
    this.agentid,
    this.agentname,
    this.accountcode,
    this.notes,
    this.address,
    this.status,
  });

  factory Agent.fromRawJson(String str) => Agent.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
    agentid: json["agentid"],
    agentname: json["agentname"],
    accountcode: json["accountcode"],
    notes: json["notes"],
    address: json["address"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "agentid": agentid,
    "agentname": agentname,
    "accountcode": accountcode,
    "notes": notes,
    "address": address,
    "status": status,
  };
}

class Pagination {
  int? limit;
  int? page;
  int? total;

  Pagination({this.limit, this.page, this.total});

  factory Pagination.fromRawJson(String str) => Pagination.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    limit: json["limit"],
    page: json["page"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "limit": limit,
    "page": page,
    "total": total,
  };
}