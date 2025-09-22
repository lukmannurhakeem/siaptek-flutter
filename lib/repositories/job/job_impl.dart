import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/model/job_model.dart';
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
}
