import 'package:INSPECT/core/service/offline_http_service.dart';
import 'package:INSPECT/model/approval_report_model.dart';
import 'package:INSPECT/model/job_model.dart';
import 'package:INSPECT/model/job_register.dart';
import 'package:INSPECT/model/report_approval_model.dart';
import 'package:INSPECT/repositories/job/job_repository.dart';
import 'package:INSPECT/route/endpoint.dart';

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

  @override
  Future<ReportApprovalModel?> fetchReportApprovals(String jobId, bool isApproved) async {
    try {
      final endpoint =
          isApproved
              ? Endpoint.getReportApprovalDataTrue(jobId) // /reportData/approval/{jobId}/true
              : Endpoint.getReportApprovalDataFalse(jobId); // /reportData/approval/{jobId}/false

      print('📡 Fetching ${isApproved ? "approved" : "pending"} reports from: $endpoint');

      final response = await _api.get(endpoint, requiresAuth: true);

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle case where response might be null or empty
        if (data == null) {
          print('⚠️ Received null response data');
          return null;
        }

        final model = ReportApprovalModel.fromJson(data);

        // Check if the model has data
        final reportCount = model.data?.length ?? 0;
        print('✅ Fetched $reportCount ${isApproved ? "approved" : "pending"} reports');

        // Return the model even if data is empty (model with empty list is different from null)
        return model;
      } else {
        print('⚠️ Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to load report approvals: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Error fetching report approvals: $e');
      // Return null instead of throwing to allow graceful handling
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> approveReport(String reportId) async {
    try {
      // Update with your actual approve endpoint
      final response = await _api.put(
        '/reportData/approve/$reportId', // Or '/reportData/$reportId/approve'
        data: {'approvalStatus': 'approved', 'approvedAt': DateTime.now().toIso8601String()},
        requiresAuth: true,
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

  @override
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
        requiresAuth: true,
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
