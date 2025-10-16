import 'dart:typed_data';

import 'package:base_app/core/service/offline_http_service.dart';
import 'package:base_app/model/get_company_division.dart';
import 'package:base_app/model/get_report_type_model.dart';
import 'package:base_app/model/item_report_model.dart';
import 'package:base_app/repositories/system/system_repository.dart';
import 'package:base_app/route/endpoint.dart';

class SystemImpl implements SystemRepository {
  final OfflineHttpService _api; // Changed from ApiClient

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
      final response = await _api.post(
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

      // Check if queued
      if (response.statusCode == 202 && response.data['queued'] == true) {
        throw Exception('Division saved locally. Will sync when online.');
      }
    } catch (e) {
      throw Exception('Failed to create division: $e');
    }
  }

  @override
  Future<void> deleteDivision(GetCompanyDivision division) async {
    try {
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

      final response = await _api.delete(
        '${Endpoint.deleteDivision}/${division.divisionid}',
        requiresAuth: true,
        data: requestBody,
      );

      // Check if queued
      if (response.statusCode == 202 && response.data['queued'] == true) {
        throw Exception('Division deletion queued. Will sync when online.');
      }
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

      // Check if queued
      if (response.statusCode == 202 && response.data['queued'] == true) {
        return {'message': 'Report saved locally. Will sync when online.', 'queued': true};
      }

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

      // Check if queued
      if (response.statusCode == 202 && response.data['queued'] == true) {
        return {'message': 'Report update queued. Will sync when online.', 'queued': true};
      }

      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      final response = await _api.delete(
        '${Endpoint.deleteReportType}/$reportId',
        requiresAuth: true,
      );

      // Check if queued
      if (response.statusCode == 202 && response.data['queued'] == true) {
        throw Exception('Report deletion queued. Will sync when online.');
      }
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
      final response = await _api.put(
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

      // Check if queued
      if (response.statusCode == 202 && response.data['queued'] == true) {
        throw Exception('Division update queued. Will sync when online.');
      }
    } catch (e) {
      throw Exception('Failed to update division: $e');
    }
  }

  Future<Map<String, dynamic>?> getReportFields(String reportTypeId) async {
    try {
      final response = await _api.get(Endpoint.getReportField(reportTypeId), requiresAuth: true);
      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to fetch report fields: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> createReportData(Map<String, dynamic> requestBody) async {
    try {
      final response = await _api.post(
        Endpoint.createReportData,
        requiresAuth: true,
        data: requestBody,
      );

      // Check if queued
      if (response.statusCode == 202 && response.data['queued'] == true) {
        return {'message': 'Report data saved locally. Will sync when online.', 'queued': true};
      }

      return response.data is Map<String, dynamic> ? response.data : null;
    } catch (e) {
      throw Exception('Failed to create report data: $e');
    }
  }

  @override
  Future<List<ItemReportModel>> fetchReportDataTypeModel(String reportTypeId) async {
    try {
      final response = await _api.get(Endpoint.getItemReport(reportTypeId), requiresAuth: true);

      final data = response.data;

      if (data is List) {
        return data.map((e) => ItemReportModel.fromJson(e)).toList();
      } else if (data is String) {
        return itemReportModelFromJson(data);
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).map((e) => ItemReportModel.fromJson(e)).toList();
      } else {
        throw Exception('Unexpected response format: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to fetch report types: $e');
    }
  }

  @override
  Future<Uint8List?> fetchPdfReportById(String reportTypeId) async {
    try {
      // Note: UnifiedHttpService doesn't have getBytes yet
      // We'll need to add it or handle binary data differently
      // For now, using regular get with binary handling
      final response = await _api.get(
        Endpoint.fetchPdfReportById(reportTypeId),
        requiresAuth: true,
      );

      final data = response.data;
      if (data != null && data is List<int>) {
        return Uint8List.fromList(data);
      }

      throw Exception('Invalid PDF response format');
    } catch (e) {
      throw Exception('Failed to fetch PDF: $e');
    }
  }
}
