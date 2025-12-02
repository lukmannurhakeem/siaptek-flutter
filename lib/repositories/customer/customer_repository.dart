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

  Future<Map<String, dynamic>> getDashboardCustomer(String customerId);

  Future<Map<String, dynamic>> getDashboardSite(String customerId);

  Future<Map<String, dynamic>> getDashboardStatistic(String customerId);

  Future<Map<String, dynamic>> getDashboardReports(String customerId);

  Future<Map<String, dynamic>> getDashboardItems(String customerId);

  Future<Map<String, dynamic>> getDashboardJobs(String customerId);
}
