import 'dart:typed_data';

import 'package:INSPECT/core/service/service_locator.dart';
import 'package:INSPECT/model/get_company_division.dart';
import 'package:INSPECT/model/get_report_type_model.dart';
import 'package:INSPECT/model/item_report_model.dart';
import 'package:INSPECT/repositories/system/system_repository.dart';
import 'package:flutter/material.dart';

class SystemProvider extends ChangeNotifier {
  final SystemRepository _systemRepository = ServiceLocator().systemRepository;

  List<GetCompanyDivision> _division = [];
  bool _isLoading = false;
  String? _errorMessage;
  GetReportTypeModel? _getReportTypeModel;

  List<ItemReportModel>? _itemReportModel;

  // Getters
  List<GetCompanyDivision> get divisions => _division;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasData => _division.isNotEmpty;

  bool get hasReport => _getReportTypeModel?.data != null && _getReportTypeModel!.data!.isNotEmpty;

  // Updated: Better null handling for item reports
  bool get hasItemReport => _itemReportModel != null && _itemReportModel!.isNotEmpty;

  bool get hasError => _errorMessage != null;

  GetReportTypeModel? get getReportTypeModel => _getReportTypeModel;

  List<ItemReportModel>? get itemReportModel => _itemReportModel;

  Uint8List? _pdfData;

  Uint8List? get pdfData => _pdfData;

  bool _isCreatingCycle = false;

  bool get isCreatingCycle => _isCreatingCycle;

  // Division Methods
  Future<void> fetchDivision() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _systemRepository.fetchCompanyDivision();
      _division = result ?? [];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

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
    _setLoading(true);
    _clearError();

    try {
      await _systemRepository.createDivision(
        customerid: customerid,
        divisionname: divisionname,
        divisioncode: divisioncode,
        logo: logo,
        address: address,
        telephone: telephone,
        website: website,
        email: email,
        fax: fax,
        culture: culture,
        timezone: timezone,
      );
      await fetchDivision();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

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
    _setLoading(true);
    _clearError();

    try {
      await _systemRepository.updateDivision(
        divisionId: divisionId,
        customerid: customerid,
        divisionname: divisionname,
        divisioncode: divisioncode,
        logo: logo,
        address: address,
        telephone: telephone,
        website: website,
        email: email,
        fax: fax,
        culture: culture,
        timezone: timezone,
      );
      await fetchDivision();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDivision(GetCompanyDivision division) async {
    _setLoading(true);
    _clearError();

    try {
      await _systemRepository.deleteDivision(division);
      _division.removeWhere((div) => div.divisionid == division.divisionid);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDivisionById(String divisionId) async {
    try {
      final division = _division.firstWhere(
        (div) => div.divisionid == divisionId,
        orElse: () => throw Exception('Division not found'),
      );
      return await deleteDivision(division);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Report Methods
  Future<void> fetchReportType() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _systemRepository.fetchReportTypeModel();
      _getReportTypeModel = result;
    } catch (e) {
      _setError(e.toString());
      _getReportTypeModel = null;
    } finally {
      _setLoading(false);
    }
  }

  // Updated: Better error and null handling for report data
  Future<void> fetchReportDataType(String reportTypeId) async {
    _setLoading(true);
    _clearError();
    _itemReportModel = null; // Reset before fetching

    try {
      if (reportTypeId.isEmpty) {
        // If no report type ID, just set empty list
        _itemReportModel = [];
        return;
      }

      final result = await _systemRepository.fetchReportDataTypeModel(reportTypeId);

      // Handle null or empty response
      if (result == null || result.isEmpty) {
        _itemReportModel = [];
      } else {
        _itemReportModel = result;
      }
    } catch (e) {
      // Don't set error for "no data" scenarios
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('not found') ||
          errorMessage.contains('no data') ||
          errorMessage.contains('404')) {
        // Just set empty list, no error
        _itemReportModel = [];
      } else {
        // Real error occurred
        _setError(e.toString());
        _itemReportModel = null;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> createReport({
    required Map<String, dynamic> reportType,
    required List<Map<String, dynamic>> competencyReports,
    required List<Map<String, dynamic>> reportTypeDates,
    required List<Map<String, dynamic>> statusRuleReports,
    required List<Map<String, dynamic>> reportFields,
    required List<Map<String, dynamic>> actionReports,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final requestBody = {
        "reportType": reportType,
        "competencyReports": competencyReports,
        "reportTypeDates": reportTypeDates,
        "statusRuleReports": statusRuleReports,
        "reportFields": reportFields,
        "actionReports": actionReports,
      };

      final result = await _systemRepository.createReport(requestBody);
      await fetchReportType();
      return result;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> updateReport({
    required String reportId,
    required Map<String, dynamic> reportType,
    required List<Map<String, dynamic>> competencyReports,
    required List<Map<String, dynamic>> reportTypeDates,
    required List<Map<String, dynamic>> statusRuleReports,
    required List<Map<String, dynamic>> reportFields,
    required List<Map<String, dynamic>> actionReports,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final requestBody = {
        "reportType": reportType,
        "competencyReports": competencyReports,
        "reportTypeDates": reportTypeDates,
        "statusRuleReports": statusRuleReports,
        "reportFields": reportFields,
        "actionReports": actionReports,
      };

      final result = await _systemRepository.updateReport(reportId, requestBody);
      await fetchReportType();
      return result;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReport(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      await _systemRepository.deleteReport(reportId);
      await fetchReportType();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getReportDetails(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _systemRepository.getReportDetails(reportId);
      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getReportFields(String reportTypeId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _systemRepository.getReportFields(reportTypeId);
      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Uint8List?> fetchPdfReportById(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final pdfBytes = await _systemRepository.fetchPdfReportById(reportId);
      _pdfData = pdfBytes;
      notifyListeners();
      return pdfBytes;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void clearPdfData() {
    _pdfData = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createReportData({
    required String reportTypeId,
    required String itemId,
    required String itemNo,
    required String status,
    required String inspectedBy,
    required String reportDate,
    required String regulation,
    required Map<String, dynamic> reportData,
  }) async {
    try {
      _setLoading(true);

      final requestBody = {
        "reportTypeID": reportTypeId,
        "itemID": itemId,
        "itemNo": itemNo,
        "status": status,
        "inspectedBy": inspectedBy,
        "reportDate": reportDate,
        "regulation": regulation,
        "reportData": reportData,
      };

      final result = await _systemRepository.createReportData(requestBody);

      _setLoading(false);
      return result;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Utility methods
  void clearData() {
    _division = [];
    _getReportTypeModel = null;
    _itemReportModel = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void clearReportData() {
    _getReportTypeModel = null;
    notifyListeners();
  }

  void clearItemReportData() {
    _itemReportModel = null;
    notifyListeners();
  }

  void clearDivisionData() {
    _division = [];
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createCycle({
    required String reportTypeId,
    String? categoryId,
    String? customerId,
    String? siteId,
    required String unit,
    required int duration,
    int? minLength,
    int? maxLength,
  }) async {
    _isCreatingCycle = true;
    notifyListeners();

    try {
      final result = await _systemRepository.createCycle(
        reportTypeId: reportTypeId,
        categoryId: categoryId,
        customerId: customerId,
        siteId: siteId,
        unit: unit,
        duration: duration,
        minLength: minLength,
        maxLength: maxLength,
      );

      _isCreatingCycle = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isCreatingCycle = false;
      notifyListeners();
      rethrow;
    }
  }
}
