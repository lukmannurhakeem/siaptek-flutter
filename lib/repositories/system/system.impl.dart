import 'package:base_app/core/service/http_service.dart';
import 'package:base_app/model/get_company_division.dart';
import 'package:base_app/model/get_report_type_model.dart';
import 'package:base_app/repositories/system/system_repository.dart';
import 'package:base_app/route/endpoint.dart';

class SystemImpl implements SystemRepository {
  final ApiClient _api;

  SystemImpl(this._api);

  @override
  Future<List<GetCompanyDivision>> fetchCompanyDivision() async {
    final response = await _api.get(Endpoint.companyDivision, requiresAuth: true);

    if (response.data is List) {
      return (response.data as List<dynamic>)
          .map((json) => GetCompanyDivision.fromJson(json))
          .toList();
    } else {
      // If API sometimes returns single object, wrap it in a list
      return [GetCompanyDivision.fromJson(response.data)];
    }
  }

  @override
  Future<GetReportTypeModel> fetchReportTypeModel() async {
    final response = await _api.get(Endpoint.reportType, requiresAuth: true);

    return GetReportTypeModel.fromJson(response.data);
  }

  @override
  Future<void> createDivision({
    String? customerid,
    String? divisionname,
    String? divisioncode,
    String? logo,
    String? address,
    String? telephone,
    String? website,
    String? email,
    String? fax,
    String? culture,
    String? timezone,
  }) async {
    await _api.post(
      Endpoint.createDivision,
      requiresAuth: true,
      data: {
        "customerid": customerid,
        "divisionname": divisionname,
        "divisioncode": divisioncode,
        "logo": logo,
        "address": address,
        "telephone": telephone,
        "website": website,
        "email": email,
        "fax": fax,
        "culture": culture,
        "timezone": timezone,
      },
    );
  }

  @override
  Future<Map<String, dynamic>?> createReport(Map<String, dynamic> requestBody) async {
    final response = await _api.post(
      Endpoint.createReport, // You'll need to add this to your endpoint constants
      requiresAuth: true,
      data: requestBody,
    );

    // Return the response data in case there's useful information like report ID
    return response.data is Map<String, dynamic> ? response.data : null;
  }
}
