import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/providers/category_provider.dart';
import 'package:INSPECT/providers/customer_provider.dart';
import 'package:INSPECT/providers/site_provider.dart';
import 'package:INSPECT/providers/system_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_dropdown.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateCycleScreen extends StatefulWidget {
  const CreateCycleScreen({super.key});

  @override
  State<CreateCycleScreen> createState() => _CreateCycleScreenState();
}

class _CreateCycleScreenState extends State<CreateCycleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _categoryController = TextEditingController();
  final _lengthController = TextEditingController(text: '0');
  final _minLengthController = TextEditingController(text: '0');
  final _maxLengthController = TextEditingController(text: '0');

  // Dropdown values
  String? _selectedReportTypeId; // Store the ID
  String? _selectedReportTypeName; // Optional: store name for display
  String? _selectedUnit;
  String? _selectedCategoryId;

  bool _isLoading = false;

  final List<String> _units = ['Day', 'Week', 'Months', 'Year'];

  @override
  void initState() {
    super.initState();

    // Fetch data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);

      customerProvider.fetchCustomers(context);
      categoryProvider.fetchCategories();
      systemProvider.fetchReportType();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _lengthController.dispose();
    _minLengthController.dispose();
    _maxLengthController.dispose();
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

  Widget _buildLabelWithTooltip(String label, {bool isRequired = false}) {
    return Row(
      children: [
        if (isRequired) const Text('* ', style: TextStyle(color: Colors.red, fontSize: 16)),
        Text(
          label,
          style: context.topology.textTheme.titleSmall?.copyWith(
            color: context.colors.primary,
            fontWeight: isRequired ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.info_outline, size: 16, color: context.colors.primary.withOpacity(0.6)),
      ],
    );
  }

  Widget _buildFormRow(BuildContext context, Widget label, Widget field, {IconData? icon}) {
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
              Expanded(child: Padding(padding: const EdgeInsets.only(top: 12.0), child: label)),
            ],
          ),
        ),
        context.hS,
        Expanded(flex: 3, child: field),
      ],
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return Row(
          children: [
            Expanded(
              child:
                  categoryProvider.isLoading
                      ? Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.primary,
                          ),
                        ),
                      )
                      : CommonTextField(
                        controller: _categoryController,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                        enabled: false,
                      ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _showCategoryDialog();
              },
              icon: Icon(Icons.edit_outlined, color: context.colors.primary),
              style: IconButton.styleFrom(
                backgroundColor: context.colors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  _categoryController.clear();
                  _selectedCategoryId = null;
                });
              },
              icon: const Icon(Icons.close, color: Colors.red),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNumberFieldWithButtons(BuildContext context, TextEditingController controller) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              int currentValue = int.tryParse(controller.text) ?? 0;
              if (currentValue > 0) {
                controller.text = (currentValue - 1).toString();
              }
            });
          },
          icon: const Icon(Icons.remove, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: context.colors.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CommonTextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              int currentValue = int.tryParse(controller.text) ?? 0;
              controller.text = (currentValue + 1).toString();
            });
          },
          icon: const Icon(Icons.add, size: 18),
          style: IconButton.styleFrom(
            backgroundColor: context.colors.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeDropdown(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, systemProvider, child) {
        if (systemProvider.isLoading) {
          return Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
            ),
          );
        }

        if (!systemProvider.hasReport) {
          return CommonDropdown<String>(
            value: null,
            items: const [],
            onChanged: null,
            borderColor: context.colors.primary.withOpacity(0.3),
            textStyle: context.topology.textTheme.bodySmall?.copyWith(
              color: context.colors.primary.withOpacity(0.5),
            ),
          );
        }

        final reportTypes = systemProvider.getReportTypeModel!.data!;

        return CommonDropdown<String>(
          value: _selectedReportTypeId,
          items:
              reportTypes.map((reportType) {
                return DropdownMenuItem<String>(
                  value: reportType.reportType?.reportTypeId, // Use reportTypeId as value
                  child: Text(
                    reportType.reportType?.reportName ?? 'Unknown',
                    style: context.topology.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedReportTypeId = value;
              // Optionally store the name too for display purposes
              _selectedReportTypeName =
                  reportTypes
                      .firstWhere((rt) => rt.reportType?.reportTypeId == value)
                      .reportType
                      ?.reportName;
            });
          },
          borderColor: context.colors.primary,
          textStyle: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
        );
      },
    );
  }

  Widget _buildCustomerSiteField(BuildContext context) {
    return Consumer2<CustomerProvider, SiteProvider>(
      builder: (context, customerProvider, siteProvider, child) {
        bool isFetchingSites =
            siteProvider.selectedCustomerId != null &&
            siteProvider.sitesCustomerList.isEmpty &&
            siteProvider.getSiteByCustomerId == null;

        return Row(
          children: [
            // Customer Dropdown
            Expanded(
              child:
                  customerProvider.isFetching
                      ? Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.primary,
                          ),
                        ),
                      )
                      : CommonDropdown<String>(
                        value: siteProvider.selectedCustomerId,
                        items:
                            customerProvider.customers.map((customer) {
                              return DropdownMenuItem<String>(
                                value: customer.customerid,
                                child: Text(
                                  customer.customername ?? 'Unknown',
                                  style: context.topology.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            siteProvider.setSelectedCustomer(value);
                            siteProvider.fetchSiteByCustomerId(context, value);
                          }
                        },
                        borderColor: context.colors.primary,
                        textStyle: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
            ),
            const SizedBox(width: 12),
            // Site Dropdown
            Expanded(
              child:
                  siteProvider.selectedCustomerId == null
                      ? CommonDropdown<String>(
                        value: null,
                        items: const [],
                        onChanged: null,
                        borderColor: context.colors.primary.withOpacity(0.3),
                        textStyle: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary.withOpacity(0.5),
                        ),
                      )
                      : isFetchingSites
                      ? Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.primary,
                          ),
                        ),
                      )
                      : siteProvider.sitesCustomerList.isEmpty
                      ? CommonDropdown<String>(
                        value: null,
                        items: const [],
                        onChanged: null,
                        borderColor: context.colors.primary.withOpacity(0.3),
                        textStyle: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary.withOpacity(0.5),
                        ),
                      )
                      : CommonDropdown<String>(
                        value: siteProvider.selectedCustomerIdSite,
                        items:
                            siteProvider.sitesCustomerList.map((site) {
                              return DropdownMenuItem<String>(
                                value: site.siteid,
                                child: Text(
                                  site.siteName ?? 'Unknown',
                                  style: context.topology.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            siteProvider.setSelectedCustomerById(value);
                          }
                        },
                        borderColor: context.colors.primary,
                        textStyle: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(
                      'Select Category',
                      style: context.topology.textTheme.titleMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SizedBox(
                      width: 400,
                      height: 400,
                      child:
                          provider.isLoading
                              ? Center(
                                child: CircularProgressIndicator(color: context.colors.primary),
                              )
                              : provider.filteredCategories.isEmpty
                              ? Center(
                                child: Text(
                                  'No categories available',
                                  style: context.topology.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.primary.withOpacity(0.6),
                                  ),
                                ),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: provider.totalItemCount,
                                itemBuilder: (context, index) {
                                  final category = provider.getCategoryByIndex(index);
                                  if (category == null) return const SizedBox.shrink();

                                  return Padding(
                                    padding: EdgeInsets.only(left: category.level * 20.0),
                                    child: ListTile(
                                      leading:
                                          category.children.isNotEmpty
                                              ? IconButton(
                                                icon: Icon(
                                                  category.isExpanded
                                                      ? Icons.expand_more
                                                      : Icons.chevron_right,
                                                  color: context.colors.primary,
                                                ),
                                                onPressed: () {
                                                  provider.toggleExpansion(category);
                                                },
                                              )
                                              : const SizedBox(width: 40),
                                      title: Text(
                                        category.name,
                                        style: context.topology.textTheme.bodyMedium?.copyWith(
                                          fontWeight:
                                              category.level == 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      subtitle:
                                          category.categoryCode != null
                                              ? Text(
                                                'Code: ${category.categoryCode}',
                                                style: context.topology.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: context.colors.primary.withOpacity(
                                                        0.6,
                                                      ),
                                                    ),
                                              )
                                              : null,
                                      onTap: () {
                                        setState(() {
                                          _categoryController.text = category.name;
                                          _selectedCategoryId = category.id;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: context.colors.primary)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final siteProvider = Provider.of<SiteProvider>(context, listen: false);
      final systemProvider = Provider.of<SystemProvider>(context, listen: false);

      // Validate customer selection
      if (siteProvider.selectedCustomerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Please select a customer')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      // Validate report type selection
      if (_selectedReportTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Please select a report type')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      // Validate unit selection
      if (_selectedUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Please select a unit')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final result = await systemProvider.createCycle(
          reportTypeId: _selectedReportTypeId!,
          categoryId: _selectedCategoryId,
          customerId: siteProvider.selectedCustomerId,
          siteId: siteProvider.selectedCustomerIdSite,
          unit: _selectedUnit!,
          duration: int.tryParse(_lengthController.text) ?? 0,
          minLength: int.tryParse(_minLengthController.text),
          maxLength: int.tryParse(_maxLengthController.text),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          final isQueued = result?['queued'] == true;
          final message =
              isQueued
                  ? (result?['message'] ?? 'Cycle saved locally. Will sync when online.')
                  : 'Cycle created successfully!';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(isQueued ? Icons.cloud_upload : Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: isQueued ? Colors.orange : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 3),
            ),
          );

          NavigationService().goBack();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Failed to create cycle: ${e.toString()}')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: context.paddingHorizontal,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            context.vM,
            _buildSectionHeader(context, 'Cycle Information', Icons.refresh_outlined),
            context.vM,
            _buildFormRow(
              context,
              _buildLabelWithTooltip('Report Type', isRequired: true),
              _buildReportTypeDropdown(context),
              icon: Icons.calendar_today,
            ),
            context.vS,
            _buildFormRow(
              context,
              _buildLabelWithTooltip('Category'),
              _buildCategoryField(context),
              icon: Icons.category_outlined,
            ),
            context.vS,
            _buildFormRow(
              context,
              Text(
                'Customer/Site',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              _buildCustomerSiteField(context),
              icon: Icons.business_outlined,
            ),
            context.vL,
            _buildSectionHeader(context, 'Time Period', Icons.schedule_outlined),
            context.vM,
            _buildFormRow(
              context,
              _buildLabelWithTooltip('Unit', isRequired: true),
              CommonDropdown<String>(
                value: _selectedUnit,
                items:
                    _units.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit, style: context.topology.textTheme.bodySmall),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value;
                  });
                },
                borderColor: context.colors.primary,
                textStyle: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              icon: Icons.access_time,
            ),
            context.vS,
            _buildFormRow(
              context,
              _buildLabelWithTooltip('Duration', isRequired: true),
              _buildNumberFieldWithButtons(context, _lengthController),
              icon: Icons.timer_outlined,
            ),
            context.vS,
            _buildFormRow(
              context,
              Text(
                'Min Length',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              _buildNumberFieldWithButtons(context, _minLengthController),
              icon: Icons.arrow_downward,
            ),
            context.vS,
            _buildFormRow(
              context,
              Text(
                'Max Length',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              _buildNumberFieldWithButtons(context, _maxLengthController),
              icon: Icons.arrow_upward,
            ),
            context.vXl,
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    icon: Icons.save,
                    text: _isLoading ? 'Saving...' : 'Save',
                    onPressed: _isLoading ? null : _handleSave,
                  ),
                ),
              ],
            ),
            context.vM,
            Center(
              child: TextButton.icon(
                onPressed: () => NavigationService().goBack(),
                icon: Icon(Icons.arrow_back, color: context.colors.primary),
                label: Text(
                  'Back to List',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            context.vL,
          ],
        ),
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
            Icon(Icons.add_circle_outline, color: context.colors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Create Cycle',
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
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Row(
                        children: [
                          Icon(Icons.info_outline, color: context.colors.primary),
                          const SizedBox(width: 8),
                          const Text('Help'),
                        ],
                      ),
                      content: const Text(
                        'Fill in the required fields to create a new cycle. '
                        'Fields marked with * are mandatory.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
              );
            },
            icon: Icon(Icons.help_outline, color: context.colors.primary),
          ),
        ],
      ),
      body: SafeArea(child: _buildMobileLayout(context)),
    );
  }
}
