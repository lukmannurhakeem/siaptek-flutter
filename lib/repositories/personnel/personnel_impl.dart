import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/model/personnel_team_member_model.dart';
import 'package:base_app/model/personnel_team_model.dart';
import 'package:base_app/repositories/personnel/personnel_repository.dart';
import 'package:base_app/route/endpoint.dart';

class PersonnelImpl implements PersonnelRepository {
  final ApiClient _api;

  PersonnelImpl(this._api);

  @override
  Future<PersonnelModel> fetchPersonnel() async {
    final response = await _api.get(Endpoint.personnelView, requiresAuth: true);
    return PersonnelModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> createPersonnel(Map<String, dynamic> personnelData) async {
    final response = await _api.post(
      Endpoint.personnelCreate,
      data: personnelData,
      requiresAuth: true,
    );
    return response.data;
  }

  @override
  Future<List<PersonnelTeamModel>> fetchTeamPersonnel() async {
    final response = await _api.get(Endpoint.personnelTeamView, requiresAuth: true);

    if (response.data is List) {
      return (response.data as List)
          .map((item) => PersonnelTeamModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response.data is Map<String, dynamic>) {
      if (response.data.containsKey('data') && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => PersonnelTeamModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [PersonnelTeamModel.fromJson(response.data)];
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> createTeamPersonnel(Map<String, dynamic> personnelTeamData) async {
    final response = await _api.post(
      Endpoint.personnelTeamCreate,
      data: personnelTeamData,
      requiresAuth: true,
    );
    return response.data;
  }

  @override
  Future<List<PersonnelTeamMemberModel>> fetchTeamMembers(String teamPersonnelId) async {
    final response = await _api.get(
      '${Endpoint.personnelMembersView}/$teamPersonnelId',
      requiresAuth: true,
    );

    if (response.data is List) {
      return (response.data as List)
          .map((item) => PersonnelTeamMemberModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response.data is Map<String, dynamic>) {
      if (response.data.containsKey('data') && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((item) => PersonnelTeamMemberModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [PersonnelTeamMemberModel.fromJson(response.data)];
    }
    return [];
  }

  @override
  Future<AddMemberResponse> addTeamMember(Map<String, dynamic> memberData) async {
    final response = await _api.post(
      Endpoint.personnelMembersAdd,
      data: memberData,
      requiresAuth: true,
    );
    return AddMemberResponse.fromJson(response.data);
  }

  @override
  Future<void> removeTeamMember(String personnelMembersId) async {
    await _api.delete('${Endpoint.personnelMembersDelete}/$personnelMembersId', requiresAuth: true);
  }

  @override
  Future<void> updateTeamMember(String personnelMembersId, Map<String, dynamic> memberData) async {
    await _api.put(
      '${Endpoint.personnelMembersUpdate}/$personnelMembersId',
      data: memberData,
      requiresAuth: true,
    );
  }
}
