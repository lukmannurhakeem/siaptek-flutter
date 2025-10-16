import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/get_customer_model.dart';
import 'package:base_app/repositories/customer/customer_repository.dart';
import 'package:base_app/route/endpoint.dart';

class CustomerImpl implements CustomerRepository {
  final OfflineHttpService _api; // Changed from ApiClient

  CustomerImpl(this._api);

  @override
  Future<GetCustomerModel> fetchCustomer() async {
    final response = await _api.get(Endpoint.customer, requiresAuth: true);
    return GetCustomerModel.fromJson(response.data);
  }

  @override
  Future<void> createCustomer({
    required String customerId,
    required String siteCode,
    required String customerCode,
    required String division,
    required String status,
    required String customerName,
  }) async {
    final response = await _api.post(
      Endpoint.createCustomer,
      requiresAuth: true,
      data: {
        'customerid': customerId,
        'sitecode': siteCode,
        'customercode': customerCode,
        'division': division,
        'status': status,
        'customername': customerName,
      },
    );

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      throw Exception('Customer saved locally. Will sync when online.');
    }
  }
}
