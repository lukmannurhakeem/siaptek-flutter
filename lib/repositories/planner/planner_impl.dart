import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/inspection_plan_model.dart';
import 'package:base_app/repositories/planner/planner_repository.dart';
import 'package:base_app/route/endpoint.dart';
import 'package:flutter/foundation.dart';

class PlannerImpl implements PlannerRepository {
  final OfflineHttpService _api;

  PlannerImpl(this._api);

  @override
  Future<InspectionPlanModel> createInspectionPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _api.post(
        Endpoint.inspectionPlansCreate,
        data: planData,
        requiresAuth: true,
      );

      if (response.statusCode == 202) {
        // Request was queued for offline sync
        return InspectionPlanModel.fromJson({
          ...planData,
          'id': response.data['requestId'],
          'isQueued': true,
        });
      }

      return InspectionPlanModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create inspection plan: $e');
    }
  }

  @override
  Future<List<InspectionPlanModel>> getInspectionPlans() async {
    try {
      final response = await _api.get(Endpoint.inspectionPlansView, requiresAuth: true);

      debugPrint('🔍 Raw response type: ${response.data.runtimeType}');
      debugPrint('🔍 Raw response: ${response.data}');

      // Handle wrapped response format: { "success": true, "data": [...] }
      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'];

        if (data is List) {
          debugPrint('✅ Found ${data.length} plans in wrapped response');
          return data.map((json) {
            try {
              return InspectionPlanModel.fromJson(json as Map<String, dynamic>);
            } catch (e, stackTrace) {
              debugPrint('❌ Failed to parse plan: $e');
              debugPrint('JSON: $json');
              debugPrint('Stack: $stackTrace');
              rethrow;
            }
          }).toList();
        }
      }

      // Fallback: Handle direct array response
      if (response.data is List) {
        debugPrint('✅ Found ${(response.data as List).length} plans in direct array');
        return (response.data as List).map((json) {
          try {
            return InspectionPlanModel.fromJson(json as Map<String, dynamic>);
          } catch (e, stackTrace) {
            debugPrint('❌ Failed to parse plan: $e');
            debugPrint('JSON: $json');
            debugPrint('Stack: $stackTrace');
            rethrow;
          }
        }).toList();
      }

      debugPrint('⚠️ No valid data found, returning empty list');
      return [];
    } catch (e, stackTrace) {
      debugPrint('❌ Exception in getInspectionPlans: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to fetch inspection plans: $e');
    }
  }

  @override
  Future<InspectionPlanModel> getInspectionPlanById(String planId) async {
    try {
      final response = await _api.get(Endpoint.getInspectionPlanById(planId), requiresAuth: true);

      // Handle wrapped response
      if (response.data is Map<String, dynamic> && response.data['data'] != null) {
        return InspectionPlanModel.fromJson(response.data['data']);
      }

      return InspectionPlanModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch inspection plan: $e');
    }
  }

  @override
  Future<List<InspectionPlanModel>> getInspectionPlansByJob(String jobId) async {
    try {
      final response = await _api.get(Endpoint.getInspectionPlansByJob(jobId), requiresAuth: true);

      // Handle wrapped response
      if (response.data is Map<String, dynamic> && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => InspectionPlanModel.fromJson(json))
            .toList();
      }

      // Fallback: Direct array
      if (response.data is List) {
        return (response.data as List).map((json) => InspectionPlanModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch job inspection plans: $e');
    }
  }

  @override
  Future<List<InspectionPlanModel>> getInspectionPlansByAssignee(String assigneeId) async {
    try {
      final response = await _api.get(
        Endpoint.getInspectionPlansByAssignee(assigneeId),
        requiresAuth: true,
      );

      // Handle wrapped response
      if (response.data is Map<String, dynamic> && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => InspectionPlanModel.fromJson(json))
            .toList();
      }

      // Fallback: Direct array
      if (response.data is List) {
        return (response.data as List).map((json) => InspectionPlanModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch assignee inspection plans: $e');
    }
  }

  @override
  Future<InspectionPlanModel> updateInspectionPlan(
    String planId,
    Map<String, dynamic> planData,
  ) async {
    try {
      final response = await _api.put(
        '${Endpoint.inspectionPlansUpdate}/$planId',
        data: planData,
        requiresAuth: true,
      );

      if (response.statusCode == 202) {
        // Request was queued for offline sync
        return InspectionPlanModel.fromJson({...planData, 'id': planId, 'isQueued': true});
      }

      // Handle wrapped response
      if (response.data is Map<String, dynamic> && response.data['data'] != null) {
        return InspectionPlanModel.fromJson(response.data['data']);
      }

      return InspectionPlanModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update inspection plan: $e');
    }
  }

  @override
  Future<bool> deleteInspectionPlan(String planId) async {
    try {
      final response = await _api.delete(
        '${Endpoint.inspectionPlansDelete}/$planId',
        requiresAuth: true,
      );

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      throw Exception('Failed to delete inspection plan: $e');
    }
  }

  @override
  int getPendingSyncCount() {
    return _api.getPendingCount();
  }

  @override
  Future<void> syncPendingPlans() async {
    try {
      final result = await _api.syncNow();

      if (result.hasFailures) {
        throw Exception('Some requests failed to sync: ${result.failed}/${result.total}');
      }
    } catch (e) {
      throw Exception('Failed to sync pending plans: $e');
    }
  }
}
