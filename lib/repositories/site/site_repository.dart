import 'package:base_app/model/get_site_model.dart';
import 'package:base_app/model/site_customer_by_id_model.dart';

abstract class SiteRepository {
  Future<GetSiteModel> fetchSite();

  Future<GetSiteByCustomerIdModel> fetchSiteByCustomerId({required String customerId});

  Future<void> createSite({
    required String siteCode,
    required String siteName,
    required String division,
    required String customerCode,
    required String customerId,
    required String address,
    required String status,
  });
}
