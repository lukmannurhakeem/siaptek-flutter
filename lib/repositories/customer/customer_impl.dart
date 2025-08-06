import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/model/get_customer_model.dart';
import 'package:base_app/repositories/customer/customer_repository.dart';
import 'package:base_app/route/endpoint.dart';

class CustomerImpl implements CustomerRepository {
  final ApiClient _api;

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
    await _api.post(
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
  }
}
