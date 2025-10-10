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
  Future<JobRegisterModel> fetchJobRegisterModel() async {
    final response = await _api.get(Endpoint.jobRegister, requiresAuth: true);
    return JobRegisterModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> createJobItem(Map<String, dynamic> jobItemData) async {
    final response = await _api.post(Endpoint.jobItemCreate, data: jobItemData, requiresAuth: true);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> jobData) async {
    final response = await _api.post(Endpoint.jobCreate, data: jobData, requiresAuth: true);
    return response.data;
  }
}
