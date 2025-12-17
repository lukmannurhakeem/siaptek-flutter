import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/core/service/service_locator.dart';
import 'package:INSPECT/model/dahboard_model.dart';
import 'package:INSPECT/model/get_customer_model.dart';
import 'package:INSPECT/repositories/customer/customer_repository.dart';
import 'package:INSPECT/widget/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository = ServiceLocator().customerRepository;

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

  // Dashboard specific data
  DashboardModel? _dashboardData;

  DashboardModel? get dashboardData => _dashboardData;

  StatisticsData? _statisticsData;

  StatisticsData? get statisticsData => _statisticsData;

  List<ItemData> _itemsData = [];

  List<ItemData> get itemsData => _itemsData;

  // Loading states
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isFetching = false;

  bool get isFetching => _isFetching;

  bool _isCreating = false;

  bool get isCreating => _isCreating;

  bool _isDashboardLoading = false;

  bool get isDashboardLoading => _isDashboardLoading;

  // Expose repository for direct access
  CustomerRepository get customerRepository => _customerRepository;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetching(bool value) {
    _isFetching = value;
    notifyListeners();
  }

  void _setCreating(bool value) {
    _isCreating = value;
    notifyListeners();
  }

  void _setDashboardLoading(bool value) {
    _isDashboardLoading = value;
    notifyListeners();
  }

  // Fetch customers list
  Future<void> fetchCustomers(BuildContext context) async {
    _setFetching(true);
    try {
      final model = await _customerRepository.fetchCustomer();
      _getCustomerModel = model;
      _customers = model.customers ?? [];
      notifyListeners();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    } finally {
      _setFetching(false);
    }
  }

  // Create new customer
  Future<void> createCustomer(BuildContext context) async {
    _setCreating(true);
    _setLoading(true);
    try {
      await _customerRepository.createCustomer(
        customerCode: customerCodeController.text,
        customerId: uuid.v4(),
        customerName: customerNameController.text,
        division: divisionController.text,
        siteCode: siteCodeController.text,
        status: statusController.text,
      );

      await fetchCustomers(context);
      NavigationService().goBack();
      CommonSnackbar.showSuccess(context, "Customer created successfully");

      // Clear controllers after successful creation
      _clearControllers();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    } finally {
      _setCreating(false);
      _setLoading(false);
    }
  }

  // Fetch complete dashboard data
  Future<void> fetchDashboardData(BuildContext context, String customerId) async {
    _setDashboardLoading(true);
    try {
      final response = await _customerRepository.getDashboardCustomer(customerId);

      if (response['success'] == true && response['data'] != null) {
        _dashboardData = DashboardModel.fromJson(response['data']);
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to load dashboard data');
      }
    } catch (e) {
      CommonSnackbar.showError(context, 'Failed to load dashboard: ${e.toString()}');
    } finally {
      _setDashboardLoading(false);
    }
  }

  // Fetch statistics data
  Future<void> fetchStatistics(BuildContext context, String customerId) async {
    try {
      final response = await _customerRepository.getDashboardStatistic(customerId);

      if (response['success'] == true && response['data'] != null) {
        _statisticsData = StatisticsData.fromJson(response['data']);
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to load statistics');
      }
    } catch (e) {
      CommonSnackbar.showError(context, 'Failed to load statistics: ${e.toString()}');
    }
  }

  // Fetch items data
  Future<void> fetchItems(BuildContext context, String customerId) async {
    try {
      final response = await _customerRepository.getDashboardItems(customerId);

      if (response['success'] == true && response['data'] != null) {
        _itemsData = (response['data'] as List).map((item) => ItemData.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to load items');
      }
    } catch (e) {
      CommonSnackbar.showError(context, 'Failed to load items: ${e.toString()}');
    }
  }

  // Fetch all dashboard data at once (parallel requests)
  Future<void> fetchAllDashboardData(BuildContext context, String customerId) async {
    _setDashboardLoading(true);
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _customerRepository.getDashboardCustomer(customerId),
        _customerRepository.getDashboardStatistic(customerId),
        _customerRepository.getDashboardItems(customerId),
      ]);

      // Parse dashboard data
      if (results[0]['success'] == true && results[0]['data'] != null) {
        _dashboardData = DashboardModel.fromJson(results[0]['data']);
      }

      // Parse statistics data
      if (results[1]['success'] == true && results[1]['data'] != null) {
        _statisticsData = StatisticsData.fromJson(results[1]['data']);
      }

      // Parse items data
      if (results[2]['success'] == true && results[2]['data'] != null) {
        _itemsData = (results[2]['data'] as List).map((item) => ItemData.fromJson(item)).toList();
      }

      notifyListeners();
    } catch (e) {
      CommonSnackbar.showError(context, 'Failed to load dashboard data: ${e.toString()}');
    } finally {
      _setDashboardLoading(false);
    }
  }

  // Clear dashboard data
  void clearDashboardData() {
    _dashboardData = null;
    _statisticsData = null;
    _itemsData = [];
    notifyListeners();
  }

  void _clearControllers() {
    customerIdController.clear();
    siteCodeController.clear();
    customerCodeController.clear();
    divisionController.clear();
    statusController.clear();
    customerNameController.clear();
    addressController.clear();
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
    addressController.dispose();
    super.dispose();
  }
}
