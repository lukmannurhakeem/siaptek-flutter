import 'package:base_app/model/get_site_model.dart';

abstract class SiteRepository {
  Future<GetSiteModel> fetchSite();

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
