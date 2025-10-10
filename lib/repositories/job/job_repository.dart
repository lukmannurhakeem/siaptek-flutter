import 'package:base_app/model/job_model.dart';
import 'package:base_app/model/job_register.dart';

abstract class JobRepository {
  Future<JobModel> fetchJobModel();

  Future<JobRegisterModel> fetchJobRegisterModel();

  Future<Map<String, dynamic>> createJobItem(Map<String, dynamic> jobItemData);

  Future<Map<String, dynamic>> createJob(Map<String, dynamic> jobData);
}
