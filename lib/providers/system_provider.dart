import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/get_company_division.dart';
import 'package:base_app/model/get_report_type_model.dart';
import 'package:base_app/repositories/system/system_repository.dart';
import 'package:flutter/material.dart';

class SystemProvider extends ChangeNotifier {
  final SystemRepository _systemRepository = ServiceLocator().systemRepository;

  List<GetCompanyDivision> _division = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GetCompanyDivision> get divisions => _division;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasData => _division.isNotEmpty;

  bool get hasReport => _getReportTypeModel?.data != null;

  bool get hasError => _errorMessage != null;

  GetReportTypeModel? _getReportTypeModel;

  GetReportTypeModel? get getReportTypeModel => _getReportTypeModel;

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

      // Optionally refresh the divisions list after successful creation
      await fetchDivision();
    } catch (e) {
      _setError(e.toString());
      rethrow; // Re-throw to let the UI handle the error
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

      // Optionally refresh report types after successful creation
      await fetchReportType();

      return result;
    } catch (e) {
      _setError(e.toString());
      rethrow; // Re-throw to let the UI handle the error
    } finally {
      _setLoading(false);
    }
  }

  // Alternative method with individual parameters for better type safety
  Future<Map<String, dynamic>?> createReportDetailed({
    // Report Type parameters
    required String jobID,
    required String reportName,
    required String description,
    required String documentCode,
    bool isExternalReport = false,
    bool defaultAsDraft = true,
    bool archived = false,
    bool updateItemStatus = true,
    bool updateItemDates = true,
    required String batchReportType,
    bool isStatusRequired = true,
    required String possibleStatus,
    required String permission,
    required String categoryID,
    required String fieldsID,
    required String documentTemplate,
    required String labelTemplate,
    required String actionReportID,
    required String competencyID,

    // Other components
    required List<Map<String, dynamic>> competencyReports,
    required List<Map<String, dynamic>> reportTypeDates,
    required List<Map<String, dynamic>> statusRuleReports,
    required List<Map<String, dynamic>> reportFields,
    required List<Map<String, dynamic>> actionReports,
  }) async {
    final reportType = {
      "jobID": jobID,
      "reportName": reportName,
      "description": description,
      "documentCode": documentCode,
      "isExternalReport": isExternalReport,
      "defaultAsDraft": defaultAsDraft,
      "archived": archived,
      "updateItemStatus": updateItemStatus,
      "updateItemDates": updateItemDates,
      "batchReportType": batchReportType,
      "isStatusRequired": isStatusRequired,
      "possibleStatus": possibleStatus,
      "permission": permission,
      "categoryID": categoryID,
      "fieldsID": fieldsID,
      "documentTemplate": documentTemplate,
      "labelTemplate": labelTemplate,
      "actionReportID": actionReportID,
      "competencyID": competencyID,
    };

    return await createReport(
      reportType: reportType,
      competencyReports: competencyReports,
      reportTypeDates: reportTypeDates,
      statusRuleReports: statusRuleReports,
      reportFields: reportFields,
      actionReports: actionReports,
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String error) {
    _errorMessage = error;
  }

  void clearData() {
    _division = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
