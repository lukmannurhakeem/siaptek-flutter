import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/repositories/personnel/personnel_repository.dart';
import 'package:flutter/material.dart';

class PersonnelProvider extends ChangeNotifier {
  final PersonnelRepository _personnelRepository = ServiceLocator().personnelRepository;

  PersonnelModel? _personnelModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  PersonnelModel? get personnelModel => _personnelModel;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<PersonnelData> get personnelList => _personnelModel?.data ?? [];

  int get personnelCount => _personnelModel?.count ?? 0;

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

  // Refresh personnel data
  Future<void> refreshPersonnel() async {
    await fetchPersonnel();
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

  // Clear all data
  void clearData() {
    _personnelModel = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
