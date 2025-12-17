import 'dart:typed_data';

import 'package:INSPECT/model/get_company_division.dart';
import 'package:INSPECT/model/get_report_type_model.dart';
import 'package:INSPECT/model/item_report_model.dart';

abstract class SystemRepository {
  Future<List<GetCompanyDivision>> fetchCompanyDivision();

  Future<GetReportTypeModel> fetchReportTypeModel();

  Future<List<ItemReportModel>> fetchReportDataTypeModel(String reportTypeId);

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
  });

  Future<void> deleteDivision(GetCompanyDivision division);

  Future<Map<String, dynamic>?> createReport(Map<String, dynamic> requestBody);

  Future<Map<String, dynamic>?> updateReport(String reportId, Map<String, dynamic> requestBody);

  Future<void> deleteReport(String reportId);

  Future<Map<String, dynamic>?> getReportDetails(String reportId);

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
  });

  Future<Map<String, dynamic>?> getReportFields(String reportTypeId);

  Future<Uint8List?> fetchPdfReportById(String reportTypeId);

  Future<Map<String, dynamic>?> createReportData(Map<String, dynamic> requestBody);

  // New method for creating cycle
  Future<Map<String, dynamic>?> createCycle({
    required String reportTypeId,
    String? categoryId,
    String? customerId,
    String? siteId,
    required String unit,
    required int duration,
    int? minLength,
    int? maxLength,
  });
}
