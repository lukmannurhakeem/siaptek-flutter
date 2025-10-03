import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/model/personnel_team_member_model.dart';
import 'package:base_app/model/personnel_team_model.dart';
import 'package:base_app/repositories/personnel/personnel_repository.dart';
import 'package:flutter/material.dart';

class PersonnelProvider extends ChangeNotifier {
  final PersonnelRepository _personnelRepository = ServiceLocator().personnelRepository;

  PersonnelModel? _personnelModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Team-related state
  List<PersonnelTeamModel> _teamPersonnelList = [];

  // Getters
  PersonnelModel? get personnelModel => _personnelModel;

  // Updated getter for team personnel
  List<PersonnelTeamModel> get teamPersonnelList => _teamPersonnelList;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<PersonnelData> get personnelList => _personnelModel?.data ?? [];

  int get personnelCount => _personnelModel?.count ?? 0;

  int get teamPersonnelCount => _teamPersonnelList.length;

  List<PersonnelTeamMemberModel> _teamMembers = [];

  List<PersonnelTeamMemberModel> get teamMembers => _teamMembers;

  // Fetch personnel data
  Future<void> fetchPersonnel() async {
    _setLoading(true);
    _clearError();

    try {
      _personnelModel = await _personnelRepository.fetchPersonnel();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch personnel: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void clearTeamMembers() {
    _teamMembers = [];
    notifyListeners();
  }

  Future<void> fetchTeamPersonnel() async {
    _setLoading(true);
    _clearError();

    try {
      _teamPersonnelList = await _personnelRepository.fetchTeamPersonnel();
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch team personnel: ${e.toString()}');
      _teamPersonnelList = [];
    } finally {
      _setLoading(false);
    }
  }

  // Refresh personnel data
  Future<void> refreshPersonnel() async {
    await fetchPersonnel();
  }

  // Refresh team personnel data
  Future<void> refreshTeamPersonnel() async {
    await fetchTeamPersonnel();
  }

  // Search personnel by name, job title, or employee number
  List<PersonnelData> searchPersonnel(String query) {
    if (query.isEmpty) return personnelList;

    final lowercaseQuery = query.toLowerCase();

    return personnelList.where((personnelData) {
      final fullName = personnelData.fullName.toLowerCase();
      final displayName = personnelData.displayName.toLowerCase();
      final jobTitle = personnelData.company.jobTitle.toLowerCase();
      final employeeNumber = personnelData.company.employeeNumber.toLowerCase();

      return fullName.contains(lowercaseQuery) ||
          displayName.contains(lowercaseQuery) ||
          jobTitle.contains(lowercaseQuery) ||
          employeeNumber.contains(lowercaseQuery);
    }).toList();
  }

  // Search teams by name, type, or description
  List<PersonnelTeamModel> searchTeams(String query) {
    if (query.isEmpty) return _teamPersonnelList;

    final lowercaseQuery = query.toLowerCase();

    return _teamPersonnelList.where((team) {
      final name = team.name?.toLowerCase() ?? '';
      final type = team.type?.toLowerCase() ?? '';
      final description = team.description?.toLowerCase() ?? '';

      return name.contains(lowercaseQuery) ||
          type.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }

  // Get personnel by ID
  PersonnelData? getPersonnelById(String personnelId) {
    try {
      return personnelList.firstWhere(
        (personnel) => personnel.personnel.personnelID == personnelId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get team by ID
  PersonnelTeamModel? getTeamById(String teamId) {
    try {
      return _teamPersonnelList.firstWhere((team) => team.teamPersonnelId == teamId);
    } catch (e) {
      return null;
    }
  }

  // Filter personnel by job title
  List<PersonnelData> filterByJobTitle(String jobTitle) {
    if (jobTitle.isEmpty) return personnelList;

    return personnelList
        .where(
          (personnelData) =>
              personnelData.company.jobTitle.toLowerCase().contains(jobTitle.toLowerCase()),
        )
        .toList();
  }

  // Filter active personnel (not archived)
  List<PersonnelData> get activePersonnel {
    return personnelList.where((personnelData) => !personnelData.personnel.isArchived).toList();
  }

  // Filter personnel hidden from planner
  List<PersonnelData> get visibleInPlanner {
    return personnelList
        .where((personnelData) => !personnelData.personnel.isHiddenFromPlanner)
        .toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Save new personnel - Updated to use real API call
  Future<bool> createPersonnel(Map<String, dynamic> personnelData) async {
    _setLoading(true);
    _clearError();

    try {
      // Call repository method to create personnel
      await _personnelRepository.createPersonnel(personnelData);

      // Refresh the list after creating
      await fetchPersonnel();
      return true;
    } catch (e) {
      _setError('Failed to create personnel: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTeamPersonnel(Map<String, dynamic> personnelData) async {
    _setLoading(true);
    _clearError();

    try {
      await _personnelRepository.createTeamPersonnel(personnelData);

      // Refresh the team list after creating
      await fetchTeamPersonnel();
      return true;
    } catch (e) {
      _setError('Failed to create team personnel: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing personnel
  Future<bool> updatePersonnel(String personnelId, PersonnelData personnelData) async {
    _setLoading(true);
    _clearError();

    try {
      // Call repository method to update personnel
      // await _personnelRepository.updatePersonnel(personnelId, personnelData);

      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Refresh the list after updating
      await fetchPersonnel();
      return true;
    } catch (e) {
      _setError('Failed to update personnel: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing team
  Future<bool> updateTeamPersonnel(String teamId, Map<String, dynamic> teamData) async {
    _setLoading(true);
    _clearError();

    try {
      // Call repository method to update team
      // await _personnelRepository.updateTeamPersonnel(teamId, teamData);

      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Refresh the list after updating
      await fetchTeamPersonnel();
      return true;
    } catch (e) {
      _setError('Failed to update team: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete personnel
  Future<bool> deletePersonnel(String personnelId) async {
    _setLoading(true);
    _clearError();

    try {
      // Call repository method to delete personnel
      // await _personnelRepository.deletePersonnel(personnelId);

      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Refresh the list after deleting
      await fetchPersonnel();
      return true;
    } catch (e) {
      _setError('Failed to delete personnel: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete team
  Future<bool> deleteTeamPersonnel(String teamId) async {
    _setLoading(true);
    _clearError();

    try {
      // Call repository method to delete team
      // await _personnelRepository.deleteTeamPersonnel(teamId);

      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Refresh the list after deleting
      await fetchTeamPersonnel();
      return true;
    } catch (e) {
      _setError('Failed to delete team: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTeamMembers(String teamPersonnelId) async {
    _setLoading(true);
    _clearError();

    try {
      _teamMembers = await _personnelRepository.fetchTeamMembers(teamPersonnelId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch team members: ${e.toString()}');
      _teamMembers = [];
    } finally {
      _setLoading(false);
    }
  }

  // Add member to team
  Future<bool> addTeamMember(Map<String, dynamic> memberData) async {
    _setLoading(true);
    _clearError();

    try {
      await _personnelRepository.addTeamMember(memberData);

      // Refresh team members list if we have a team selected
      if (memberData['team_personnel_id'] != null) {
        await fetchTeamMembers(memberData['team_personnel_id']);
      }

      return true;
    } catch (e) {
      _setError('Failed to add team member: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove member from team
  Future<bool> removeTeamMember(String personnelMembersId, String teamPersonnelId) async {
    _setLoading(true);
    _clearError();

    try {
      await _personnelRepository.removeTeamMember(personnelMembersId);

      // Refresh team members list
      await fetchTeamMembers(teamPersonnelId);

      return true;
    } catch (e) {
      _setError('Failed to remove team member: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update team member roles
  Future<bool> updateTeamMember(
    String personnelMembersId,
    String teamPersonnelId,
    Map<String, dynamic> memberData,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _personnelRepository.updateTeamMember(personnelMembersId, memberData);

      // Refresh team members list
      await fetchTeamMembers(teamPersonnelId);

      return true;
    } catch (e) {
      _setError('Failed to update team member: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get personnel details for a team member
  PersonnelData? getPersonnelForMember(String personnelId) {
    return getPersonnelById(personnelId);
  }

  // Clear all data
  void clearData() {
    _personnelModel = null;
    _teamPersonnelList = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
