import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum PersonnelSearchColumn { name, jobTitle, employeeNumber, status }

class AccessViewScreen extends StatefulWidget {
  const AccessViewScreen({super.key});

  @override
  State<AccessViewScreen> createState() => _AccessViewScreenState();
}

class _AccessViewScreenState extends State<AccessViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  int sortColumnIndex = 0;

  // Search filters
  PersonnelSearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonnelProvider>().fetchPersonnel();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild to update filtered personnel
    });
  }

  // Get values based on selected column
  List<dynamic> _getColumnValues(List<PersonnelData> personnel, PersonnelSearchColumn column) {
    if (personnel.isEmpty) return [];

    switch (column) {
      case PersonnelSearchColumn.name:
        return personnel.map((e) => e.displayName).where((name) => name.isNotEmpty).toSet().toList()
          ..sort();
      case PersonnelSearchColumn.jobTitle:
        return personnel
            .map((e) => e.company.jobTitle)
            .where((title) => title.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case PersonnelSearchColumn.employeeNumber:
        return personnel
            .map((e) => e.company.employeeNumber)
            .where((num) => num.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case PersonnelSearchColumn.status:
        return [true, false]; // Archived, Active
    }
  }

  // Apply filters to personnel list
  List<PersonnelData> _getFilteredPersonnel(List<PersonnelData> personnel) {
    if (personnel.isEmpty) return [];

    var filteredList = personnel;

    // Apply text search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredList =
          filteredList.where((person) {
            final name = person.displayName.toLowerCase();
            final jobTitle = person.company.jobTitle.toLowerCase();
            final employeeNumber = person.company.employeeNumber.toLowerCase();

            return name.contains(searchText) ||
                jobTitle.contains(searchText) ||
                employeeNumber.contains(searchText);
          }).toList();
    }

    // Apply column filter
    if (selectedColumn != null && selectedValue != null) {
      switch (selectedColumn!) {
        case PersonnelSearchColumn.name:
          filteredList = filteredList.where((p) => p.displayName == selectedValue).toList();
          break;
        case PersonnelSearchColumn.jobTitle:
          filteredList = filteredList.where((p) => p.company.jobTitle == selectedValue).toList();
          break;
        case PersonnelSearchColumn.employeeNumber:
          filteredList =
              filteredList.where((p) => p.company.employeeNumber == selectedValue).toList();
          break;
        case PersonnelSearchColumn.status:
          filteredList =
              filteredList.where((p) => p.personnel.isArchived == selectedValue).toList();
          break;
      }
    }

    return filteredList;
  }

  String _getColumnLabel(PersonnelSearchColumn column) {
    switch (column) {
      case PersonnelSearchColumn.name:
        return 'Name';
      case PersonnelSearchColumn.jobTitle:
        return 'Job Title';
      case PersonnelSearchColumn.employeeNumber:
        return 'Employee Number';
      case PersonnelSearchColumn.status:
        return 'Status';
    }
  }

  String _getValueLabel(PersonnelSearchColumn column, dynamic value) {
    if (column == PersonnelSearchColumn.status) {
      return value == true ? 'Archived' : 'Active';
    }
    return value.toString();
  }

  void _showFilterDialog(BuildContext context, List<PersonnelData> personnel) {
    PersonnelSearchColumn? tempColumn = selectedColumn;
    dynamic tempValue = selectedValue;

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          final columnValues =
              tempColumn != null ? _getColumnValues(personnel, tempColumn!) : <dynamic>[];

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
                      child: CommonDropdown<PersonnelSearchColumn>(
                        value: tempColumn,
                        items: [
                          DropdownMenuItem<PersonnelSearchColumn>(
                            value: null,
                            child: Text(
                              'Select Column',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          ...PersonnelSearchColumn.values.map((column) {
                            return DropdownMenuItem<PersonnelSearchColumn>(
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
                            tempValue = null;
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
    return Consumer<PersonnelProvider>(
      builder: (context, personnelProvider, child) {
        // Show loading indicator
        if (personnelProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message
        if (personnelProvider.errorMessage != null) {
          return _buildErrorState(context, personnelProvider);
        }

        final allPersonnel = personnelProvider.activePersonnel;
        final filteredPersonnel = _getFilteredPersonnel(allPersonnel);

        // Show empty state
        if (allPersonnel.isEmpty) {
          return _buildEmptyState(context);
        }

        // Show personnel data
        return context.isTablet
            ? _buildTabletLayout(context, filteredPersonnel, allPersonnel)
            : _buildMobileLayout(context, filteredPersonnel, allPersonnel);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, PersonnelProvider personnelProvider) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/bg_4.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load personnel',
                style: context.topology.textTheme.titleLarge?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  personnelProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => personnelProvider.refreshPersonnel(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/bg_4.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: context.screenHeight - kToolbarHeight * 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              context.vXxl,
              Text(
                _searchController.text.isEmpty
                    ? 'You do not have any personnel right now'
                    : 'No results for "${_searchController.text}"',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              if (_searchController.text.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Add your first personnel member',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          right: 30,
          child: FloatingActionButton(
            onPressed: () {
              NavigationService().navigateTo(AppRoutes.accessScreen, arguments: null);
            },
            tooltip: 'Add New',
            backgroundColor: context.colors.primary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    List<PersonnelData> filteredPersonnel,
    List<PersonnelData> allPersonnel,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/bg_4.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: context.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.accessScreen);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by name, job title, or employee number...',
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
                        onPressed: () => _showFilterDialog(context, allPersonnel),
                      ),
                    ],
                  ),
                ),
                context.vM,
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredPersonnel.length} personnel found',
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
                      filteredPersonnel.isEmpty
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
                                  'No personnel found',
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
                              await Provider.of<PersonnelProvider>(
                                context,
                                listen: false,
                              ).fetchPersonnel();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    padding: const EdgeInsets.all(8),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth - 16,
                                      ),
                                      child: DataTable(
                                        sortColumnIndex: sortColumnIndex,
                                        showCheckboxColumn: false,
                                        columnSpacing: 20,
                                        dataRowMinHeight: 56,
                                        dataRowMaxHeight: 56,
                                        columns: _buildColumns(context),
                                        rows: List.generate(filteredPersonnel.length, (index) {
                                          final data = filteredPersonnel[index];
                                          final isEven = index % 2 == 0;
                                          return _buildRow(context, data, isEven);
                                        }),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<PersonnelData> filteredPersonnel,
    List<PersonnelData> allPersonnel,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/bg_4.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: context.paddingAll,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.accessScreen);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by name, job title, or employee number...',
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
                        onPressed: () => _showFilterDialog(context, allPersonnel),
                      ),
                    ],
                  ),
                ),
                context.vM,
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredPersonnel.length} personnel found',
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
                      filteredPersonnel.isEmpty
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
                                  'No personnel found',
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
                              await Provider.of<PersonnelProvider>(
                                context,
                                listen: false,
                              ).fetchPersonnel();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.all(8),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth - 16,
                                      ),
                                      child: DataTable(
                                        sortColumnIndex: sortColumnIndex,
                                        showCheckboxColumn: false,
                                        columnSpacing: 20,
                                        dataRowMinHeight: 56,
                                        dataRowMaxHeight: 56,
                                        columns: _buildColumns(context),
                                        rows: List.generate(filteredPersonnel.length, (index) {
                                          final data = filteredPersonnel[index];
                                          final isEven = index % 2 == 0;
                                          return _buildRow(context, data, isEven);
                                        }),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
          if (filteredPersonnel.isNotEmpty)
            Positioned(
              bottom: 50,
              right: 30,
              child: FloatingActionButton(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.accessScreen, arguments: null);
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
            'Job Title',
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
            'Employee Number',
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

  DataRow _buildRow(BuildContext context, PersonnelData data, bool isEven) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      onSelectChanged: (_) {
        NavigationService().navigateTo(
          AppRoutes.personnelDetails,
          arguments: {'personnelId': data.personnel.personnelID},
        );
      },
      cells: [
        DataCell(
          Text(
            data.displayName,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.company.jobTitle.isNotEmpty ? data.company.jobTitle : '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.company.employeeNumber.isNotEmpty ? data.company.employeeNumber : '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.personnel.isArchived ? 'Archived' : 'Active',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
