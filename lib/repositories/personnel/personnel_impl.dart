import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/model/personnel_team_member_model.dart';
import 'package:base_app/model/personnel_team_model.dart';
import 'package:base_app/repositories/personnel/personnel_repository.dart';
import 'package:base_app/route/endpoint.dart';

class PersonnelImpl implements PersonnelRepository {
  final OfflineHttpService api; // Changed from ApiClient

  PersonnelImpl(this.api);

  @override
  Future<PersonnelModel> fetchPersonnel() async {
    final response = await api.get(Endpoint.personnelView, requiresAuth: true);
    return PersonnelModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> createPersonnel(Map<String, dynamic> personnelData) async {
    final response = await api.post(
      Endpoint.personnelCreate,
      data: personnelData,
      requiresAuth: true,
    );

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      return {'message': 'Personnel saved locally. Will sync when online.', 'queued': true};
    }

    return response.data;
  }

  @override
  Future<List<PersonnelTeamModel>> fetchTeamPersonnel() async {
    final response = await api.get(Endpoint.personnelTeamView, requiresAuth: true);

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
    final response = await api.post(
      Endpoint.personnelTeamCreate,
      data: personnelTeamData,
      requiresAuth: true,
    );

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      return {'message': 'Team saved locally. Will sync when online.', 'queued': true};
    }

    return response.data;
  }

  @override
  Future<List<PersonnelTeamMemberModel>> fetchTeamMembers(String teamPersonnelId) async {
    final response = await api.get(
      '${Endpoint.personnelMembersView}/$teamPersonnelId',
      requiresAuth: true,
    );

    if (response.data is Map<String, dynamic>) {
      if (response.data.containsKey('members') && response.data['members'] is List) {
        return (response.data['members'] as List)
            .map((item) => PersonnelTeamMemberModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      if (response.data.containsKey('data')) {
        final data = response.data['data'];
        if (data is Map<String, dynamic> && data.containsKey('members')) {
          return (data['members'] as List)
              .map((item) => PersonnelTeamMemberModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        if (data is List) {
          return data
              .map((item) => PersonnelTeamMemberModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [PersonnelTeamMemberModel.fromJson(response.data)];
    } else if (response.data is List) {
      return (response.data as List)
          .map((item) => PersonnelTeamMemberModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<AddMemberResponse> addTeamMember(Map<String, dynamic> memberData) async {
    final response = await api.post(
      Endpoint.personnelMembersAdd,
      data: memberData,
      requiresAuth: true,
    );

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      // Return a mock response for queued request
      return AddMemberResponse(
        message: 'Member addition queued. Will sync when online.',
        data: response.data,
      );
    }

    return AddMemberResponse.fromJson(response.data);
  }

  @override
  Future<void> removeTeamMember(String personnelMembersId) async {
    final response = await api.delete(
      '${Endpoint.personnelMembersDelete}/$personnelMembersId',
      requiresAuth: true,
    );

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      throw Exception('Member removal queued. Will sync when online.');
    }
  }

  @override
  Future<void> updateTeamMember(String personnelMembersId, Map<String, dynamic> memberData) async {
    final response = await api.put(
      '${Endpoint.personnelMembersUpdate}/$personnelMembersId',
      data: memberData,
      requiresAuth: true,
    );

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      throw Exception('Member update queued. Will sync when online.');
    }
  }
}
