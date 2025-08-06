import 'package:base_app/model/get_customer_model.dart';

abstract class CustomerRepository {
  Future<GetCustomerModel> fetchCustomer();

  Future<void> createCustomer({
    required String customerId,
    required String siteCode,
    required String customerCode,
    required String division,
    required String status,
    required String customerName,
  });
}
