import 'package:INSPECT/core/service/offline_http_service.dart';
import 'package:INSPECT/model/get_site_model.dart';
import 'package:INSPECT/model/site_customer_by_id_model.dart';
import 'package:INSPECT/repositories/site/site_repository.dart';
import 'package:INSPECT/route/endpoint.dart';

class SiteImpl implements SiteRepository {
  final OfflineHttpService _api; // Changed from ApiClient

  SiteImpl(this._api);

  @override
  Future<GetSiteModel> fetchSite() async {
    final response = await _api.get(Endpoint.site, requiresAuth: true);
    return GetSiteModel.fromJson(response.data);
  }

  @override
  Future<void> createSite({
    required String siteCode,
    required String siteName,
    required String division,
    required String customerCode,
    required String customerId,
    required String address,
    required String status,
  }) async {
    final response = await _api.post(
      Endpoint.createSite,
      requiresAuth: true,
      data: {
        'sitecode': siteCode,
        'sitename': siteName,
        'divisionId': division,
        'customercode': customerCode,
        'customerid': customerId,
        'address': address,
        'status': status,
      },
    );

    // Check if queued
    if (response.statusCode == 202 && response.data['queued'] == true) {
      throw Exception('Site saved locally. Will sync when online.');
    }
  }

  @override
  Future<GetSiteByCustomerIdModel> fetchSiteByCustomerId({required String customerId}) async {
    final response = await _api.get(Endpoint.getSiteByCustomerId(customerId), requiresAuth: true);
    return GetSiteByCustomerIdModel.fromJson(response.data);
  }
}
