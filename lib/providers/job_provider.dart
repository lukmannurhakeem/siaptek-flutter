import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/get_customer_model.dart';
import 'package:base_app/model/job_model.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/repositories/customer/customer_repository.dart';
import 'package:base_app/repositories/job/job_repository.dart';
import 'package:base_app/widget/common_snackbar.dart';
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

  // Search state
  SearchColumnType? _selectedSearchColumn;
  dynamic _selectedSearchValue;

  SearchColumnType? get selectedSearchColumn => _selectedSearchColumn;

  dynamic get selectedSearchValue => _selectedSearchValue;

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

  /// Fetch job register model from repository
  Future<void> fetchJobRegisterModel(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final model = await _jobRepository.fetchJobRegisterModel();
      _jobRegisterModel = model;
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

  /// Filter methods for different tabs (Job Register Items)
  List<Item> getFilteredItems(int tabIndex) {
    final items = jobItems;
    switch (tabIndex) {
      case 0: // All Items
        return items;
      case 1: // Inspected/Active (items with accepted inspection status)
        return items
            .where(
              (item) =>
                  item.inspectionStatus?.toLowerCase() == 'accepted' ||
                  item.status?.toLowerCase() == 'active',
            )
            .toList();
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
  Future<void> createJobItem(BuildContext context, Map<String, dynamic> jobItemData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _jobRepository.createJobItem(jobItemData);

      if (context.mounted) {
        CommonSnackbar.showSuccess(context, result["message"] ?? "Job item created successfully");
      }

      // Refresh items after creation
      await fetchJobRegisterModel(context);

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

  /// Reset provider state
  void reset() {
    _jobModel = null;
    _jobRegisterModel = null;
    _getCustomerModel = null;
    _customers = [];
    _isLoading = false;
    _error = null;
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
