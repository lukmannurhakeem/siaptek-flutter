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

  var uuid = Uuid();

  GetCustomerModel? _getCustomerModel;

  GetCustomerModel? get getCustomerModel => _getCustomerModel;

  List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  int sortColumnIndex = 0;

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

  Future<void> fetchCustomers(BuildContext context) async {
    try {
      final model = await _customerRepository.fetchCustomer();
      _getCustomerModel = model;
      _customers = model.customers ?? [];
      notifyListeners();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    }
  }

  Future<void> fetchJobModel(BuildContext context) async {
    try {
      final model = await _jobRepository.fetchJobModel();
      _jobModel = model;
      notifyListeners();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    }
  }

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
      CommonSnackbar.showError(context, e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter methods for different tabs
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

  // Search functionality
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

  Future<void> createCustomer(BuildContext context) async {
    try {
      await _customerRepository.createCustomer(
        customerCode: customerCodeController.text,
        customerId: uuid.v4(),
        customerName: customerNameController.text,
        division: divisionController.text,
        siteCode: siteCodeController.text,
        status: statusController.text,
      );

      fetchCustomers(context);
      NavigationService().goBack();
      CommonSnackbar.showSuccess(context, "Customer created successfully");
      notifyListeners();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    }
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
