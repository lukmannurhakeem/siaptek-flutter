// To parse this JSON data, do
//
//     final personnelTeamModel = personnelTeamModelFromJson(jsonString);

import 'dart:convert';

List<PersonnelTeamModel> personnelTeamModelFromJson(String str) =>
    List<PersonnelTeamModel>.from(json.decode(str).map((x) => PersonnelTeamModel.fromJson(x)));

String personnelTeamModelToJson(List<PersonnelTeamModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PersonnelTeamModel {
  String? teamPersonnelId;
  String? name;
  String? parentTeam;
  String? type;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;

  PersonnelTeamModel({
    this.teamPersonnelId,
    this.name,
    this.parentTeam,
    this.type,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory PersonnelTeamModel.fromJson(Map<String, dynamic> json) => PersonnelTeamModel(
    teamPersonnelId: json["team_personnel_id"],
    name: json["name"],
    parentTeam: json["parent_team"],
    type: json["type"],
    description: json["description"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "team_personnel_id": teamPersonnelId,
    "name": name,
    "parent_team": parentTeam,
    "type": type,
    "description": description,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
