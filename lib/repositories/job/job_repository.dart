import 'package:base_app/model/approval_report_model.dart';
import 'package:base_app/model/job_model.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/model/report_approval_model.dart';

abstract class JobRepository {
  Future<JobModel> fetchJobModel();

  Future<JobRegisterModel> fetchJobRegisterModel(String jobId);

  Future<ApprovalReportModel> fetchApprovalReport(String jobId);

  Future<dynamic> createJobItem(Map<String, dynamic> jobItemData);

  Future<dynamic> createJob(Map<String, dynamic> jobData);

  Future<dynamic> updateApprovalStatus(String itemId);

  Future<ReportApprovalModel> fetchReportApprovals(String jobId, bool status);

  Future<Map<String, dynamic>> rejectReport(String reportId, {String? reason});

  Future<Map<String, dynamic>> approveReport(String reportId);
}
