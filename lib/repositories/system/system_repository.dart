import 'package:base_app/model/get_company_division.dart';
import 'package:base_app/model/get_report_type_model.dart';

abstract class SystemRepository {
  Future<List<GetCompanyDivision>> fetchCompanyDivision();

  Future<GetReportTypeModel> fetchReportTypeModel();

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

  Future<Map<String, dynamic>?> createReport(Map<String, dynamic> requestBody);
}
