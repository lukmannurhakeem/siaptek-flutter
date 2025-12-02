import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/approval_report_model.dart';
import 'package:base_app/model/job_model.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/model/report_approval_model.dart';
import 'package:base_app/repositories/job/job_repository.dart';
import 'package:base_app/route/endpoint.dart';

class JobImpl implements JobRepository {
  final OfflineHttpService _api;

  JobImpl(this._api);

  @override
  Future<JobModel> fetchJobModel() async {
    try {
      final response = await _api.get(Endpoint.jobView, requiresAuth: true);
      return JobModel.fromJson(response.data);
    } catch (e) {
      print('❌ Error fetching job model: $e');
      throw Exception('Failed to fetch jobs: $e');
    }
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
      print('❌ Error fetching job register: $e');
      throw Exception('Failed to fetch job register: $e');
    }
  }

  @override
  Future<ApprovalReportModel> fetchApprovalReport(String jobId) async {
    try {
      print('📡 Fetching approval reports for jobId: $jobId');
      final response = await _api.get(Endpoint.getInspectionRegister(jobId), requiresAuth: true);

      final data = response.data;
      if (data is Map<String, dynamic>) {
        print('✅ Approval report data received');
        return ApprovalReportModel.fromJson(data);
      }

      print('❌ Unexpected response format: ${data.runtimeType}');
      throw Exception('Unexpected response format: ${data.runtimeType}');
    } catch (e) {
      print('❌ Error fetching approval report: $e');
      throw Exception('Failed to fetch approval report: $e');
    }
  }

  @override
  Future<dynamic> createJobItem(Map<String, dynamic> jobItemData) async {
    try {
      final response = await _api.post(
        Endpoint.jobItemCreate,
        data: jobItemData,
        requiresAuth: true,
      );

      if (response.statusCode == 202 && response.data['queued'] == true) {
        return {
          'message': 'Job item saved locally. Will sync when online.',
          'queued': true,
          'requestId': response.data['requestId'],
        };
      }

      return response.data;
    } catch (e) {
      print('❌ Error creating job item: $e');
      throw Exception('Failed to create job item: $e');
    }
  }

  @override
  Future<dynamic> createJob(Map<String, dynamic> jobData) async {
    try {
      final response = await _api.post(Endpoint.jobCreate, data: jobData, requiresAuth: true);

      if (response.statusCode == 202 && response.data['queued'] == true) {
        return {
          'message': 'Job saved locally. Will sync when online.',
          'queued': true,
          'requestId': response.data['requestId'],
        };
      }

      return response.data;
    } catch (e) {
      print('❌ Error creating job: $e');
      throw Exception('Failed to create job: $e');
    }
  }

  @override
  Future<dynamic> updateApprovalStatus(String itemId) async {
    try {
      final response = await _api.put(
        Endpoint.updateReportApproval(itemId),
        data: {'isApproved': true},
        requiresAuth: true,
      );

      // Check if request was queued (offline mode)
      if (response.statusCode == 202 && response.data['queued'] == true) {
        print('📝 Approval status queued for sync');
        return {
          'message': 'Approval status saved locally. Will sync when online.',
          'queued': true,
          'requestId': response.data['requestId'],
        };
      }

      print('✅ Approval status updated successfully');
      return response.data;
    } catch (e) {
      print('❌ Error updating approval status: $e');
      throw Exception('Failed to update approval status: $e');
    }
  }

  //////
  @override
  Future<ReportApprovalModel> fetchReportApprovals(String jobId, bool isApproved) async {
    try {
      final endpoint =
          isApproved
              ? Endpoint.getReportApprovalDataTrue(jobId) // /reportData/approval/{jobId}/true
              : Endpoint.getReportApprovalDataFalse(jobId); // /reportData/approval/{jobId}/false

      print('📡 Fetching ${isApproved ? "approved" : "pending"} reports from: $endpoint');

      final response = await _api.get(endpoint, requiresAuth: true);

      if (response.statusCode == 200) {
        final model = ReportApprovalModel.fromJson(response.data);
        print(
          '✅ Fetched ${model.data?.length ?? 0} ${isApproved ? "approved" : "pending"} reports',
        );
        return model;
      } else {
        throw Exception('Failed to load report approvals: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error fetching report approvals: $e');
      throw Exception('Error fetching report approvals: $e');
    }
  }

  /// Approve a report
  Future<Map<String, dynamic>> approveReport(String reportId) async {
    try {
      // Update with your actual approve endpoint
      final response = await _api.put(
        '/reportData/approve/$reportId', // Or '/reportData/$reportId/approve'
        data: {'approvalStatus': 'approved', 'approvedAt': DateTime.now().toIso8601String()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Report approved successfully', 'data': response.data};
      } else {
        throw Exception('Failed to approve report: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error approving report: $e');
      throw Exception('Error approving report: $e');
    }
  }

  /// Reject a report
  Future<Map<String, dynamic>> rejectReport(String reportId, {String? reason}) async {
    try {
      // Update with your actual reject endpoint
      final response = await _api.put(
        '/reportData/reject/$reportId', // Or '/reportData/$reportId/reject'
        data: {
          'approvalStatus': 'rejected',
          'rejectedAt': DateTime.now().toIso8601String(),
          if (reason != null) 'rejectionReason': reason,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Report rejected successfully', 'data': response.data};
      } else {
        throw Exception('Failed to reject report: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error rejecting report: $e');
      throw Exception('Error rejecting report: $e');
    }
  }
}
