import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/get_company_division.dart';
import 'package:INSPECT/providers/system_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanyCreateDivision extends StatefulWidget {
  final String? id;
  final GetCompanyDivision? division;

  const CompanyCreateDivision({this.id, this.division, super.key});

  @override
  State<CompanyCreateDivision> createState() => _CompanyCreateDivision();
}

class _CompanyCreateDivision extends State<CompanyCreateDivision> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  final _divisionNameController = TextEditingController();
  final _divisionCodeController = TextEditingController();
  final _logoController = TextEditingController();
  final _addressController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _faxController = TextEditingController();
  final _cultureController = TextEditingController();
  final _timezoneController = TextEditingController();

  bool get isEditMode => widget.division != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (isEditMode && widget.division != null) {
      _divisionNameController.text = widget.division!.divisionname ?? '';
      _divisionCodeController.text = widget.division!.divisioncode ?? '';
      _logoController.text = widget.division!.logo ?? '';
      _addressController.text = widget.division!.address ?? '';
      _telephoneController.text = widget.division!.telephone ?? '';
      _websiteController.text = widget.division!.website ?? '';
      _emailController.text = widget.division!.email ?? '';
      _faxController.text = widget.division!.fax ?? '';
      _cultureController.text = widget.division!.culture ?? '';
      _timezoneController.text = widget.division!.timezone ?? '';
    }
  }

  @override
  void dispose() {
    _divisionNameController.dispose();
    _divisionCodeController.dispose();
    _logoController.dispose();
    _addressController.dispose();
    _telephoneController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _faxController.dispose();
    _cultureController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: context.colors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: context.colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditMode
                  ? 'Update the division information below'
                  : 'Create a new division for your organization',
              style: context.topology.textTheme.bodySmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(
    BuildContext context,
    String label,
    Widget textField, {
    bool isRequired = false,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              if (isRequired) const Text('* ', style: TextStyle(color: Colors.red, fontSize: 16)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    label,
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: isRequired ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(flex: 3, child: textField),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);

      try {
        if (isEditMode) {
          await systemProvider.updateDivision(
            divisionId: widget.division!.divisionid!,
            customerid: widget.id ?? widget.division!.customerid,
            divisionname: _divisionNameController.text.trim(),
            divisioncode: _divisionCodeController.text.trim(),
            logo: _logoController.text.trim().isEmpty ? null : _logoController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            telephone:
                _telephoneController.text.trim().isEmpty ? null : _telephoneController.text.trim(),
            website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            fax: _faxController.text.trim().isEmpty ? null : _faxController.text.trim(),
            culture: _cultureController.text.trim().isEmpty ? null : _cultureController.text.trim(),
            timezone:
                _timezoneController.text.trim().isEmpty ? null : _timezoneController.text.trim(),
          );

          if (systemProvider.hasError) {
            _showErrorSnackBar(systemProvider.errorMessage!);
          } else {
            _showSuccessSnackBar('Division updated successfully');
            NavigationService().goBack();
          }
        } else {
          await systemProvider.createDivision(
            customerid: widget.id,
            divisionname: _divisionNameController.text.trim(),
            divisioncode: _divisionCodeController.text.trim(),
            logo: _logoController.text.trim().isEmpty ? null : _logoController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            telephone:
                _telephoneController.text.trim().isEmpty ? null : _telephoneController.text.trim(),
            website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            fax: _faxController.text.trim().isEmpty ? null : _faxController.text.trim(),
            culture: _cultureController.text.trim().isEmpty ? null : _cultureController.text.trim(),
            timezone:
                _timezoneController.text.trim().isEmpty ? null : _timezoneController.text.trim(),
          );

          if (systemProvider.hasError) {
            _showErrorSnackBar(systemProvider.errorMessage!);
          } else {
            _showSuccessSnackBar('Division created successfully');
            NavigationService().goBack();
          }
        }
      } catch (e) {
        _showErrorSnackBar('Failed to ${isEditMode ? 'update' : 'create'} division: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, SystemProvider systemProvider) {
    return Padding(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          context.vM,
          _buildInfoBanner(context),
          context.vM,
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Basic Information', Icons.business_outlined),
                        context.vM,
                        _buildFormRow(
                          context,
                          'Division Name',
                          CommonTextField(
                            controller: _divisionNameController,
                            hintText: 'Enter Division Name',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Division name is required';
                              }
                              return null;
                            },
                          ),
                          isRequired: true,
                          icon: Icons.corporate_fare,
                        ),
                        context.vS,
                        _buildFormRow(
                          context,
                          'Division Code',
                          CommonTextField(
                            controller: _divisionCodeController,
                            hintText: 'Enter Division Code',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Division code is required';
                              }
                              return null;
                            },
                          ),
                          isRequired: true,
                          icon: Icons.tag,
                        ),
                        context.vS,
                        _buildFormRow(
                          context,
                          'Logo URL',
                          CommonTextField(
                            controller: _logoController,
                            hintText: 'Enter Logo URL',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.image_outlined,
                        ),
                        context.vL,
                        _buildSectionHeader(
                          context,
                          'Contact Information',
                          Icons.contact_mail_outlined,
                        ),
                        context.vM,
                        _buildFormRow(
                          context,
                          'Address',
                          CommonTextField(
                            controller: _addressController,
                            hintText: 'Enter Address',
                            maxLines: 2,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.location_on_outlined,
                        ),
                        context.vS,
                        _buildFormRow(
                          context,
                          'Telephone',
                          CommonTextField(
                            controller: _telephoneController,
                            hintText: 'Enter Phone Number',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.phone_outlined,
                        ),
                        context.vS,
                        _buildFormRow(
                          context,
                          'Email Address',
                          CommonTextField(
                            controller: _emailController,
                            hintText: 'Enter Email Address',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                              }
                              return null;
                            },
                          ),
                          icon: Icons.email_outlined,
                        ),
                        context.vS,
                      ],
                    ),
                  ),
                ),
                context.hXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Additional Details', Icons.more_horiz),
                        context.vM,
                        _buildFormRow(
                          context,
                          'Website',
                          CommonTextField(
                            controller: _websiteController,
                            hintText: 'Enter Website URL',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.language_outlined,
                        ),
                        context.vS,
                        _buildFormRow(
                          context,
                          'Fax',
                          CommonTextField(
                            controller: _faxController,
                            hintText: 'Enter Fax Number',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.print_outlined,
                        ),
                        context.vS,
                        _buildFormRow(
                          context,
                          'Culture',
                          CommonTextField(
                            controller: _cultureController,
                            hintText: 'Enter Culture (e.g., en-US)',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.translate_outlined,
                        ),
                        context.vS,
                        _buildFormRow(
                          context,
                          'Timezone',
                          CommonTextField(
                            controller: _timezoneController,
                            hintText: 'Enter Timezone',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.access_time_outlined,
                        ),
                        context.vS,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          context.vL,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: CommonButton(
                  icon: isEditMode ? Icons.update : Icons.save,
                  text:
                      systemProvider.isLoading
                          ? (isEditMode ? 'Updating...' : 'Saving...')
                          : (isEditMode ? 'Update' : 'Save'),
                  onPressed: systemProvider.isLoading ? null : _handleSave,
                ),
              ),
            ],
          ),
          context.vM,
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, SystemProvider systemProvider) {
    return SingleChildScrollView(
      padding: context.paddingHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          context.vM,
          _buildInfoBanner(context),
          context.vL,
          _buildSectionHeader(context, 'Basic Information', Icons.business_outlined),
          context.vM,
          _buildFormRow(
            context,
            'Division Name',
            CommonTextField(
              controller: _divisionNameController,
              hintText: 'Enter Division Name',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Division name is required';
                }
                return null;
              },
            ),
            isRequired: true,
            icon: Icons.corporate_fare,
          ),
          context.vS,
          _buildFormRow(
            context,
            'Division Code',
            CommonTextField(
              controller: _divisionCodeController,
              hintText: 'Enter Division Code',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Division code is required';
                }
                return null;
              },
            ),
            isRequired: true,
            icon: Icons.tag,
          ),
          context.vS,
          _buildFormRow(
            context,
            'Logo URL',
            CommonTextField(
              controller: _logoController,
              hintText: 'Enter Logo URL',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.image_outlined,
          ),
          context.vL,
          _buildSectionHeader(context, 'Contact Information', Icons.contact_mail_outlined),
          context.vM,
          _buildFormRow(
            context,
            'Address',
            CommonTextField(
              controller: _addressController,
              hintText: 'Enter Address',
              maxLines: 2,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.location_on_outlined,
          ),
          context.vS,
          _buildFormRow(
            context,
            'Telephone',
            CommonTextField(
              controller: _telephoneController,
              hintText: 'Enter Phone Number',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.phone_outlined,
          ),
          context.vS,
          _buildFormRow(
            context,
            'Email Address',
            CommonTextField(
              controller: _emailController,
              hintText: 'Enter Email Address',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                }
                return null;
              },
            ),
            icon: Icons.email_outlined,
          ),
          context.vL,
          _buildSectionHeader(context, 'Additional Details', Icons.more_horiz),
          context.vM,
          _buildFormRow(
            context,
            'Website',
            CommonTextField(
              controller: _websiteController,
              hintText: 'Enter Website URL',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.language_outlined,
          ),
          context.vS,
          _buildFormRow(
            context,
            'Fax',
            CommonTextField(
              controller: _faxController,
              hintText: 'Enter Fax Number',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.print_outlined,
          ),
          context.vS,
          _buildFormRow(
            context,
            'Culture',
            CommonTextField(
              controller: _cultureController,
              hintText: 'Enter Culture (e.g., en-US)',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.translate_outlined,
          ),
          context.vS,
          _buildFormRow(
            context,
            'Timezone',
            CommonTextField(
              controller: _timezoneController,
              hintText: 'Enter Timezone',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.access_time_outlined,
          ),
          context.vL,
          CommonButton(
            icon: isEditMode ? Icons.update : Icons.save,
            text:
                systemProvider.isLoading
                    ? (isEditMode ? 'Updating...' : 'Saving...')
                    : (isEditMode ? 'Update' : 'Save'),
            onPressed: systemProvider.isLoading ? null : _handleSave,
          ),
          context.vL,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEditMode ? Icons.edit : Icons.add_business,
              color: context.colors.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isEditMode ? 'Edit Division' : 'Create Division',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: Consumer<SystemProvider>(
          builder: (context, systemProvider, child) {
            return Form(
              key: _formKey,
              child:
                  context.isTablet
                      ? _buildTabletLayout(context, systemProvider)
                      : _buildMobileLayout(context, systemProvider),
            );
          },
        ),
      ),
    );
  }
}
