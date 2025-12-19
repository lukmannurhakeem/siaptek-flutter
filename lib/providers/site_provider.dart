import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/core/service/service_locator.dart';
import 'package:INSPECT/model/get_site_model.dart';
import 'package:INSPECT/model/site_customer_by_id_model.dart';
import 'package:INSPECT/repositories/site/site_repository.dart';
import 'package:INSPECT/widget/common_snackbar.dart';
import 'package:flutter/material.dart';

enum SiteStatus { Active, InActive }

extension SiteStatusExtension on SiteStatus {
  String get label {
    switch (this) {
      case SiteStatus.Active:
        return 'Active';
      case SiteStatus.InActive:
        return 'InActive';
    }
  }
}


class SiteProvider extends ChangeNotifier {
  final SiteRepository _siteRepository = ServiceLocator().siteRepository;

  // TextEditingControllers for each field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController siteCodeController = TextEditingController();
  final TextEditingController customerCodeController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController customerIdController = TextEditingController();

  List<Site> _sites = [];

  List<Site> get sites => _sites;

  GetSiteModel? _getSiteModel;

  GetSiteModel? get getSiteModel => _getSiteModel;

  List<SiteCustomer> _sitesCustomerList = [];

  List<SiteCustomer> get sitesCustomerList => _sitesCustomerList;

  GetSiteByCustomerIdModel? _getSiteByCustomerIdModel;

  GetSiteByCustomerIdModel? get getSiteByCustomerId => _getSiteByCustomerIdModel;

  String? selectedCustomerId;

  String? selectedCustomerIdSite = '';

  void setSelectedCustomer(String? customerId) {
    selectedCustomerId = customerId;
    // Clear site selection when customer changes
    selectedCustomerIdSite = null;
    // Clear sites list when customer changes
    _sitesCustomerList = [];
    notifyListeners();
  }

  void setSelectedCustomerById(String? siteId) {
    selectedCustomerIdSite = siteId;
    print('Selected site ID: $siteId');
    notifyListeners();
  }

  Future<void> fetchSite(BuildContext context) async {
    try {
      _getSiteModel = await _siteRepository.fetchSite();
      _sites = _getSiteModel?.sites ?? [];
      notifyListeners();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    }
  }

  Future<void> fetchSiteByCustomerId(BuildContext context, customerId) async {
    try {
      // Clear previous sites first
      _sitesCustomerList = [];
      notifyListeners();

      final model = await _siteRepository.fetchSiteByCustomerId(customerId: customerId);
      print('Site customer length : ${model.siteCustomers?.length}');

      _getSiteByCustomerIdModel = model;
      _sitesCustomerList = model.siteCustomers ?? [];

      // If there's only one site, auto-select it
      if (_sitesCustomerList.length == 1) {
        selectedCustomerIdSite = _sitesCustomerList.first.siteid;
      }

      notifyListeners();
    } catch (e) {
      _sitesCustomerList = [];
      notifyListeners();
      CommonSnackbar.showError(context, e.toString());
    }
  }

  Future<void> createSite(BuildContext context) async {
    try {
      await _siteRepository.createSite(
        status: statusController.text,
        siteCode: siteCodeController.text,
        division: divisionController.text,
        customerId: selectedCustomerId.toString() ?? '',
        customerCode: customerCodeController.text,
        address: addressController.text,
        siteName: nameController.text,
      );
      fetchSite(context);
      NavigationService().goBack();
      CommonSnackbar.showSuccess(context, "Site created successfully");
      notifyListeners();
    } catch (e) {
      CommonSnackbar.showError(context, e.toString());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    siteCodeController.dispose();
    customerCodeController.dispose();
    areaController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    divisionController.dispose();
    addressController.dispose();
    statusController.dispose();
    customerIdController.dispose();
    super.dispose();
  }
}
