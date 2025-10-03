import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/model/personnel_team_member_model.dart';
import 'package:base_app/model/personnel_team_model.dart';

abstract class PersonnelRepository {
  Future<PersonnelModel> fetchPersonnel();

  Future<Map<String, dynamic>> createPersonnel(Map<String, dynamic> personnelData);

  Future<List<PersonnelTeamModel>> fetchTeamPersonnel();

  Future<Map<String, dynamic>> createTeamPersonnel(Map<String, dynamic> personnelData);

  // Team member methods
  Future<List<PersonnelTeamMemberModel>> fetchTeamMembers(String teamPersonnelId);

  Future<AddMemberResponse> addTeamMember(Map<String, dynamic> memberData);

  Future<void> removeTeamMember(String personnelMembersId);

  Future<void> updateTeamMember(String personnelMembersId, Map<String, dynamic> memberData);
}
