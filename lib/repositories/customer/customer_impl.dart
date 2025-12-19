import 'package:INSPECT/core/service/offline_http_service.dart';
import 'package:INSPECT/model/get_customer_model.dart';
import 'package:INSPECT/repositories/customer/customer_repository.dart';
import 'package:INSPECT/route/endpoint.dart';

class CustomerImpl implements CustomerRepository {
  final OfflineHttpService _api;

  CustomerImpl(this._api);

  @override
  Future<GetCustomerModel> fetchCustomer() async {
    final response = await _api.get(Endpoint.customer, requiresAuth: true);
    return GetCustomerModel.fromJson(response.data);
  }

  @override
  @override
Future<void> createCustomer({
  required String customerId,
  required String customerName,
  required String siteCode,
  required String accountCode,
  required String divisionId,
  String? agent,
  String? notes,
  String? logo,
  String? address,
}) async {
  final response = await _api.post(
    Endpoint.createCustomer,
    requiresAuth: true,
    data: {
      'customerid': customerId,
      'customername': customerName,
      'sitecode': siteCode,
      'account_code': accountCode,
      'divisionid': divisionId,
      if (agent != null) 'agent': agent,
      if (notes != null) 'notes': notes,
      if (logo != null) 'logo': logo,
      if (address != null) 'address': address,
    },
  );

  // Check if queued
  if (response.statusCode == 202 && response.data['queued'] == true) {
    throw Exception('Customer saved locally. Will sync when online.');
  }
}

  @override
  Future<Map<String, dynamic>> getDashboardCustomer(String customerId) async {
    final response = await _api.get(Endpoint.getDashboardCustomer(customerId), requiresAuth: true);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getDashboardSite(String customerId) async {
    final response = await _api.get(Endpoint.getDashboardSite(customerId), requiresAuth: true);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getDashboardStatistic(String customerId) async {
    final response = await _api.get(Endpoint.getDashboardStatistic(customerId), requiresAuth: true);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getDashboardReports(String customerId) async {
    final response = await _api.get(Endpoint.getDashboardReports(customerId), requiresAuth: true);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getDashboardItems(String customerId) async {
    final response = await _api.get(Endpoint.getDashboardItems(customerId), requiresAuth: true);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getDashboardJobs(String customerId) async {
    final response = await _api.get(Endpoint.getDashboardJobs(customerId), requiresAuth: true);
    return response.data as Map<String, dynamic>;
  }
}
