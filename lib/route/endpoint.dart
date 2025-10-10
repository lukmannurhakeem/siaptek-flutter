class Endpoint {
  //auth
  static const String login = '/auth/login';
  static const String verifyToken = '/auth/verify';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String userRegister = '/auth/register';

  //customer
  static const String customer = '/customer';
  static const String createCustomer = '/customer/create';

  // site
  static const String site = '/site/view';
  static const String createSite = '/site/createSite';

  //system
  static const String companyDivision = '/division/view';
  static const String createDivision = '/division/create';
  static const String updateDivision = '/division/update';
  static const String reportType = '/report/view';
  static const String deleteReportType = '/report/delete';
  static const String createReport = '/report/create';

  static String getReportField(String reportTypeId) {
    return '/reportData/fields/$reportTypeId';
  }

  static String fetchPdfReportById(String reportTypeId) {
    return '/reportData/$reportTypeId/view-pdf';
  }

  static String getItemReport(String reportTypeId) {
    return '/reportData/itemreport/$reportTypeId';
  }

  static const String createReportData = '/reportData/create';

  //job
  static const String jobView = '/job/view';
  static const String jobRegister = '/jobitems/view';
  static const String jobItemCreate = '/jobitems/create';
  static const String personnelMembersView = '/personnelmembers/team';
  static const String personnelMembersAdd = '/personnelmembers/add-member';
  static const String personnelMembersDelete = '/personnelmembers';
  static const String personnelMembersUpdate = '/personnelmembers';
  static const String jobCreate = '/job/create';

  //category
  static const String categoryView = '/category/view';
  static const String categoryCreate = '/category/create';

  //personnel
  static const String personnelView = '/personnel/view';
  static const String personnelCreate = '/personnel/create';
  static const String personnelTeamView = '/teampersonnel/view';
  static const String personnelTeamCreate = '/teampersonnel/create';

  static String categoryViewById({String? categoryId}) {
    return categoryId != null ? '/category/$categoryId' : '/category';
  }

  static String getSiteByCustomerId(String customerId) {
    return '/site/customer/$customerId';
  }

  static const String deleteDivision = '/division/delete';
}
