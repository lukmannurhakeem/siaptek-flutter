import 'dart:typed_data';

import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/get_company_division.dart';
import 'package:base_app/model/get_report_type_model.dart';
import 'package:base_app/model/item_report_model.dart';
import 'package:base_app/repositories/system/system_repository.dart';
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

  bool get hasItemReport => _itemReportModel != null;

  bool get hasError => _errorMessage != null;

  GetReportTypeModel? get getReportTypeModel => _getReportTypeModel;

  List<ItemReportModel>? get itemReportModel => _itemReportModel;
  Uint8List? _pdfData;

  Uint8List? get pdfData => _pdfData;

  // Division Methods
  Future<void> fetchDivision() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _systemRepository.fetchCompanyDivision();
      _division = result;
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
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchReportDataType(String reportTypeId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _systemRepository.fetchReportDataTypeModel(reportTypeId);
      _itemReportModel = result;
    } catch (e) {
      _setError(e.toString());
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

  // Add this method to your SystemProvider class

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

  void clearDivisionData() {
    _division = [];
    notifyListeners();
  }
}
