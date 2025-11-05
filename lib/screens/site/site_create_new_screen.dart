import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/customer_provider.dart';
import 'package:base_app/providers/site_provider.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_file_upload_input.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SiteCreateNewScreen extends StatefulWidget {
  const SiteCreateNewScreen({super.key});

  @override
  State<SiteCreateNewScreen> createState() => _SiteCreateNewScreenState();
}

class _SiteCreateNewScreenState extends State<SiteCreateNewScreen> {
  String? selectedDivisionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);

      // Fetch customers
      customerProvider.fetchCustomers(context);

      // Fetch divisions
      if (systemProvider.divisions.isEmpty) {
        systemProvider.fetchDivision();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final siteProvider = Provider.of<SiteProvider>(context, listen: false);
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Site',
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.l),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is used for creating Sites belonging to a Customer',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vM,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Name',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Name',
                        controller: siteProvider.nameController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Site Code',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Site Code',
                        controller: siteProvider.siteCodeController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Customer',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Consumer2<CustomerProvider, SiteProvider>(
                        builder: (context, customerProvider, siteProvider, _) {
                          final customers = customerProvider.customers;

                          return DropdownButtonFormField<String>(
                            value: siteProvider.selectedCustomerId,
                            decoration: InputDecoration(
                              hintText: 'Select Customer',
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              hintStyle: context.topology.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
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
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Area',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        controller: siteProvider.areaController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Description',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Description',
                        controller: siteProvider.descriptionController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Notes',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Notes',
                        controller: siteProvider.notesController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                // Division Dropdown
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Division',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
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
                                // Store the division ID in the controller for submission
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
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Address',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Address',
                        controller: siteProvider.addressController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Status',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Status',
                        controller: siteProvider.statusController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Logo',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(flex: 3, child: CommonFileUploadInput()),
                  ],
                ),
                context.vL,
                CommonButton(
                  text: 'Save',
                  onPressed: () {
                    siteProvider.createSite(context);
                  },
                ),
                context.vL,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
