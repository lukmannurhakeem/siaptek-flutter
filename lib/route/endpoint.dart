class Endpoint {
  //auth
  static const String login = '/auth/login';
  static const String verifyToken = '/auth/verify';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  //customer
  static const String customer = '/customer';
  static const String createCustomer = '/customer/create';

  // site
  static const String site = '/site/view';
  static const String createSite = '/site/createSite';

  //system
  static const String companyDivision = '/division/view';
  static const String createDivision = '/division/create';
  static const String reportType = '/report/view';
  static const String createReport = '/report/create';

  //job
  static const String jobView = '/job/view';

  //category
  static const String categoryView = '/category/view';
  static const String categoryCreate = '/category/create';

  //personnel
  static const String personnelView = '/personnel/view';

  static String categoryViewById({String? categoryId}) {
    return categoryId != null ? '/category/$categoryId' : '/category';
  }

  static String getSiteByCustomerId(String customerId) {
    return '/site/customer/$customerId';
  }
}
