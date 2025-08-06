import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/model/get_site_model.dart';
import 'package:base_app/repositories/site/site_repository.dart';
import 'package:base_app/route/endpoint.dart';

class SiteImpl implements SiteRepository {
  final ApiClient _api;

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
        'division': division,
        'customercode': customerCode,
        'customerid': customerId,
        'address': address,
        'status': status,
      },
    );
  }
}
