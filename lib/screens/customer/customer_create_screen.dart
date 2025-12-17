import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/providers/customer_provider.dart';
import 'package:INSPECT/providers/personnel_provider.dart';
import 'package:INSPECT/providers/system_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_dropdown.dart';
import 'package:INSPECT/widget/common_file_upload_input.dart';
import 'package:INSPECT/widget/common_textfield.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personnelProvider = Provider.of<PersonnelProvider>(context, listen: false);
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);

      if (personnelProvider.personnelList.isEmpty) {
        personnelProvider.fetchPersonnel();
      }

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

  Widget _buildAgentDropdown(BuildContext context, {IconData? icon}) {
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
                    'Agent',
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
                    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
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
    );
  }

  Widget _buildMobileLayout(BuildContext context, CustomerProvider customerProvider) {
    return SingleChildScrollView(
      padding: context.paddingHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          context.vM,
          _buildSectionHeader(context, 'Basic Information', Icons.business_outlined),
          context.vM,
          _buildRow(
            context,
            'Customer Name',
            CommonTextField(
              hintText: 'Enter Customer Name',
              controller: customerProvider.customerNameController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            isRequired: true,
            icon: Icons.person_outline,
          ),
          context.vS,
          _buildRow(
            context,
            'Account Code',
            CommonTextField(
              hintText: 'Enter Account Code',
              controller: customerProvider.customerCodeController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.tag,
          ),
          context.vS,
          _buildRow(
            context,
            'Status',
            CommonTextField(
              hintText: 'Enter Status',
              controller: customerProvider.statusController,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.info_outline,
          ),
          context.vL,
          _buildSectionHeader(context, 'Assignment & Organization', Icons.group_outlined),
          context.vM,
          _buildAgentDropdown(context, icon: Icons.person),
          context.vS,
          _buildDivisionDropdown(context, icon: Icons.business),
          context.vL,
          _buildSectionHeader(context, 'Additional Details', Icons.description_outlined),
          context.vM,
          _buildRow(
            context,
            'Notes',
            CommonTextField(
              hintText: 'Enter Notes',
              controller: notesController,
              maxLines: 3,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.notes,
          ),
          context.vS,
          _buildRow(
            context,
            'Address',
            CommonTextField(
              hintText: 'Enter Address',
              controller: customerProvider.addressController,
              maxLines: 2,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
            icon: Icons.location_on_outlined,
          ),
          context.vS,
          _buildRow(context, 'Logo', CommonFileUploadInput(), icon: Icons.image_outlined),
          context.vL,
          CommonButton(
            text: _isLoading ? 'Saving...' : 'Save Customer',
            onPressed: _isLoading ? null : () => _saveCustomer(customerProvider),
          ),
          context.vL,
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, CustomerProvider customerProvider) {
    return Padding(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
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
                          'Customer Name',
                          CommonTextField(
                            hintText: 'Enter Customer Name',
                            controller: customerProvider.customerNameController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          isRequired: true,
                          icon: Icons.person_outline,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Account Code',
                          CommonTextField(
                            hintText: 'Enter Account Code',
                            controller: customerProvider.customerCodeController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.tag,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Status',
                          CommonTextField(
                            hintText: 'Enter Status',
                            controller: customerProvider.statusController,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.info_outline,
                        ),
                        context.vL,
                        _buildSectionHeader(
                          context,
                          'Assignment & Organization',
                          Icons.group_outlined,
                        ),
                        context.vM,
                        _buildAgentDropdown(context, icon: Icons.person),
                        context.vS,
                        _buildDivisionDropdown(context, icon: Icons.business),
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
                          'Notes',
                          CommonTextField(
                            hintText: 'Enter Notes',
                            controller: notesController,
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
                          'Address',
                          CommonTextField(
                            hintText: 'Enter Address',
                            controller: customerProvider.addressController,
                            maxLines: 2,
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                          icon: Icons.location_on_outlined,
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
                  text: _isLoading ? 'Saving...' : 'Save Customer',
                  onPressed: _isLoading ? null : () => _saveCustomer(customerProvider),
                ),
              ),
            ],
          ),
          context.vM,
        ],
      ),
    );
  }

  void _saveCustomer(CustomerProvider customerProvider) {
    // Validate required fields
    if (customerProvider.customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Please enter customer name')),
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

    customerProvider
        .createCustomer(context)
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
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, color: context.colors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Create Customer',
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
                        'Saving customer...',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                )
                : (context.isTablet
                    ? _buildTabletLayout(context, customerProvider)
                    : _buildMobileLayout(context, customerProvider)),
      ),
    );
  }
}
