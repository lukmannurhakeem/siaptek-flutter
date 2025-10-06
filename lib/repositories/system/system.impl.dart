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
    try {
      final response = await _api.get(Endpoint.companyDivision, requiresAuth: true);

      if (response.data is List) {
        return (response.data as List<dynamic>)
            .map((json) => GetCompanyDivision.fromJson(json))
            .toList();
      } else {
        return [GetCompanyDivision.fromJson(response.data)];
      }
    } catch (e) {
      throw Exception('Failed to fetch company divisions: $e');
    }
  }

  @override
  Future<GetReportTypeModel> fetchReportTypeModel() async {
    try {
      final response = await _api.get(Endpoint.reportType, requiresAuth: true);
      return GetReportTypeModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch report types: $e');
    }
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
    try {
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
    } catch (e) {
      throw Exception('Failed to create division: $e');
    }
  }

  @override
  Future<void> deleteDivision(GetCompanyDivision division) async {
    try {
      // Prepare request body as per your API specification
      final requestBody = {
        "division_id": division.divisionid,
        "customer_id": division.customerid,
        "division_name": division.divisionname,
        "division_code": division.divisioncode,
        "logo": division.logo,
        "address": division.address,
        "telephone": division.telephone,
        "website": division.website,
        "email": division.email,
        "fax": division.fax,
        "culture": division.culture,
        "timezone": division.timezone,
      };

      await _api.delete(
        '${Endpoint.deleteDivision}/${division.divisionid}',
        requiresAuth: true,
        data: requestBody,
      );
    } catch (e) {
      throw Exception('Failed to delete division: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> createReport(Map<String, dynamic> requestBody) async {
    try {
      final response = await _api.post(
        Endpoint.createReport,
        requiresAuth: true,
        data: requestBody,
      );
      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> updateReport(
    String reportId,
    Map<String, dynamic> requestBody,
  ) async {
    try {
      final response = await _api.put(
        '${Endpoint.reportType}/$reportId',
        requiresAuth: true,
        data: requestBody,
      );
      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await _api.delete('${Endpoint.deleteReportType}/$reportId', requiresAuth: true);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getReportDetails(String reportId) async {
    try {
      final response = await _api.get('${Endpoint.reportType}/$reportId', requiresAuth: true);
      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to get report details: $e');
    }
  }

  // Add this method to your SystemImpl class

  @override
  Future<void> updateDivision({
    required String divisionId,
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
    try {
      await _api.put(
        '${Endpoint.updateDivision}/$divisionId',
        requiresAuth: true,
        data: {
          if (customerid != null) "customerid": customerid,
          if (divisionname != null) "divisionname": divisionname,
          if (divisioncode != null) "divisioncode": divisioncode,
          if (logo != null) "logo": logo,
          if (address != null) "address": address,
          if (telephone != null) "telephone": telephone,
          if (website != null) "website": website,
          if (email != null) "email": email,
          if (fax != null) "fax": fax,
          if (culture != null) "culture": culture,
          if (timezone != null) "timezone": timezone,
        },
      );
    } catch (e) {
      throw Exception('Failed to update division: $e');
    }
  }
}
