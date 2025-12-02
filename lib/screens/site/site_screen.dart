import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/site_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/get_site_model.dart';

enum SiteSearchColumn { name, code, division, status }

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  int sortColumnIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Search filters
  SiteSearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SiteProvider>(context, listen: false).fetchSite(context);
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
      // Trigger rebuild to update filtered sites
    });
  }

  // Get values based on selected column
  List<dynamic> _getColumnValues(List<Site> sites, SiteSearchColumn column) {
    if (sites.isEmpty) return [];

    switch (column) {
      case SiteSearchColumn.name:
        return sites.map((e) => e.siteName ?? '').where((name) => name.isNotEmpty).toSet().toList()
          ..sort();
      case SiteSearchColumn.code:
        return sites.map((e) => e.siteCode ?? '').where((code) => code.isNotEmpty).toSet().toList()
          ..sort();
      case SiteSearchColumn.division:
        return sites.map((e) => e.division ?? '').where((div) => div.isNotEmpty).toSet().toList()
          ..sort();
      case SiteSearchColumn.status:
        return [true, false]; // Archived, Active
    }
  }

  // Apply filters to site list
  List<Site> _getFilteredSites(List<Site> sites) {
    if (sites.isEmpty) return [];

    var filteredList = sites;

    // Apply text search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredList =
          filteredList.where((site) {
            final name = (site.siteName ?? '').toLowerCase();
            final code = (site.siteCode ?? '').toLowerCase();
            final division = (site.division ?? '').toLowerCase();

            return name.contains(searchText) ||
                code.contains(searchText) ||
                division.contains(searchText);
          }).toList();
    }

    // Apply column filter
    if (selectedColumn != null && selectedValue != null) {
      switch (selectedColumn!) {
        case SiteSearchColumn.name:
          filteredList = filteredList.where((site) => site.siteName == selectedValue).toList();
          break;
        case SiteSearchColumn.code:
          filteredList = filteredList.where((site) => site.siteCode == selectedValue).toList();
          break;
        case SiteSearchColumn.division:
          filteredList = filteredList.where((site) => site.division == selectedValue).toList();
          break;
        case SiteSearchColumn.status:
          filteredList =
              filteredList.where((site) => (site.archived ?? false) == selectedValue).toList();
          break;
      }
    }

    return filteredList;
  }

  String _getColumnLabel(SiteSearchColumn column) {
    switch (column) {
      case SiteSearchColumn.name:
        return 'Site Name';
      case SiteSearchColumn.code:
        return 'Site Code';
      case SiteSearchColumn.division:
        return 'Division';
      case SiteSearchColumn.status:
        return 'Status';
    }
  }

  String _getValueLabel(SiteSearchColumn column, dynamic value) {
    if (column == SiteSearchColumn.status) {
      return value == true ? 'Archived' : 'Active';
    }
    return value.toString();
  }

  void _showFilterDialog(BuildContext context, List<Site> sites) {
    // Temporary variables for dialog
    SiteSearchColumn? tempColumn = selectedColumn;
    dynamic tempValue = selectedValue;

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          final columnValues =
              tempColumn != null ? _getColumnValues(sites, tempColumn!) : <dynamic>[];

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
                      child: CommonDropdown<SiteSearchColumn>(
                        value: tempColumn,
                        items: [
                          DropdownMenuItem<SiteSearchColumn>(
                            value: null,
                            child: Text(
                              'Select Column',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          ...SiteSearchColumn.values.map((column) {
                            return DropdownMenuItem<SiteSearchColumn>(
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
    return Consumer<SiteProvider>(
      builder: (context, provider, child) {
        final sites = provider.sites;
        final filteredSites = _getFilteredSites(sites);

        if (sites.isEmpty) {
          return _buildEmptyState(context);
        }

        return context.isTablet
            ? _buildTabletLayout(context, filteredSites, sites)
            : _buildMobileLayout(context, filteredSites, sites);
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
                'Add your first site',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
        // Floating action button
        Positioned(
          bottom: 50,
          right: 30,
          child: FloatingActionButton(
            onPressed: () {
              NavigationService().navigateTo(AppRoutes.createSite);
            },
            tooltip: 'Add New',
            backgroundColor: context.colors.primary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, List<Site> filteredSites, List<Site> allSites) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          // Background image (fixed at bottom right)
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
          // Foreground scrollable content
          Padding(
            padding: context.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed "Create" button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createSite);
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
                  hintText: 'Search by site name, code, or division...',
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
                        onPressed: () => _showFilterDialog(context, allSites),
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
                        '${filteredSites.length} site${filteredSites.length != 1 ? 's' : ''} found',
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
                // Scrollable table
                Expanded(
                  child:
                      filteredSites.isEmpty
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
                                  'No sites found',
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
                              await Provider.of<SiteProvider>(
                                context,
                                listen: false,
                              ).fetchSite(context);
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
                                        rows: List.generate(filteredSites.length, (index) {
                                          final data = filteredSites[index];
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

  Widget _buildMobileLayout(BuildContext context, List<Site> filteredSites, List<Site> allSites) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          // Background image (fixed at bottom right)
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
          // Foreground scrollable content
          Padding(
            padding: context.paddingAll,
            child: Column(
              children: [
                // Create Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createSite);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by site name, code, or division...',
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
                        onPressed: () => _showFilterDialog(context, allSites),
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
                        '${filteredSites.length} site${filteredSites.length != 1 ? 's' : ''} found',
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
                      filteredSites.isEmpty
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
                                  'No sites found',
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
                              await Provider.of<SiteProvider>(
                                context,
                                listen: false,
                              ).fetchSite(context);
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
                                        rows: List.generate(filteredSites.length, (index) {
                                          final data = filteredSites[index];
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
          // Floating action button
          if (filteredSites.isNotEmpty)
            Positioned(
              bottom: 50,
              right: 30,
              child: FloatingActionButton(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.createSite);
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
            'Site Name',
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
            'Site Code',
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

  DataRow _buildRow(BuildContext context, Site data, bool isEven) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      cells: [
        DataCell(
          Text(
            data.siteName ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.siteCode ?? '',
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
