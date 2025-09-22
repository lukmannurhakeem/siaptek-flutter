import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/get_customer_model.dart';
import 'package:base_app/model/job_model.dart';
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

  Future<void> fetchCustomers(BuildContext context) async {
    try {
      final model = await _customerRepository.fetchCustomer();
      _getCustomerModel = model;
      _customers = model.customers ?? [];
      notifyListeners(); // Important to update the UI
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

  // Dispose controllers
  @override
  void dispose() {
    customerIdController.dispose();
    siteCodeController.dispose();
    customerCodeController.dispose();
    divisionController.dispose();
    statusController.dispose();
    customerNameController.dispose();
    super.dispose();
  }
}
