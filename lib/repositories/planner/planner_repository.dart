import 'package:INSPECT/model/inspection_plan_model.dart';

abstract class PlannerRepository {
  /// Create a new inspection plan
  Future<InspectionPlanModel> createInspectionPlan(Map<String, dynamic> planData);

  /// Get all inspection plans
  Future<List<InspectionPlanModel>> getInspectionPlans();

  /// Get inspection plan by ID
  Future<InspectionPlanModel> getInspectionPlanById(String planId);

  /// Get inspection plans by job ID
  Future<List<InspectionPlanModel>> getInspectionPlansByJob(String jobId);

  /// Get inspection plans by assignee ID
  Future<List<InspectionPlanModel>> getInspectionPlansByAssignee(String assigneeId);

  /// Update inspection plan
  Future<InspectionPlanModel> updateInspectionPlan(String planId, Map<String, dynamic> planData);

  /// Delete inspection plan
  Future<bool> deleteInspectionPlan(String planId);

  /// Get pending sync count
  int getPendingSyncCount();

  /// Manually trigger sync
  Future<void> syncPendingPlans();
}
