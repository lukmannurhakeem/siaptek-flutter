import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/core/service/service_locator.dart';
import 'package:base_app/model/get_site_model.dart';
import 'package:base_app/repositories/site/site_repository.dart';
import 'package:base_app/widget/common_snackbar.dart';
import 'package:flutter/material.dart';

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

  String? selectedCustomerCode;
  String? selectedCustomerId;

  void setSelectedCustomer(String? customerId) {
    selectedCustomerId = customerId;
    print('$customerId');
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
