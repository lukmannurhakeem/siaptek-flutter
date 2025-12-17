import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/get_customer_model.dart';
import 'package:INSPECT/providers/customer_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_dialog.dart';
import 'package:INSPECT/widget/common_dropdown.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum CustomerSearchColumn { name, code, division, status }

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int sortColumnIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Search filters
  CustomerSearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    // Fetch data once the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers(context);
    });

    // Listen to search text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild to update filtered customers
    });
  }

  // Get values based on selected column
  List<dynamic> _getColumnValues(List<Customer> customers, CustomerSearchColumn column) {
    if (customers.isEmpty) return [];

    switch (column) {
      case CustomerSearchColumn.name:
        return customers
            .map((e) => e.customername ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case CustomerSearchColumn.code:
        return customers
            .map((e) => e.accountCode ?? '')
            .where((code) => code.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case CustomerSearchColumn.division:
        return customers
            .map((e) => e.division ?? '')
            .where((div) => div.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case CustomerSearchColumn.status:
        return [true, false]; // Archived, Active
    }
  }

  // Apply filters to customer list
  List<Customer> _getFilteredCustomers(List<Customer> customers) {
    if (customers.isEmpty) return [];

    var filteredList = customers;

    // Apply text search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredList =
          filteredList.where((customer) {
            final name = (customer.customername ?? '').toLowerCase();
            final code = (customer.accountCode ?? '').toLowerCase();
            final division = (customer.division ?? '').toLowerCase();

            return name.contains(searchText) ||
                code.contains(searchText) ||
                division.contains(searchText);
          }).toList();
    }

    // Apply column filter
    if (selectedColumn != null && selectedValue != null) {
      switch (selectedColumn!) {
        case CustomerSearchColumn.name:
          filteredList =
              filteredList.where((customer) => customer.customername == selectedValue).toList();
          break;
        case CustomerSearchColumn.code:
          filteredList =
              filteredList.where((customer) => customer.accountCode == selectedValue).toList();
          break;
        case CustomerSearchColumn.division:
          filteredList =
              filteredList.where((customer) => customer.division == selectedValue).toList();
          break;
        case CustomerSearchColumn.status:
          filteredList =
              filteredList
                  .where((customer) => (customer.archived ?? false) == selectedValue)
                  .toList();
          break;
      }
    }

    return filteredList;
  }

  String _getColumnLabel(CustomerSearchColumn column) {
    switch (column) {
      case CustomerSearchColumn.name:
        return 'Name';
      case CustomerSearchColumn.code:
        return 'Customer Code';
      case CustomerSearchColumn.division:
        return 'Division';
      case CustomerSearchColumn.status:
        return 'Status';
    }
  }

  String _getValueLabel(CustomerSearchColumn column, dynamic value) {
    if (column == CustomerSearchColumn.status) {
      return value == true ? 'Archived' : 'Active';
    }
    return value.toString();
  }

  void _showFilterDialog(BuildContext context, List<Customer> customers) {
    // Temporary variables for dialog
    CustomerSearchColumn? tempColumn = selectedColumn;
    dynamic tempValue = selectedValue;

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          final columnValues =
              tempColumn != null ? _getColumnValues(customers, tempColumn!) : <dynamic>[];

          return SizedBox(
            height: context.screenHeight / 3.5,
            child: Column(
              children: [
                // Column Type Dropdown
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Filter By',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CommonDropdown<CustomerSearchColumn>(
                        value: tempColumn,
                        items: [
                          DropdownMenuItem<CustomerSearchColumn>(
                            value: null,
                            child: Text(
                              'Select Column',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          ...CustomerSearchColumn.values.map((column) {
                            return DropdownMenuItem<CustomerSearchColumn>(
                              value: column,
                              child: Text(
                                _getColumnLabel(column),
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            tempColumn = value;
                            tempValue = null; // Reset value when column changes
                          });
                        },
                      ),
                    ),
                  ],
                ),
                context.vS,
                // Value Dropdown
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Value',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child:
                          tempColumn == null
                              ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.colors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'Select a column first',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary.withOpacity(0.5),
                                  ),
                                ),
                              )
                              : CommonDropdown<dynamic>(
                                value: tempValue,
                                items: [
                                  DropdownMenuItem<dynamic>(
                                    value: null,
                                    child: Text(
                                      'All',
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  ...columnValues.map((value) {
                                    return DropdownMenuItem<dynamic>(
                                      value: value,
                                      child: Text(
                                        _getValueLabel(tempColumn!, value),
                                        style: context.topology.textTheme.bodySmall?.copyWith(
                                          color: context.colors.primary,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setDialogState(() {
                                    tempValue = value;
                                  });
                                },
                              ),
                    ),
                  ],
                ),
                context.vL,
                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: 'Clear',
                        onPressed: () {
                          setState(() {
                            selectedColumn = null;
                            selectedValue = null;
                          });
                          NavigationService().goBack();
                        },
                      ),
                    ),
                    context.hS,
                    Expanded(
                      child: CommonButton(
                        text: 'Apply',
                        onPressed: () {
                          setState(() {
                            selectedColumn = tempColumn;
                            selectedValue = tempValue;
                          });
                          NavigationService().goBack();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, child) {
        final customers = provider.customers;
        final filteredCustomers = _getFilteredCustomers(customers);

        if (customers.isEmpty) {
          return _buildEmptyState(context);
        }

        return context.isTablet
            ? _buildTabletLayout(context, filteredCustomers, customers)
            : _buildMobileLayout(context, filteredCustomers, customers);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      children: [
        // Background image (fixed at bottom right)
        Positioned(
          bottom: 0,
          right: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/bg_2.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
        // Empty state content
        SizedBox(
          width: double.infinity,
          height: context.screenHeight - kToolbarHeight * 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              context.vXxl,
              Text(
                'You do not have list right now',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              Text(
                'Add your first customer',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.vL,
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.createCustomer);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    List<Customer> filteredCustomers,
    List<Customer> allCustomers,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: context.screenHeight - (kToolbarHeight * 1.25),
          child: Padding(
            padding: context.paddingHorizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Create Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createCustomer);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by name, code, or division...',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: context.colors.primary),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color:
                              (selectedColumn != null && selectedValue != null)
                                  ? context.colors.primary
                                  : context.colors.primary.withOpacity(0.5),
                        ),
                        onPressed: () => _showFilterDialog(context, allCustomers),
                      ),
                    ],
                  ),
                ),
                context.vM,
                // Result count and active filter indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredCustomers.length} customer${filteredCustomers.length != 1 ? 's' : ''} found',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      if (selectedColumn != null && selectedValue != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColumn = null;
                              selectedValue = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Filter: ${_getColumnLabel(selectedColumn!)}: ${_getValueLabel(selectedColumn!, selectedValue)}',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.close, size: 14, color: context.colors.primary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      filteredCustomers.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: context.colors.primary.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No customers found',
                                  style: context.topology.textTheme.titleMedium?.copyWith(
                                    color: context.colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or filter',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh: () async {
                              await Provider.of<CustomerProvider>(
                                context,
                                listen: false,
                              ).fetchCustomers(context);
                            },
                            child: ListView(
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: IntrinsicWidth(
                                    stepWidth: double.infinity,
                                    child: DataTable(
                                      sortColumnIndex: sortColumnIndex,
                                      showCheckboxColumn: false,
                                      columnSpacing: 20,
                                      dataRowMinHeight: 56,
                                      dataRowMaxHeight: 56,
                                      columns: _buildColumns(context),
                                      rows: List.generate(filteredCustomers.length, (index) {
                                        final data = filteredCustomers[index];
                                        final isEven = index % 2 == 0;
                                        return _buildRow(context, data, isEven);
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<Customer> filteredCustomers,
    List<Customer> allCustomers,
  ) {
    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - (kToolbarHeight * 1.25),
      child: Stack(
        children: [
          Padding(
            padding: context.paddingHorizontal,
            child: Column(
              children: [
                // Create Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createCustomer);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by name, code, or division...',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: context.colors.primary),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color:
                              (selectedColumn != null && selectedValue != null)
                                  ? context.colors.primary
                                  : context.colors.primary.withOpacity(0.5),
                        ),
                        onPressed: () => _showFilterDialog(context, allCustomers),
                      ),
                    ],
                  ),
                ),
                context.vM,
                // Result count and active filter indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredCustomers.length} customer${filteredCustomers.length != 1 ? 's' : ''} found',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      if (selectedColumn != null && selectedValue != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColumn = null;
                              selectedValue = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Filter: ${_getColumnLabel(selectedColumn!)}: ${_getValueLabel(selectedColumn!, selectedValue)}',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.close, size: 14, color: context.colors.primary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      filteredCustomers.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: context.colors.primary.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No customers found',
                                  style: context.topology.textTheme.titleMedium?.copyWith(
                                    color: context.colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or filter',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh:
                                () => Provider.of<CustomerProvider>(
                                  context,
                                  listen: false,
                                ).fetchCustomers(context),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                sortColumnIndex: sortColumnIndex,
                                showCheckboxColumn: false,
                                columnSpacing: 20,
                                dataRowMinHeight: 56,
                                dataRowMaxHeight: 56,
                                columns: _buildColumns(context),
                                rows: List.generate(filteredCustomers.length, (index) {
                                  final data = filteredCustomers[index];
                                  final isEven = index % 2 == 0;
                                  return _buildRow(context, data, isEven);
                                }),
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
          // Floating Action Button (optional - you already have a create button)
          if (filteredCustomers.isNotEmpty)
            Positioned(
              bottom: 50,
              right: 30,
              child: FloatingActionButton(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.createCustomer);
                },
                tooltip: 'Add New',
                backgroundColor: context.colors.primary,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context) {
    return [
      DataColumn(
        label: Expanded(
          child: Text(
            'Name',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Customer Code',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Division',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Status',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
    ];
  }

  DataRow _buildRow(BuildContext context, Customer data, bool isEven) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      cells: [
        DataCell(
          Text(
            data.customername ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.accountCode ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.division ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.archived == true ? 'Archived' : 'Active',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
