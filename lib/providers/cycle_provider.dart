import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/cycle_model.dart';
import 'package:base_app/repositories/cycle/cycle_repository.dart';
import 'package:flutter/material.dart';

class CycleProvider extends ChangeNotifier {
  final CycleRepository _cycleRepository = ServiceLocator().cycleRepository;

  CycleModel? _cycleModel;
  bool _isLoading = false;
  String? _errorMessage;
  int _sortColumnIndex = 0;

  CycleModel? get cycleModel => _cycleModel;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get sortColumnIndex => _sortColumnIndex;

  set sortColumnIndex(int value) {
    _sortColumnIndex = value;
    notifyListeners();
  }

  // Fetch cycles from API
  Future<void> fetchCycles(BuildContext context, {int? page, int? pageSize}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _cycleModel = await _cycleRepository.fetchCycles(page: page ?? 1, pageSize: pageSize ?? 20);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching cycles: ${e.toString()}')));
      }
    }
  }

  // Delete cycle
  Future<void> deleteCycle(BuildContext context, String? cycleId) async {
    if (cycleId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _cycleRepository.deleteCycle(cycleId);

      // Remove from local list after successful deletion
      _cycleModel?.data?.removeWhere((cycle) => cycle.cycleId == cycleId);

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cycle deleted successfully')));
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting cycle: ${e.toString()}')));
      }
    }
  }

  // Create cycle
  Future<void> createCycle(
    BuildContext context, {
    required String reportTypeId,
    String? categoryId,
    String? customerId,
    String? siteId,
    required String unit,
    required int length,
    int? minLength,
    int? maxLength,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _cycleRepository.createCycle(
        reportTypeId: reportTypeId,
        categoryId: categoryId,
        customerId: customerId,
        siteId: siteId,
        unit: unit,
        length: length,
        minLength: minLength,
        maxLength: maxLength,
      );

      // Check if queued
      if (response?['queued'] == true) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response?['message'] ?? 'Cycle queued')));
        }
        return;
      }

      // Refresh the list after creating
      await fetchCycles(context);

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cycle created successfully')));
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating cycle: ${e.toString()}')));
      }
    }
  }

  // Update cycle
  Future<void> updateCycle(
    BuildContext context, {
    required String cycleId,
    required String reportTypeId,
    String? categoryId,
    String? customerId,
    String? siteId,
    required String unit,
    required int length,
    int? minLength,
    int? maxLength,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _cycleRepository.updateCycle(
        cycleId: cycleId,
        reportTypeId: reportTypeId,
        categoryId: categoryId,
        customerId: customerId,
        siteId: siteId,
        unit: unit,
        length: length,
        minLength: minLength,
        maxLength: maxLength,
      );

      // Check if queued
      if (response?['queued'] == true) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response?['message'] ?? 'Cycle update queued')));
        }
        return;
      }

      // Refresh the list after updating
      await fetchCycles(context);

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cycle updated successfully')));
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating cycle: ${e.toString()}')));
      }
    }
  }

  // Get cycle by ID
  CycleData? getCycleById(String cycleId) {
    return _cycleModel?.data?.firstWhere(
      (cycle) => cycle.cycleId == cycleId,
      orElse: () => CycleData(),
    );
  }

  // Get cycle details from API
  Future<CycleData?> getCycleDetails(BuildContext context, String cycleId) async {
    try {
      final response = await _cycleRepository.getCycleDetails(cycleId);
      if (response != null && response['data'] != null) {
        return CycleData.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching cycle details: ${e.toString()}')));
      }
      return null;
    }
  }

  // Clear data
  void clearData() {
    _cycleModel = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
