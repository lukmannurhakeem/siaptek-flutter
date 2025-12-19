import 'package:INSPECT/model/get_customer_model.dart';

abstract class CustomerRepository {
 Future<GetCustomerModel> fetchCustomer();

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
  });

  Future<Map<String, dynamic>> getDashboardCustomer(String customerId);

  Future<Map<String, dynamic>> getDashboardSite(String customerId);

  Future<Map<String, dynamic>> getDashboardStatistic(String customerId);

  Future<Map<String, dynamic>> getDashboardReports(String customerId);

  Future<Map<String, dynamic>> getDashboardItems(String customerId);

  Future<Map<String, dynamic>> getDashboardJobs(String customerId);
}
