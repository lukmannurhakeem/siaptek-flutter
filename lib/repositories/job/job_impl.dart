import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/model/job_model.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/repositories/job/job_repository.dart';
import 'package:base_app/route/endpoint.dart';

class JobImpl implements JobRepository {
  final ApiClient _api;

  JobImpl(this._api);

  @override
  Future<JobModel> fetchJobModel() async {
    final response = await _api.get(Endpoint.jobView, requiresAuth: true);
    return JobModel.fromJson(response.data);
  }

  @override
  Future<JobRegisterModel> fetchJobRegisterModel(String jobId) async {
    try {
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
    final response = await _api.post(Endpoint.jobItemCreate, data: jobItemData, requiresAuth: true);
    return response.data;
  }

  @override
  Future<dynamic> createJob(Map<String, dynamic> jobData) async {
    final response = await _api.post(Endpoint.jobCreate, data: jobData, requiresAuth: true);
    return response.data;
  }
}
