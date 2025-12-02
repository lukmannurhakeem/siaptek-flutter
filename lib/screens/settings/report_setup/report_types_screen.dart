import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/screens/job/job_item_details/item_files_screen.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_snackbar.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ReportSearchColumn { name, description, category, documentCode, status }

class ReportTypeScreen extends StatefulWidget {
  const ReportTypeScreen({super.key});

  @override
  State<ReportTypeScreen> createState() => _ReportTypeScreenState();
}

class _ReportTypeScreenState extends State<ReportTypeScreen> with TickerProviderStateMixin {
  List<FileItem> _files = [];
  bool _isUploading = false;
  int sortColumnIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Search filters
  ReportSearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().fetchReportType();
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
      // Trigger rebuild to update filtered reports
    });
  }

  // Get values based on selected column
  List<dynamic> _getColumnValues(List<dynamic> reports, ReportSearchColumn column) {
    if (reports.isEmpty) return [];

    switch (column) {
      case ReportSearchColumn.name:
        return reports
            .map((e) => e.reportType?.reportName ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case ReportSearchColumn.description:
        return reports
            .map((e) => e.reportType?.description ?? '')
            .where((desc) => desc.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case ReportSearchColumn.category:
        return reports
            .map((e) => e.reportType?.categoryId ?? '')
            .where((cat) => cat.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case ReportSearchColumn.documentCode:
        return reports
            .map((e) => e.reportType?.documentCode ?? '')
            .where((code) => code.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case ReportSearchColumn.status:
        return [true, false]; // Archived, Active
    }
  }

  // Apply filters to report list
  List<dynamic> _getFilteredReports(List<dynamic> reports) {
    if (reports.isEmpty) return [];

    var filteredList = reports;

    // Apply text search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredList =
          filteredList.where((report) {
            final name = (report.reportType?.reportName ?? '').toLowerCase();
            final description = (report.reportType?.description ?? '').toLowerCase();
            final category = (report.reportType?.categoryId ?? '').toLowerCase();
            final documentCode = (report.reportType?.documentCode ?? '').toLowerCase();

            return name.contains(searchText) ||
                description.contains(searchText) ||
                category.contains(searchText) ||
                documentCode.contains(searchText);
          }).toList();
    }

    // Apply column filter
    if (selectedColumn != null && selectedValue != null) {
      switch (selectedColumn!) {
        case ReportSearchColumn.name:
          filteredList =
              filteredList
                  .where((report) => report.reportType?.reportName == selectedValue)
                  .toList();
          break;
        case ReportSearchColumn.description:
          filteredList =
              filteredList
                  .where((report) => report.reportType?.description == selectedValue)
                  .toList();
          break;
        case ReportSearchColumn.category:
          filteredList =
              filteredList
                  .where((report) => report.reportType?.categoryId == selectedValue)
                  .toList();
          break;
        case ReportSearchColumn.documentCode:
          filteredList =
              filteredList
                  .where((report) => report.reportType?.documentCode == selectedValue)
                  .toList();
          break;
        case ReportSearchColumn.status:
          filteredList =
              filteredList
                  .where((report) => (report.reportType?.archived ?? false) == selectedValue)
                  .toList();
          break;
      }
    }

    return filteredList;
  }

  String _getColumnLabel(ReportSearchColumn column) {
    switch (column) {
      case ReportSearchColumn.name:
        return 'Report Name';
      case ReportSearchColumn.description:
        return 'Description';
      case ReportSearchColumn.category:
        return 'Category';
      case ReportSearchColumn.documentCode:
        return 'Document Code';
      case ReportSearchColumn.status:
        return 'Status';
    }
  }

  String _getValueLabel(ReportSearchColumn column, dynamic value) {
    if (column == ReportSearchColumn.status) {
      return value == true ? 'Archived' : 'Active';
    }
    return value.toString();
  }

  void _showFilterDialog(BuildContext context, List<dynamic> reports) {
    ReportSearchColumn? tempColumn = selectedColumn;
    dynamic tempValue = selectedValue;

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          final columnValues =
              tempColumn != null ? _getColumnValues(reports, tempColumn!) : <dynamic>[];

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
                      child: CommonDropdown<ReportSearchColumn>(
                        value: tempColumn,
                        items: [
                          DropdownMenuItem<ReportSearchColumn>(
                            value: null,
                            child: Text(
                              'Select Column',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          ...ReportSearchColumn.values.map((column) {
                            return DropdownMenuItem<ReportSearchColumn>(
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
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        // Show snackbars after frame is built
        if (provider.hasData && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CommonSnackbar.showSuccess(context, "Successfully loaded report");
          });
        }

        if (provider.hasError && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CommonSnackbar.showError(context, provider.errorMessage!);
          });
        }

        // Loading state
        if (provider.isLoading && !provider.hasReport) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading report...'),
              ],
            ),
          );
        }

        // Error state
        if (provider.hasError && !provider.hasReport) {
          return _buildErrorState(context, provider);
        }

        final allReports = provider.getReportTypeModel?.data ?? [];
        final filteredReports = _getFilteredReports(allReports);

        // Empty state
        if (allReports.isEmpty) {
          return _buildEmptyState(context);
        }

        return context.isTablet
            ? _buildTabletLayout(context, filteredReports, allReports)
            : _buildMobileLayout(context, filteredReports, allReports);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, SystemProvider provider) {
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
              Text('Failed to load report', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => provider.fetchReportType(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
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
                'You do not have any reports right now',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              Text(
                'Add your first report',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          right: 30,
          child: FloatingActionButton(
            onPressed: () {
              NavigationService().navigateTo(AppRoutes.reportCreate);
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
    List<dynamic> filteredReports,
    List<dynamic> allReports,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          NavigationService().navigateTo(AppRoutes.reportCreate);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create New'),
                        style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickAndUploadFiles,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Import'),
                        style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by name, description, category, or document code...',
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
                        onPressed: () => _showFilterDialog(context, allReports),
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
                        '${filteredReports.length} report${filteredReports.length != 1 ? 's' : ''} found',
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
                      filteredReports.isEmpty
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
                                  'No reports found',
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
                              await Provider.of<SystemProvider>(
                                context,
                                listen: false,
                              ).fetchReportType();
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
                                        columns: _buildDataColumns(context),
                                        rows: List.generate(filteredReports.length, (index) {
                                          final reportItem = filteredReports[index];
                                          final isEven = index % 2 == 0;
                                          return _buildRow(context, reportItem, isEven, index);
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
    List<dynamic> filteredReports,
    List<dynamic> allReports,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          NavigationService().navigateTo(AppRoutes.reportCreate);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create'),
                        style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickAndUploadFiles,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Import'),
                        style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by name, description, category...',
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
                        onPressed: () => _showFilterDialog(context, allReports),
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
                        '${filteredReports.length} report${filteredReports.length != 1 ? 's' : ''} found',
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
                      filteredReports.isEmpty
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
                                  'No reports found',
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
                              await Provider.of<SystemProvider>(
                                context,
                                listen: false,
                              ).fetchReportType();
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
                                        columns: _buildDataColumns(context),
                                        rows: List.generate(filteredReports.length, (index) {
                                          final reportItem = filteredReports[index];
                                          final isEven = index % 2 == 0;
                                          return _buildRow(context, reportItem, isEven, index);
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
          if (filteredReports.isNotEmpty)
            Positioned(
              bottom: 50,
              right: 30,
              child: FloatingActionButton(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.reportCreate);
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

  List<DataColumn> _buildDataColumns(BuildContext context) {
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
            'Description',
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
            'Categories',
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
            'Document Code',
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
            'Revision No',
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
      DataColumn(
        label: Expanded(
          child: Text(
            'Actions',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ),
    ];
  }

  DataRow _buildRow(BuildContext context, dynamic reportItem, bool isEven, int index) {
    final data = reportItem.reportType;

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      onSelectChanged: (selected) {
        if (selected == true) {
          NavigationService().navigateTo(
            AppRoutes.reportTypeDetails,
            arguments: {
              'reportTypeID':
                  data?.reportTypeId ??
                  data?.categoryId ??
                  reportItem.reportType?.reportTypeId ??
                  'default-id',
              'jobID': data?.jobId,
              'reportName': data?.reportName,
            },
          );
        }
      },
      cells: [
        DataCell(
          Text(
            data?.reportName ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data?.description ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data?.categoryId ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data?.documentCode ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data?.competencyId ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data?.archived == true ? 'Archived' : 'Active',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: context.colors.primary, size: 20),
                onPressed: () => _editReport(reportItem, index),
                tooltip: 'Edit Report',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _showDeleteDialog(reportItem, index),
                tooltip: 'Delete Report',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editReport(dynamic reportItem, int index) {
    NavigationService().navigateTo(
      AppRoutes.reportCreate,
      arguments: {
        'isEdit': true,
        'reportData': reportItem.reportType,
        'reportIndex': index,
        'fullReportItem': reportItem,
      },
    );
  }

  void _showDeleteDialog(dynamic reportItem, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Report',
            style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this report?',
                style: context.topology.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Name: ${reportItem.reportType?.reportName ?? 'N/A'}',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Description: ${reportItem.reportType?.description ?? 'N/A'}',
                      style: context.topology.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Document Code: ${reportItem.reportType?.documentCode ?? 'N/A'}',
                      style: context.topology.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: context.colors.primary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReport(reportItem, index);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReport(dynamic reportItem, int index) async {
    try {
      final provider = Provider.of<SystemProvider>(context, listen: false);
      CommonSnackbar.showInfo(context, "Deleting report...");

      final reportId =
          reportItem.reportType.reportTypeId ?? reportItem.reportType?.jobID ?? index.toString();

      await provider.deleteReport(reportId);

      if (mounted) {
        CommonSnackbar.showSuccess(context, "Report deleted successfully");
      }
    } catch (e) {
      if (mounted) {
        CommonSnackbar.showError(context, "Error deleting report: $e");
      }
    }
  }

  Future<void> _pickAndUploadFiles() async {
    try {
      setState(() {
        _isUploading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        for (PlatformFile file in result.files) {
          if (file.path != null) {
            final fileItem = FileItem(
              name: file.name,
              path: file.path!,
              dateAdded: DateTime.now(),
              size: file.size,
            );

            setState(() {
              _files.add(fileItem);
            });
          }
        }

        if (mounted) {
          CommonSnackbar.showSuccess(
            context,
            'Successfully uploaded ${result.files.length} file(s)',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CommonSnackbar.showError(context, 'Error uploading files: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
