import 'package:INSPECT/model/approval_report_model.dart';
import 'package:INSPECT/model/job_model.dart';
import 'package:INSPECT/model/job_register.dart';
import 'package:INSPECT/model/report_approval_model.dart';

abstract class JobRepository {
  /// Fetch all jobs
  Future<JobModel> fetchJobModel();

  /// Fetch job register details with items for a specific job
  Future<JobRegisterModel> fetchJobRegisterModel(String jobId);

  /// Fetch approval report for a specific job
  Future<ApprovalReportModel> fetchApprovalReport(String jobId);

  /// Create a new job item
  Future<dynamic> createJobItem(Map<String, dynamic> jobItemData);

  /// Create a new job
  Future<dynamic> createJob(Map<String, dynamic> jobData);

  /// Update approval status for an item
  Future<dynamic> updateApprovalStatus(String itemId);

  /// Fetch report approvals for a job
  /// Returns null if no data or error occurs (graceful handling)
  /// [isApproved] - true for approved reports, false for pending reports
  Future<ReportApprovalModel?> fetchReportApprovals(String jobId, bool isApproved);

  /// Approve a specific report
  Future<Map<String, dynamic>> approveReport(String reportId);

  /// Reject a specific report with optional reason
  Future<Map<String, dynamic>> rejectReport(String reportId, {String? reason});
}
