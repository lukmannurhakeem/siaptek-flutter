class PersonnelTeamMemberModel {
  final String personnelMembersId;
  final String teamPersonnelId;
  final String personnelId;
  final bool isTeamLeader;
  final bool isPrimaryLeader;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonnelTeamMemberModel({
    required this.personnelMembersId,
    required this.teamPersonnelId,
    required this.personnelId,
    required this.isTeamLeader,
    required this.isPrimaryLeader,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PersonnelTeamMemberModel.fromJson(Map<String, dynamic> json) {
    return PersonnelTeamMemberModel(
      personnelMembersId: json['personnel_members_id'] ?? '',
      teamPersonnelId: json['team_personnel_id'] ?? '',
      personnelId: json['personnel_id'] ?? '',
      isTeamLeader: json['is_team_leader'] ?? false,
      isPrimaryLeader: json['is_primary_leader'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personnel_members_id': personnelMembersId,
      'team_personnel_id': teamPersonnelId,
      'personnel_id': personnelId,
      'is_team_leader': isTeamLeader,
      'is_primary_leader': isPrimaryLeader,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class AddMemberResponse {
  final PersonnelTeamMemberModel data;
  final String message;

  AddMemberResponse({required this.data, required this.message});

  factory AddMemberResponse.fromJson(Map<String, dynamic> json) {
    return AddMemberResponse(
      data: PersonnelTeamMemberModel.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}
