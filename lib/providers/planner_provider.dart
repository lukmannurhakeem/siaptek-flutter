import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/inspection_plan_model.dart';
import 'package:base_app/repositories/planner/planner_repository.dart';
import 'package:flutter/material.dart';

enum PlannerStatus { idle, loading, success, error }

class PlannerProvider extends ChangeNotifier {
  final PlannerRepository _repository = ServiceLocator().plannerRepository;

  PlannerStatus _status = PlannerStatus.idle;
  String? _errorMessage;
  List<InspectionPlanModel> _plans = [];
  InspectionPlanModel? _selectedPlan;
  int _pendingSyncCount = 0;

  // Getters
  PlannerStatus get status => _status;

  String? get errorMessage => _errorMessage;

  List<InspectionPlanModel> get plans => _plans;

  InspectionPlanModel? get selectedPlan => _selectedPlan;

  int get pendingSyncCount => _pendingSyncCount;

  bool get isLoading => _status == PlannerStatus.loading;

  bool get hasError => _status == PlannerStatus.error;

  /// Create a new inspection plan
  Future<bool> createInspectionPlan(Map<String, dynamic> planData) async {
    try {
      _setStatus(PlannerStatus.loading);

      final plan = await _repository.createInspectionPlan(planData);
      _plans.insert(0, plan);

      _updatePendingCount();
      _setStatus(PlannerStatus.success);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create plan: $e');
      return false;
    }
  }

  /// Fetch all inspection plans
  Future<void> fetchInspectionPlans() async {
    try {
      _setStatus(PlannerStatus.loading);

      _plans = await _repository.getInspectionPlans();

      _setStatus(PlannerStatus.success);
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch plans: $e');
    }
  }

  /// Fetch inspection plan by ID
  Future<void> fetchInspectionPlanById(String planId) async {
    try {
      _setStatus(PlannerStatus.loading);

      _selectedPlan = await _repository.getInspectionPlanById(planId);

      _setStatus(PlannerStatus.success);
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch plan: $e');
    }
  }

  /// Fetch plans by job ID
  Future<void> fetchPlansByJob(String jobId) async {
    try {
      _setStatus(PlannerStatus.loading);

      _plans = await _repository.getInspectionPlansByJob(jobId);

      _setStatus(PlannerStatus.success);
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch job plans: $e');
    }
  }

  /// Fetch plans by assignee ID
  Future<void> fetchPlansByAssignee(String assigneeId) async {
    try {
      _setStatus(PlannerStatus.loading);

      _plans = await _repository.getInspectionPlansByAssignee(assigneeId);

      _setStatus(PlannerStatus.success);
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch assignee plans: $e');
    }
  }

  /// Update an inspection plan
  Future<bool> updateInspectionPlan(String planId, Map<String, dynamic> planData) async {
    try {
      _setStatus(PlannerStatus.loading);

      final updatedPlan = await _repository.updateInspectionPlan(planId, planData);

      final index = _plans.indexWhere((p) => p.id == planId);
      if (index != -1) {
        _plans[index] = updatedPlan;
      }

      _updatePendingCount();
      _setStatus(PlannerStatus.success);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update plan: $e');
      return false;
    }
  }

  /// Delete an inspection plan
  Future<bool> deleteInspectionPlan(String planId) async {
    try {
      _setStatus(PlannerStatus.loading);

      final success = await _repository.deleteInspectionPlan(planId);

      if (success) {
        _plans.removeWhere((p) => p.id == planId);
      }

      _updatePendingCount();
      _setStatus(PlannerStatus.success);

      notifyListeners();
      return success;
    } catch (e) {
      _setError('Failed to delete plan: $e');
      return false;
    }
  }

  /// Sync pending requests
  Future<bool> syncPendingPlans() async {
    try {
      await _repository.syncPendingPlans();
      _updatePendingCount();

      // Refresh plans after sync
      await fetchInspectionPlans();

      return true;
    } catch (e) {
      _setError('Failed to sync: $e');
      return false;
    }
  }

  /// Update pending sync count
  void _updatePendingCount() {
    _pendingSyncCount = _repository.getPendingSyncCount();
  }

  /// Set status
  void _setStatus(PlannerStatus status) {
    _status = status;
    if (status != PlannerStatus.error) {
      _errorMessage = null;
    }
  }

  /// Set error
  void _setError(String message) {
    _status = PlannerStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == PlannerStatus.error) {
      _status = PlannerStatus.idle;
    }
    notifyListeners();
  }

  /// Filter plans by status
  List<InspectionPlanModel> getPlansByStatus(String status) {
    return _plans.where((plan) => plan.status == status).toList();
  }

  /// Filter plans by priority
  List<InspectionPlanModel> getPlansByPriority(String priority) {
    return _plans.where((plan) => plan.priority == priority).toList();
  }

  /// Get upcoming plans (start date in future)
  List<InspectionPlanModel> getUpcomingPlans() {
    final now = DateTime.now();
    return _plans.where((plan) {
      if (plan.plannedStartDate != null) {
        return plan.plannedStartDate!.isAfter(now);
      }
      return false;
    }).toList();
  }

  /// Get overdue plans (end date in past, not completed)
  List<InspectionPlanModel> getOverduePlans() {
    final now = DateTime.now();
    return _plans.where((plan) {
      if (plan.plannedEndDate != null && plan.status != 'completed') {
        return plan.plannedEndDate!.isBefore(now);
      }
      return false;
    }).toList();
  }
}
