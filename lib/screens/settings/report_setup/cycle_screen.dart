import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/cycle_model.dart';
import 'package:INSPECT/providers/cycle_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_dialog.dart';
import 'package:INSPECT/widget/common_dropdown.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum CycleSearchColumn { cycleLength, categoryName, customerSite, dataType }

class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Search filters
  CycleSearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CycleProvider>().fetchCycles(context);
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
      // Trigger rebuild to update filtered cycles
    });
  }

  // Get values based on selected column
  List<dynamic> _getColumnValues(CycleProvider cycleProvider, CycleSearchColumn column) {
    if (cycleProvider.cycleModel?.data == null) return [];

    switch (column) {
      case CycleSearchColumn.cycleLength:
        return cycleProvider.cycleModel!.data!
            .map((e) => e.cycleLength ?? '')
            .where((length) => length.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case CycleSearchColumn.categoryName:
        return cycleProvider.cycleModel!.data!
            .map((e) => e.categoryName ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case CycleSearchColumn.customerSite:
        return cycleProvider.cycleModel!.data!
            .map((e) => e.customerSite ?? '')
            .where((site) => site.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case CycleSearchColumn.dataType:
        return cycleProvider.cycleModel!.data!
            .map((e) => e.dataType ?? '')
            .where((type) => type.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    }
  }

  // Apply filters to cycle list
  List<CycleData> _getFilteredCycles(CycleProvider cycleProvider) {
    if (cycleProvider.cycleModel?.data == null) return [];

    var filteredList = cycleProvider.cycleModel!.data!;

    // Apply text search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredList =
          filteredList.where((cycle) {
            final cycleLength = (cycle.cycleLength ?? '').toLowerCase();
            final categoryName = (cycle.categoryName ?? '').toLowerCase();
            final customerSite = (cycle.customerSite ?? '').toLowerCase();
            final dataType = (cycle.dataType ?? '').toLowerCase();

            return cycleLength.contains(searchText) ||
                categoryName.contains(searchText) ||
                customerSite.contains(searchText) ||
                dataType.contains(searchText);
          }).toList();
    }

    // Apply column filter
    if (selectedColumn != null && selectedValue != null) {
      switch (selectedColumn!) {
        case CycleSearchColumn.cycleLength:
          filteredList = filteredList.where((cycle) => cycle.cycleLength == selectedValue).toList();
          break;
        case CycleSearchColumn.categoryName:
          filteredList =
              filteredList.where((cycle) => cycle.categoryName == selectedValue).toList();
          break;
        case CycleSearchColumn.customerSite:
          filteredList =
              filteredList.where((cycle) => cycle.customerSite == selectedValue).toList();
          break;
        case CycleSearchColumn.dataType:
          filteredList = filteredList.where((cycle) => cycle.dataType == selectedValue).toList();
          break;
      }
    }

    return filteredList;
  }

  String _getColumnLabel(CycleSearchColumn column) {
    switch (column) {
      case CycleSearchColumn.cycleLength:
        return 'Cycle Length';
      case CycleSearchColumn.categoryName:
        return 'Category Name';
      case CycleSearchColumn.customerSite:
        return 'Customer/Site';
      case CycleSearchColumn.dataType:
        return 'Data Type';
    }
  }

  void _showFilterDialog(BuildContext context, CycleProvider cycleProvider) {
    // Temporary variables for dialog
    CycleSearchColumn? tempColumn = selectedColumn;
    dynamic tempValue = selectedValue;

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          final columnValues =
              tempColumn != null ? _getColumnValues(cycleProvider, tempColumn!) : <dynamic>[];

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
                      child: CommonDropdown<CycleSearchColumn>(
                        value: tempColumn,
                        items: [
                          DropdownMenuItem<CycleSearchColumn>(
                            value: null,
                            child: Text(
                              'Select Column',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          ...CycleSearchColumn.values.map((column) {
                            return DropdownMenuItem<CycleSearchColumn>(
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
                                        value.toString(),
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

  Widget _buildDataTable(
    BuildContext context,
    CycleProvider cycleProvider,
    List<CycleData> filteredCycles,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
        child: DataTable(
          sortColumnIndex: cycleProvider.sortColumnIndex,
          showCheckboxColumn: false,
          columnSpacing: 20,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 56,
          columns: [
            DataColumn(
              label: Expanded(
                child: Text(
                  'Cycle Length',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  cycleProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                flex: 2,
                child: Text(
                  'Category Name',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  cycleProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                flex: 2,
                child: Text(
                  'Customer/Site',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  cycleProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Data Type',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  cycleProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                child: Center(
                  child: Text(
                    'Actions',
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
          rows: List.generate(filteredCycles.length, (index) {
            final data = filteredCycles.elementAt(index);
            final isEven = index % 2 == 0;

            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                return isEven ? context.colors.primary.withOpacity(0.05) : null;
              }),
              cells: [
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.minLength} ${data.unit}',

                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      data.categoryName ?? '-',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      data.customerSite ?? '-',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      data.dataType ?? '-',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: context.colors.primary, size: 20),
                          onPressed: () {
                            // NavigationService().navigateTo(
                            //   AppRoutes.cycleEdit,
                            //   arguments: {'cycleId': data.cycleId},
                            // );
                          },
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () {
                            _showDeleteDialog(context, data.cycleId);
                          },
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    CycleProvider cycleProvider,
    List<dynamic> filteredCycles,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(filteredCycles.length, (index) {
        final data = filteredCycles[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.length != null && data.unit != null
                                ? '${data.length} ${data.unit}'
                                : '-',
                            style: context.topology.textTheme.titleMedium?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (data.minLength != null || data.maxLength != null)
                            const SizedBox(height: 4),
                          if (data.minLength != null || data.maxLength != null)
                            Text(
                              data.minLength != null && data.maxLength != null
                                  ? 'Range: ${data.minLength} - ${data.maxLength}'
                                  : data.minLength != null
                                  ? 'Min: ${data.minLength}'
                                  : 'Max: ${data.maxLength}',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: context.colors.primary, size: 20),
                          onPressed: () {
                            NavigationService().navigateTo(
                              AppRoutes.createCycle,
                              arguments: {'cycleId': data.cycleId},
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () {
                            _showDeleteDialog(context, data.cycleId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: ${data.categoryName ?? '-'}',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer/Site: ${data.customerSite ?? '-'}',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Data Type: ${data.dataType ?? '-'}',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final hasSearchOrFilter =
        _searchController.text.isNotEmpty || (selectedColumn != null && selectedValue != null);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white, // Add white background
      child: Stack(
        children: [
          Padding(
            padding: context.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Text(
                  hasSearchOrFilter ? 'No cycles found' : 'You have no cycle created',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasSearchOrFilter
                      ? 'Try adjusting your search or filter'
                      : 'Add your first cycle',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -200,
            right: 0,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/bg_2.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                height: context.screenHeight * 0.70,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String? cycleId) {
    CommonDialog.show(
      context,
      widget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete Cycle',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to delete this cycle?',
            textAlign: TextAlign.center,
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: 'Cancel',
                  onPressed: () {
                    NavigationService().goBack();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonButton(
                  text: 'Delete',
                  onPressed: () {
                    context.read<CycleProvider>().deleteCycle(context, cycleId);
                    NavigationService().goBack();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        final filteredCycles = _getFilteredCycles(cycleProvider);

        // Show empty state
        if (cycleProvider.cycleModel?.data?.isEmpty == true) {
          return _buildEmptyState(context);
        }

        final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
        final screenWidth = context.screenWidth;

        // Show cycle data
        return Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.white, // Add white background
          child: Padding(
            padding: context.paddingAll,
            child: Column(
              children: [
                // Create New button (like SiteScreen)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createCycle);
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
                  hintText: 'Search by cycle length, category, customer/site, or data type...',
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
                        onPressed: () => _showFilterDialog(context, cycleProvider),
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
                        '${filteredCycles.length} cycle${filteredCycles.length != 1 ? 's' : ''} found',
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
                                  'Filter: ${_getColumnLabel(selectedColumn!)}: $selectedValue',
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
                // Cycle list or table
                Expanded(
                  child:
                      filteredCycles.isEmpty
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
                                  'No cycles found',
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
                            onRefresh: () => cycleProvider.fetchCycles(context),
                            child:
                                context.isTablet
                                    ? _buildDataTable(context, cycleProvider, filteredCycles)
                                    : _buildMobileList(context, cycleProvider, filteredCycles),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
