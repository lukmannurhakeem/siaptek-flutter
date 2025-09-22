import 'package:base_app/model/job_model.dart';

abstract class JobRepository {
  Future<JobModel> fetchJobModel();
}
