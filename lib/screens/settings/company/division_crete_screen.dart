import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompanyCreateDivision extends StatefulWidget {
  final String? id;

  const CompanyCreateDivision({this.id, super.key});

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
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

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);

      try {
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
      } catch (e) {
        _showErrorSnackBar('Failed to create division: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Division',
          style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: context.isTablet ? _tabletView(context) : _mobileView(context),
      ),
    );
  }

  Widget _tabletView(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, systemProvider, child) {
        return Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.spacing.l),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This is used for creating Division',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
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
                  ),
                  context.vS,
                  _buildFormRow(
                    context,
                    'Logo',
                    CommonTextField(
                      controller: _logoController,
                      hintText: 'Enter Logo URL',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  context.vS,
                  _buildFormRow(
                    context,
                    'Address',
                    CommonTextField(
                      controller: _addressController,
                      hintText: 'Enter Address',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  context.vS,
                  _buildFormRow(
                    context,
                    'Telephone',
                    CommonTextField(
                      controller: _telephoneController,
                      hintText: 'Enter Phone Numbers',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  context.vS,
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
                  ),
                  context.vS,
                  _buildFormRow(
                    context,
                    'Culture',
                    CommonTextField(
                      controller: _cultureController,
                      hintText: 'Enter Culture',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  context.vS,
                  _buildFormRow(
                    context,
                    'Timezone',
                    CommonTextField(
                      controller: _timezoneController,
                      hintText: 'Enter Time Zone',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  context.vL,
                  CommonButton(
                    text: systemProvider.isLoading ? 'Saving...' : 'Save',
                    onPressed: systemProvider.isLoading ? null : _handleSave,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mobileView(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, systemProvider, child) {
        return Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(context.spacing.m),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This is used for creating Division',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  context.vM,
                  _buildMobileFormField(
                    context,
                    'Division Name',
                    _divisionNameController,
                    'Enter Division Name',
                    true,
                  ),
                  context.vS,
                  _buildMobileFormField(
                    context,
                    'Division Code',
                    _divisionCodeController,
                    'Enter Division Code',
                    true,
                  ),
                  context.vS,
                  _buildMobileFormField(context, 'Logo', _logoController, 'Enter Logo URL'),
                  context.vS,
                  _buildMobileFormField(context, 'Address', _addressController, 'Enter Address'),
                  context.vS,
                  _buildMobileFormField(
                    context,
                    'Telephone',
                    _telephoneController,
                    'Enter Phone Numbers',
                  ),
                  context.vS,
                  _buildMobileFormField(
                    context,
                    'Website',
                    _websiteController,
                    'Enter Website URL',
                  ),
                  context.vS,
                  _buildMobileFormField(
                    context,
                    'Email Address',
                    _emailController,
                    'Enter Email Address',
                    false,
                    true,
                  ),
                  context.vS,
                  _buildMobileFormField(context, 'Fax', _faxController, 'Enter Fax Number'),
                  context.vS,
                  _buildMobileFormField(context, 'Culture', _cultureController, 'Enter Culture'),
                  context.vS,
                  _buildMobileFormField(
                    context,
                    'Timezone',
                    _timezoneController,
                    'Enter Time Zone',
                  ),
                  context.vL,
                  CommonButton(
                    text: systemProvider.isLoading ? 'Saving...' : 'Save',
                    onPressed: systemProvider.isLoading ? null : _handleSave,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormRow(BuildContext context, String label, Widget textField) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(flex: 3, child: textField),
      ],
    );
  }

  Widget _buildMobileFormField(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hintText, [
    bool isRequired = false,
    bool isEmail = false,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
        SizedBox(height: 8),
        CommonTextField(
          controller: controller,
          hintText: hintText,
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }
            if (isEmail && value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Enter a valid email address';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
