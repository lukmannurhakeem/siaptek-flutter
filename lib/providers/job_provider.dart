import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/core/service/service_locator.dart';
import 'package:INSPECT/model/get_customer_model.dart';
import 'package:INSPECT/model/job_model.dart';
import 'package:INSPECT/model/job_register.dart';
import 'package:INSPECT/model/report_approval_model.dart';
import 'package:INSPECT/repositories/customer/customer_repository.dart';
import 'package:INSPECT/repositories/job/job_repository.dart';
import 'package:INSPECT/widget/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Define SearchColumnType enum
enum SearchColumnType { customer, jobNo, site, status }

class JobProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository = ServiceLocator().customerRepository;
  final JobRepository _jobRepository = ServiceLocator().jobRepository;

  // TextEditingControllers
  final TextEditingController customerIdController = TextEditingController();
  final TextEditingController siteCodeController = TextEditingController();
  final TextEditingController customerCodeController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  var uuid = const Uuid();

  GetCustomerModel? _getCustomerModel;

  GetCustomerModel? get getCustomerModel => _getCustomerModel;

  List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  int? sortColumnIndex;
  bool sortAscending = true;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;

  String? get error => _error;

  JobModel? _jobModel;

  JobModel? get jobModel => _jobModel;

  // Job Register Model
  JobRegisterModel? _jobRegisterModel;

  JobRegisterModel? get jobRegisterModel => _jobRegisterModel;

  List<Item> get jobItems => _jobRegisterModel?.items ?? [];

  // Track current jobId to detect changes
  String? _currentJobId;

  // Search state
  SearchColumnType? _selectedSearchColumn;
  dynamic _selectedSearchValue;

  SearchColumnType? get selectedSearchColumn => _selectedSearchColumn;

  dynamic get selectedSearchValue => _selectedSearchValue;

  // Add this property to store current item
  Item? _currentItem;

  Item? get currentItem => _currentItem;

  ReportApprovalModel? _reportApprovalModel;

  ReportApprovalModel? get reportApprovalModel => _reportApprovalModel;

  bool _isUpdatingApproval = false;

  bool get isUpdatingApproval => _isUpdatingApproval;

  String? _approvalError;

  String? get approvalError => _approvalError;

  ///////////////////////////////////////
  // Report Approval Properties
  ///////////////////////////////////////
  ReportApprovalModel? _pendingReportApprovals;
  ReportApprovalModel? _approvedReportApprovals;

  String _currentApprovalFilter = 'pending'; // 'pending', 'approved', 'all'

  String get currentApprovalFilter => _currentApprovalFilter;

  // ✅ NEW: Track if we've attempted to fetch data
  bool _hasAttemptedFetch = false;

  bool get hasAttemptedFetch => _hasAttemptedFetch;

  // Check if approval data has been loaded (models exist)
  bool get hasLoadedApprovals =>
      _pendingReportApprovals != null || _approvedReportApprovals != null;

  // Get reports based on current filter
  List<ReportApprovalData> get reportApprovals {
    switch (_currentApprovalFilter) {
      case 'pending':
        return _pendingReportApprovals?.data ?? [];
      case 'approved':
        return _approvedReportApprovals?.data ?? [];
      case 'all':
        final pending = _pendingReportApprovals?.data ?? [];
        final approved = _approvedReportApprovals?.data ?? [];
        return [...pending, ...approved];
      default:
        return _pendingReportApprovals?.data ?? [];
    }
  }

  // Get pending reports only
  List<ReportApprovalData> get pendingReports => _pendingReportApprovals?.data ?? [];

  // Get approved reports only
  List<ReportApprovalData> get approvedReports => _approvedReportApprovals?.data ?? [];

  /// Set approval filter
  void setApprovalFilter(String filter) {
    _currentApprovalFilter = filter;
    notifyListeners();
  }

  /// Fetch report approvals for a specific job (both pending and approved)
  Future<void> fetchReportApprovals(
    BuildContext context,
    String jobId, {
    bool fetchBoth = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📥 Fetching Report Approvals for jobId: $jobId');

      if (fetchBoth) {
        final results = await Future.wait([
          _jobRepository.fetchReportApprovals(jobId, false), // Pending
          _jobRepository.fetchReportApprovals(jobId, true), // Approved
        ]);

        // ✅ FIXED: Keep the models even if data is empty
        // The getters handle null by returning empty lists
        _pendingReportApprovals = results[0];
        _approvedReportApprovals = results[1];

        print('✅ Pending reports: ${_pendingReportApprovals?.data?.length ?? 0}');
        print('✅ Approved reports: ${_approvedReportApprovals?.data?.length ?? 0}');
      } else {
        if (_currentApprovalFilter == 'pending') {
          final result = await _jobRepository.fetchReportApprovals(jobId, false);
          _pendingReportApprovals = result;
        } else if (_currentApprovalFilter == 'approved') {
          final result = await _jobRepository.fetchReportApprovals(jobId, true);
          _approvedReportApprovals = result;
        }
      }

      _hasAttemptedFetch = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _hasAttemptedFetch = true;
      print('❌ Error fetching Report Approvals: $_error');
      if (context.mounted) {
        CommonSnackbar.showError(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve a specific report
  Future<Map<String, dynamic>?> approveReport(
    BuildContext context,
    String reportId,
    String jobId,
  ) async {
    try {
      _isUpdatingApproval = true;
      _approvalError = null;
      notifyListeners();

      print('✅ Provider: Approving report... $reportId');

      // Call your API to approve
      await _jobRepository.approveReport(reportId);

      // ✅ Refresh BOTH lists after approval
      // This ensures the report moves from pending to approved
      await fetchReportApprovals(context, jobId, fetchBoth: true);

      _isUpdatingApproval = false;
      notifyListeners();

      if (context.mounted) {
        CommonSnackbar.showSuccess(context, 'Report approved successfully');
      }

      return {'success': true, 'message': 'Report approved successfully'};
    } catch (e) {
      _approvalError = e.toString();
      _isUpdatingApproval = false;
      notifyListeners();

      if (context.mounted) {
        CommonSnackbar.showError(context, 'Failed to approve report: $e');
      }

      return {'success': false, 'error': e.toString()};
    }
  }

  /// Reject a specific report
  Future<Map<String, dynamic>?> rejectReport(
    BuildContext context,
    String reportId,
    String jobId, {
    String? reason,
  }) async {
    try {
      _isUpdatingApproval = true;
      _approvalError = null;
      notifyListeners();

      print('❌ Provider: Rejecting report... $reportId');

      // Call your API to reject
      await _jobRepository.rejectReport(reportId, reason: reason);

      // ✅ Refresh BOTH lists after rejection
      await fetchReportApprovals(context, jobId, fetchBoth: true);

      _isUpdatingApproval = false;
      notifyListeners();

      if (context.mounted) {
        CommonSnackbar.showSuccess(context, 'Report rejected');
      }

      return {'success': true, 'message': 'Report rejected successfully'};
    } catch (e) {
      _approvalError = e.toString();
      _isUpdatingApproval = false;
      notifyListeners();

      if (context.mounted) {
        CommonSnackbar.showError(context, 'Failed to reject report: $e');
      }

      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get approval statistics from both lists
  Map<String, int> getApprovalStats() {
    final pending = _pendingReportApprovals?.data ?? [];
    final approved = _approvedReportApprovals?.data ?? [];

    return {
      'total': pending.length + approved.length,
      'pending': pending.length,
      'approved': approved.length,
      'rejected': 0, // If you have rejected reports, add them here
    };
  }

  /// Check if there are pending approvals
  bool hasPendingApprovals() {
    return (_pendingReportApprovals?.data?.length ?? 0) > 0;
  }

  /// Get count of pending approvals
  int getPendingApprovalsCount() {
    return _pendingReportApprovals?.data?.length ?? 0;
  }

  /// Filter report approvals by status (works with current data)
  List<ReportApprovalData> filterReportsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'all':
        return reportApprovals;
      case 'pending':
        return pendingReports;
      case 'approved':
        return approvedReports;
      case 'rejected':
        // If you track rejected separately, return them here
        return [];
      default:
        return reportApprovals;
    }
  }

  /// Search report approvals (searches current filtered list)
  List<ReportApprovalData> searchReports(String query, String view) {
    // ✅ FIX: Access the .data property to get List<ReportApprovalData>
    List<ReportApprovalData> sourceList =
        view == 'pending'
            ? (_pendingReportApprovals?.data ?? [])
            : (_approvedReportApprovals?.data ?? []);

    if (query.isEmpty) return sourceList;

    // Apply search filter
    final searchLower = query.toLowerCase();
    return sourceList.where((report) {
      return (report.reportName?.toLowerCase().contains(searchLower) ?? false) ||
          (report.itemNo?.toLowerCase().contains(searchLower) ?? false) ||
          (report.displayInspector.toLowerCase().contains(searchLower));
    }).toList();
  }

  /// Clear report approvals
  void clearReportApprovals() {
    _pendingReportApprovals = null;
    _approvedReportApprovals = null;
    _currentApprovalFilter = 'pending';
    _hasAttemptedFetch = false; // ✅ Reset flag
    notifyListeners();
  }

  /// Update reset method to include both approval lists
  void reset() {
    _jobModel = null;
    _jobRegisterModel = null;
    _pendingReportApprovals = null;
    _approvedReportApprovals = null;
    _currentApprovalFilter = 'pending';
    _hasAttemptedFetch = false; // ✅ Reset flag
    _getCustomerModel = null;
    _customers = [];
    _isLoading = false;
    _error = null;
    sortColumnIndex = null;
    sortAscending = true;
    _selectedSearchColumn = null;
    _selectedSearchValue = null;
    _currentJobId = null;
    _currentItem = null;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////

  /// Update the approval status of a report
  Future<Map<String, dynamic>?> updateReportApprovalStatus(
    BuildContext context,
    String itemId,
  ) async {
    try {
      _isUpdatingApproval = true;
      _approvalError = null;
      notifyListeners();

      print('🔄 Provider: Updating approval status... $itemId');
      final result = await _jobRepository.updateApprovalStatus(itemId);

      // Check if request was queued for offline sync
      final bool wasQueued = result is Map<String, dynamic> && result['queued'] == true;

      _isUpdatingApproval = false;
      notifyListeners();

      print('✅ Provider: Approval status updated and list refreshed');

      return {
        'success': true,
        'queued': wasQueued,
        'message': wasQueued ? 'Saved locally. Will sync when online.' : 'Updated successfully',
      };
    } catch (e) {
      _approvalError = e.toString();
      _isUpdatingApproval = false;
      notifyListeners();

      print('❌ Provider: Error updating approval - $e');

      return {'success': false, 'error': e.toString()};
    }
  }

  /// Clear approval error
  void clearApprovalError() {
    _approvalError = null;
    notifyListeners();
  }

  /// Get item by itemID from existing jobRegisterModel data
  Item? getItemById(String itemId) {
    if (_jobRegisterModel?.items == null) return null;

    try {
      return _jobRegisterModel!.items!.firstWhere((item) => item.itemId == itemId);
    } catch (e) {
      print('Item not found with ID: $itemId');
      return null;
    }
  }

  /// Set current item
  void setCurrentItem(String itemId) {
    _currentItem = getItemById(itemId);
    notifyListeners();
  }

  /// Clear current item
  void clearCurrentItem() {
    _currentItem = null;
    notifyListeners();
  }

  /// Set search filters
  void setSearch(SearchColumnType? column, dynamic value) {
    _selectedSearchColumn = column;
    _selectedSearchValue = value;
    notifyListeners();
  }

  /// Clear search filters
  void clearSearch() {
    _selectedSearchColumn = null;
    _selectedSearchValue = null;
    notifyListeners();
  }

  /// Clear job register model
  void clearJobRegisterModel() {
    _jobRegisterModel = null;
    _currentJobId = null;
    _currentItem = null;
    notifyListeners();
  }

  /// Create a new job from job details form
  Future<void> createJobFromDetails(BuildContext context, Map<String, dynamic> jobData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call repository to create the job
      final result = await _jobRepository.createJob(jobData);

      if (context.mounted) {
        CommonSnackbar.showSuccess(context, result["message"] ?? "Job created successfully");
      }

      // Refresh job list after successful creation
      await fetchJobModel(context);

      // Navigate back to job list
      if (context.mounted) {
        NavigationService().goBack();
      }
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        CommonSnackbar.showError(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get filtered jobs based on search criteria
  List<Datum> getFilteredJobs() {
    if (_jobModel?.data == null) return [];

    final jobs = _jobModel!.data!;

    // If no filter is applied, return all jobs
    if (_selectedSearchColumn == null || _selectedSearchValue == null) {
      return jobs;
    }

    // Filter based on selected column and value
    return jobs.where((job) {
      switch (_selectedSearchColumn!) {
        case SearchColumnType.customer:
          return job.clientName == _selectedSearchValue;
        case SearchColumnType.jobNo:
          return job.jobId == _selectedSearchValue;
        case SearchColumnType.site:
          return job.siteName == _selectedSearchValue;
        case SearchColumnType.status:
          return job.startJobNow == _selectedSearchValue;
      }
    }).toList();
  }

  /// Fetch customers from repository
  Future<void> fetchCustomers(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final model = await _customerRepository.fetchCustomer();
      _getCustomerModel = model;
      _customers = model.customers ?? [];
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        CommonSnackbar.showError(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch job model from repository
  Future<void> fetchJobModel(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final model = await _jobRepository.fetchJobModel();
      _jobModel = model;
      _error = null;

      // Sort by default if data exists
      if (_jobModel?.data != null && _jobModel!.data!.isNotEmpty) {
        sortJobData(0, true); // Default sort by first column (Job No)
      }
    } catch (e) {
      _error = e.toString();
      if (context.mounted) {
        CommonSnackbar.showError(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sort job data by column index
  void sortJobData(int columnIndex, bool ascending) {
    if (_jobModel?.data == null || _jobModel!.data!.isEmpty) return;

    sortColumnIndex = columnIndex;
    sortAscending = ascending;

    _jobModel!.data!.sort((a, b) {
      int compare = 0;

      switch (columnIndex) {
        case 0: // Job No
          compare = (a.jobId ?? '').compareTo(b.jobId ?? '');
          break;
        case 1: // Customer
          compare = (a.clientName ?? '').compareTo(b.clientName ?? '');
          break;
        case 2: // Site
          compare = (a.siteName ?? '').compareTo(b.siteName ?? '');
          break;
        case 3: // Status
          compare = (a.startJobNow ?? false) ? 1 : -1;
          if (b.startJobNow ?? false) compare = compare == 1 ? 0 : -1;
          break;
        case 4: // Start Date
          if (a.estimatedStartDate == null && b.estimatedStartDate == null) {
            compare = 0;
          } else if (a.estimatedStartDate == null) {
            compare = 1;
          } else if (b.estimatedStartDate == null) {
            compare = -1;
          } else {
            compare = a.estimatedStartDate!.compareTo(b.estimatedStartDate!);
          }
          break;
        case 5: // End Date
          if (a.estimatedEndDate == null && b.estimatedEndDate == null) {
            compare = 0;
          } else if (a.estimatedEndDate == null) {
            compare = 1;
          } else if (b.estimatedEndDate == null) {
            compare = -1;
          } else {
            compare = a.estimatedEndDate!.compareTo(b.estimatedEndDate!);
          }
          break;
      }

      return ascending ? compare : -compare;
    });

    notifyListeners();
  }

  Future<void> fetchJobRegisterModel(BuildContext context, String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching Job Register for jobId: $jobId');
      final model = await _jobRepository.fetchJobRegisterModel(jobId);

      // ✅ Properly populate the Job Register model
      _jobRegisterModel = model;
      _currentJobId = jobId;
      _error = null;

      print('✅ Job Register fetched successfully for jobId: $jobId');
      print('Item count: ${_jobRegisterModel?.items?.length}');
    } catch (e) {
      _error = e.toString();
      print('❌ Error fetching Job Register: $_error');
      if (context.mounted) {
        CommonSnackbar.showError(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter methods for different tabs (Job Register Items)
  List<Item> getFilteredItems(int tabIndex) {
    final items = jobItems;
    switch (tabIndex) {
      case 0: // All Items (Item Register tab)
        return items;
      case 1: // Inspection Register - Show ALL items
        // Changed: Show all items in inspection register, not just accepted ones
        return items; // Return all items for inspection viewing
      case 2: // Not Inspected/Pending
        return items
            .where(
              (item) =>
                  item.inspectionStatus?.toLowerCase() == 'pending' ||
                  item.inspectionStatus == null,
            )
            .toList();
      case 3: // Archived
        return items.where((item) => item.archived == true).toList();
      default:
        return items;
    }
  }

  /// Search functionality for job items (Job Register)
  List<Item> searchItems(String query, int tabIndex) {
    final filteredItems = getFilteredItems(tabIndex);
    if (query.isEmpty) return filteredItems;

    return filteredItems.where((item) {
      final searchQuery = query.toLowerCase();
      return (item.itemNo?.toLowerCase().contains(searchQuery) ?? false) ||
          (item.description?.toLowerCase().contains(searchQuery) ?? false) ||
          (item.manufacturer?.toLowerCase().contains(searchQuery) ?? false) ||
          (item.detailedLocation?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  /// Create a new customer
  Future<void> createCustomer(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _customerRepository.createCustomer(
        customerCode: customerCodeController.text,
        customerId: uuid.v4(),
        customerName: customerNameController.text,
        division: divisionController.text,
        siteCode: siteCodeController.text,
        status: statusController.text,
      );

      await fetchCustomers(context);

      if (context.mounted) {
        NavigationService().goBack();
        CommonSnackbar.showSuccess(context, "Customer created successfully");
      }

      // Clear controllers after successful creation
      customerCodeController.clear();
      customerNameController.clear();
      divisionController.clear();
      siteCodeController.clear();
      statusController.clear();
    } catch (e) {
      if (context.mounted) {
        CommonSnackbar.showError(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new job item
  Future<void> createJobItem(BuildContext context, Map<String, dynamic> jobItemData, jobId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _jobRepository.createJobItem(jobItemData);

      if (context.mounted) {
        CommonSnackbar.showSuccess(context, result["message"] ?? "Job item created successfully");
      }

      // Refresh items after creation
      await fetchJobRegisterModel(context, jobId);

      if (context.mounted) {
        NavigationService().goBack();
      }
    } catch (e) {
      if (context.mounted) {
        CommonSnackbar.showError(context, e.toString());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all filters and reset sort
  void clearFiltersAndSort() {
    sortColumnIndex = null;
    sortAscending = true;
    _selectedSearchColumn = null;
    _selectedSearchValue = null;
    notifyListeners();
  }

  @override
  void dispose() {
    customerIdController.dispose();
    siteCodeController.dispose();
    customerCodeController.dispose();
    divisionController.dispose();
    statusController.dispose();
    customerNameController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
