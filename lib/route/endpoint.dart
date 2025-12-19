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

  static const String createCycle = '/cycles/create';
  static const String getCycle = '/cycles/details';

  static String getInspectionRegister(String jobId) {
    return '/reportData/inspectionregister/$jobId';
  }

  static String getApprovalReport(String jobId, String status) {
    return '/reportData/approval/$jobId/$status';
  }

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

  static String jobRegister({String? jobId}) {
    return jobId != null ? '/jobitems/$jobId' : '/jobitems';
  }

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

  //Agent
  static const String agent = '/agent';
  static const String createAgent = '/agent/create';

  static String categoryViewById({String? categoryId}) {
    return categoryId != null ? '/category/$categoryId' : '/category';
  }

  static String getSiteByCustomerId(String customerId) {
    return '/site/customer/$customerId';
  }

  static const String deleteDivision = '/division/delete';

  // Inspection Plans
  static const String inspectionPlansView = '/inspectionplans/view';
  static const String inspectionPlansCreate = '/inspectionplans/create';
  static const String inspectionPlansUpdate = '/inspectionplans/update';
  static const String inspectionPlansDelete = '/inspectionplans/delete';

  static String getInspectionPlanById(String planId) {
    return '/inspectionplans/$planId';
  }

  static String getInspectionPlansByJob(String jobId) {
    return '/inspectionplans/job/$jobId';
  }

  static String getInspectionPlansByAssignee(String assigneeId) {
    return '/inspectionplans/assignee/$assigneeId';
  }

  static String updateReportApproval(String jobId) {
    return '/jobitems/update/$jobId';
  }

  static String getReportApprovalDataFalse(String jobId) {
    return '/reportData/approval/$jobId/false';
  }

  static String getReportApprovalDataTrue(String jobId) {
    return '/reportData/approval/$jobId/true';
  }

  ///// Dashboard

  static String getDashboardCustomer(String customerId) {
    return '/custdashboard/$customerId/dashboard';
  }

  static String getDashboardSite(String customerId) {
    return '/custdashboard/$customerId/sites';
  }

  static String getDashboardStatistic(String customerId) {
    return '/custdashboard/$customerId/statistics';
  }

  static String getDashboardReports(String customerId) {
    return '/custdashboard/$customerId/reports';
  }

  static String getDashboardItems(String customerId) {
    return '/custdashboard/$customerId/items';
  }

  static String getDashboardJobs(String customerId) {
    return '/custdashboard/$customerId/jobs';
  }
}
