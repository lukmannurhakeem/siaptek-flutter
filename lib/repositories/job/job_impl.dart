import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/job_model.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/repositories/job/job_repository.dart';
import 'package:base_app/route/endpoint.dart';

class JobImpl implements JobRepository {
  final OfflineHttpService _api;

  JobImpl(this._api);

  @override
  Future<JobModel> fetchJobModel() async {
    // Automatically uses cache when offline
    final response = await _api.get(Endpoint.jobView, requiresAuth: true);
    return JobModel.fromJson(response.data);
  }

  @override
  Future<JobRegisterModel> fetchJobRegisterModel(String jobId) async {
    try {
      // Automatically uses cache when offline
      final response = await _api.get(Endpoint.jobRegister(jobId: jobId), requiresAuth: true);

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return JobRegisterModel.fromJson(data);
      } else {
        throw Exception('Unexpected response format: expected an object with count and items');
      }
    } catch (e) {
      throw Exception('Failed to fetch job register: $e');
    }
  }

  @override
  Future<dynamic> createJobItem(Map<String, dynamic> jobItemData) async {
    // Automatically queues when offline
    final response = await _api.post(Endpoint.jobItemCreate, data: jobItemData, requiresAuth: true);

    // Check if request was queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      return {
        'message': 'Job item saved locally. Will sync when online.',
        'queued': true,
        'requestId': response.data['requestId'],
      };
    }

    return response.data;
  }

  @override
  Future<dynamic> createJob(Map<String, dynamic> jobData) async {
    // Automatically queues when offline
    final response = await _api.post(Endpoint.jobCreate, data: jobData, requiresAuth: true);

    // Check if request was queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      return {
        'message': 'Job saved locally. Will sync when online.',
        'queued': true,
        'requestId': response.data['requestId'],
      };
    }

    return response.data;
  }
}

// Note: Replace ApiClient with UnifiedHttpService in all your Impl classes
// The API is identical, just change:
// - Constructor: ApiClient _api -> UnifiedHttpService _api
// - That's it! All GET/POST/PUT/DELETE methods work the same way
