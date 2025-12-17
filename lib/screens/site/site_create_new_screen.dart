import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/providers/customer_provider.dart';
import 'package:INSPECT/providers/site_provider.dart';
import 'package:INSPECT/providers/system_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_dropdown.dart';
import 'package:INSPECT/widget/common_file_upload_input.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SiteCreateNewScreen extends StatefulWidget {
  const SiteCreateNewScreen({super.key});

  @override
  State<SiteCreateNewScreen> createState() => _SiteCreateNewScreenState();
}

class _SiteCreateNewScreenState extends State<SiteCreateNewScreen> {
  String? selectedDivisionId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);

      customerProvider.fetchCustomers(context);

      if (systemProvider.divisions.isEmpty) {
        systemProvider.fetchDivision();
      }
    });
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
              'This is used for creating Sites belonging to a Customer',
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

  Widget _buildRow(
    BuildContext context,
    String title,
    Widget child, {
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    title + (isRequired ? ' *' : ''),
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
        Expanded(flex: 3, child: child),
      ],
    );
  }

  Widget _buildCustomerDropdown(BuildContext context, {IconData? icon}) {
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'Customer *',
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: Consumer2<CustomerProvider, SiteProvider>(
            builder: (context, customerProvider, siteProvider, _) {
              if (customerProvider.isLoading) {
                return Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final customers = customerProvider.customers;

              return DropdownButtonFormField<String>(
                value: siteProvider.selectedCustomerId,
                decoration: InputDecoration(
                  hintText: 'Select Customer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.primary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  hintStyle: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                items:
                    customers.map((customer) {
                      return DropdownMenuItem<String>(
                        value: customer.customerid,
                        child: Text(
                          customer.customername ?? '-',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  siteProvider.setSelectedCustomer(value);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDivisionDropdown(BuildContext context, {IconData? icon}) {
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'Division',
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: Consumer<SystemProvider>(
            builder: (context, systemProvider, child) {
              if (systemProvider.isLoading) {
                return Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return CommonDropdown<String>(
                value: selectedDivisionId,
                items:
                    systemProvider.divisions.map((division) {
                      return DropdownMenuItem<String>(
                        value: division.divisionid,
                        child: Text(
                          division.divisionname ?? 'Unknown',
                          style: context.topology.textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDivisionId = value;
                    final siteProvider = Provider.of<SiteProvider>(context, listen: false);
                    siteProvider.divisionController.text = value ?? '';
                  });
                },
                borderColor: context.colors.primary,
                textStyle: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, SiteProvider siteProvider) {
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
          _buildRow(
            context,
            'Name',
            CommonTextField(
              hintText: 'Enter Site Name',
              controller: siteProvider.nameController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            isRequired: true,
            icon: Icons.apartment,
          ),
          context.vS,
          _buildRow(
            context,
            'Site Code',
            CommonTextField(
              hintText: 'Enter Site Code',
              controller: siteProvider.siteCodeController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.tag,
          ),
          context.vS,
          _buildCustomerDropdown(context, icon: Icons.business),
          context.vS,
          _buildRow(
            context,
            'Area',
            CommonTextField(
              hintText: 'Enter Area',
              controller: siteProvider.areaController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.map_outlined,
          ),
          context.vS,
          _buildRow(
            context,
            'Status',
            CommonTextField(
              hintText: 'Enter Status',
              controller: siteProvider.statusController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.info_outline,
          ),
          context.vL,
          _buildSectionHeader(context, 'Location & Organization', Icons.location_on_outlined),
          context.vM,
          _buildRow(
            context,
            'Address',
            CommonTextField(
              hintText: 'Enter Address',
              controller: siteProvider.addressController,
              maxLines: 2,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.home_outlined,
          ),
          context.vS,
          _buildDivisionDropdown(context, icon: Icons.business_center),
          context.vL,
          _buildSectionHeader(context, 'Additional Details', Icons.description_outlined),
          context.vM,
          _buildRow(
            context,
            'Description',
            CommonTextField(
              hintText: 'Enter Description',
              controller: siteProvider.descriptionController,
              maxLines: 3,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.description,
          ),
          context.vS,
          _buildRow(
            context,
            'Notes',
            CommonTextField(
              hintText: 'Enter Notes',
              controller: siteProvider.notesController,
              maxLines: 3,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.notes,
          ),
          context.vS,
          _buildRow(context, 'Logo', CommonFileUploadInput(), icon: Icons.image_outlined),
          context.vL,
          CommonButton(
            text: _isLoading ? 'Saving...' : 'Save Site',
            onPressed: _isLoading ? null : () => _saveSite(siteProvider),
          ),
          context.vL,
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, SiteProvider siteProvider) {
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
                        _buildRow(
                          context,
                          'Name',
                          CommonTextField(
                            hintText: 'Enter Site Name',
                            controller: siteProvider.nameController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          isRequired: true,
                          icon: Icons.apartment,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Site Code',
                          CommonTextField(
                            hintText: 'Enter Site Code',
                            controller: siteProvider.siteCodeController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.tag,
                        ),
                        context.vS,
                        _buildCustomerDropdown(context, icon: Icons.business),
                        context.vS,
                        _buildRow(
                          context,
                          'Area',
                          CommonTextField(
                            hintText: 'Enter Area',
                            controller: siteProvider.areaController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.map_outlined,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Status',
                          CommonTextField(
                            hintText: 'Enter Status',
                            controller: siteProvider.statusController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.info_outline,
                        ),
                        context.vL,
                        _buildSectionHeader(
                          context,
                          'Location & Organization',
                          Icons.location_on_outlined,
                        ),
                        context.vM,
                        _buildRow(
                          context,
                          'Address',
                          CommonTextField(
                            hintText: 'Enter Address',
                            controller: siteProvider.addressController,
                            maxLines: 2,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.home_outlined,
                        ),
                        context.vS,
                        _buildDivisionDropdown(context, icon: Icons.business_center),
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
                        _buildSectionHeader(
                          context,
                          'Additional Details',
                          Icons.description_outlined,
                        ),
                        context.vM,
                        _buildRow(
                          context,
                          'Description',
                          CommonTextField(
                            hintText: 'Enter Description',
                            controller: siteProvider.descriptionController,
                            maxLines: 3,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.description,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Notes',
                          CommonTextField(
                            hintText: 'Enter Notes',
                            controller: siteProvider.notesController,
                            maxLines: 3,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.notes,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Logo',
                          CommonFileUploadInput(),
                          icon: Icons.image_outlined,
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
                  text: _isLoading ? 'Saving...' : 'Save Site',
                  onPressed: _isLoading ? null : () => _saveSite(siteProvider),
                ),
              ),
            ],
          ),
          context.vM,
        ],
      ),
    );
  }

  void _saveSite(SiteProvider siteProvider) {
    // Validate required fields
    if (siteProvider.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Please enter site name')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (siteProvider.selectedCustomerId == null || siteProvider.selectedCustomerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Please select a customer')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    siteProvider
        .createSite(context)
        .then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Error: ${error.toString()}')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final siteProvider = Provider.of<SiteProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_location_alt, color: context.colors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Create Site',
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
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: context.colors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Saving site...',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                )
                : (context.isTablet
                    ? _buildTabletLayout(context, siteProvider)
                    : _buildMobileLayout(context, siteProvider)),
      ),
    );
  }
}
