import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/customer_provider.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_file_upload_input.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerCreateNewScreen extends StatefulWidget {
  const CustomerCreateNewScreen({super.key});

  @override
  State<CustomerCreateNewScreen> createState() => _CustomerCreateNewScreenState();
}

class _CustomerCreateNewScreenState extends State<CustomerCreateNewScreen> {
  String? selectedAgentId;
  String? selectedDivisionId;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController agentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personnelProvider = Provider.of<PersonnelProvider>(context, listen: false);
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);

      // Fetch personnel list if not already loaded
      if (personnelProvider.personnelList.isEmpty) {
        personnelProvider.fetchPersonnel();
      }

      // Fetch divisions if not already loaded
      if (systemProvider.divisions.isEmpty) {
        systemProvider.fetchDivision();
      }
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    agentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Customer',
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Customer Name',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Customer Name',
                        controller: customerProvider.customerNameController,
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
                        'Account Code',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: CommonTextField(
                        hintText: 'Enter Account Code',
                        controller: customerProvider.customerCodeController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                // Agent Dropdown
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Agent',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Consumer<PersonnelProvider>(
                        builder: (context, personnelProvider, child) {
                          if (personnelProvider.isLoading) {
                            return Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          return CommonDropdown<String>(
                            value: selectedAgentId,
                            items:
                                personnelProvider.personnelList.map((personnelData) {
                                  return DropdownMenuItem<String>(
                                    value: personnelData.personnel.personnelID,
                                    child: Text(
                                      personnelData.displayName,
                                      style: context.topology.textTheme.bodySmall,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedAgentId = value;
                                // Store the agent ID in a controller for submission
                                agentController.text = value ?? '';
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
                        controller: notesController,
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
                                customerProvider.divisionController.text = value ?? '';
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
                        controller: customerProvider.statusController,
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
                        controller: customerProvider.addressController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vL,
                CommonButton(
                  text: 'Save',
                  onPressed: () {
                    // The dropdown values are already stored in the controllers
                    // divisionController.text has the division ID
                    // agentController.text has the agent ID (though not used in current API)
                    customerProvider.createCustomer(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
