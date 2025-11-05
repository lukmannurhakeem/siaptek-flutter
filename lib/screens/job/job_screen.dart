import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SearchColumn { customer, jobNo, site, status }

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Search filters
  SearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobModel(context);
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
      // Trigger rebuild to update filtered jobs
    });
  }

  // Helper method to format date
  String _formatDate(dynamic date) {
    if (date == null) return '-';
    if (date is String) {
      final parsed = date.tryParseDateTime();
      return parsed?.formatShortDate ?? date;
    }
    if (date is DateTime) {
      return date.formatShortDate;
    }
    return '-';
  }

  // Get values based on selected column
  List<dynamic> _getColumnValues(JobProvider jobProvider, SearchColumn column) {
    if (jobProvider.jobModel?.data == null) return [];

    switch (column) {
      case SearchColumn.customer:
        return jobProvider.jobModel!.data!
            .map((e) => e.clientName ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case SearchColumn.jobNo:
        return jobProvider.jobModel!.data!
            .map((e) => e.jobId ?? '')
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case SearchColumn.site:
        return jobProvider.jobModel!.data!
            .map((e) => e.siteName ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case SearchColumn.status:
        return [true, false]; // Started, Not Started
    }
  }

  // Apply filters to job list
  List<dynamic> _getFilteredJobs(JobProvider jobProvider) {
    if (jobProvider.jobModel?.data == null) return [];

    var filteredList = jobProvider.jobModel!.data!;

    // Apply text search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredList =
          filteredList.where((job) {
            final jobNo = (job.jobId ?? '').toLowerCase();
            final customer = (job.clientName ?? '').toLowerCase();
            final site = (job.siteName ?? '').toLowerCase();

            return jobNo.contains(searchText) ||
                customer.contains(searchText) ||
                site.contains(searchText);
          }).toList();
    }

    // Apply column filter
    if (selectedColumn != null && selectedValue != null) {
      switch (selectedColumn!) {
        case SearchColumn.customer:
          filteredList = filteredList.where((job) => job.clientName == selectedValue).toList();
          break;
        case SearchColumn.jobNo:
          filteredList = filteredList.where((job) => job.jobId == selectedValue).toList();
          break;
        case SearchColumn.site:
          filteredList = filteredList.where((job) => job.siteName == selectedValue).toList();
          break;
        case SearchColumn.status:
          filteredList =
              filteredList.where((job) => (job.startJobNow ?? false) == selectedValue).toList();
          break;
      }
    }

    return filteredList;
  }

  String _getColumnLabel(SearchColumn column) {
    switch (column) {
      case SearchColumn.customer:
        return 'Customer';
      case SearchColumn.jobNo:
        return 'Job No';
      case SearchColumn.site:
        return 'Site';
      case SearchColumn.status:
        return 'Status';
    }
  }

  String _getValueLabel(SearchColumn column, dynamic value) {
    if (column == SearchColumn.status) {
      return value == true ? 'Started' : 'Not Started';
    }
    return value.toString();
  }

  void _showFilterDialog(BuildContext context, JobProvider jobProvider) {
    // Temporary variables for dialog
    SearchColumn? tempColumn = selectedColumn;
    dynamic tempValue = selectedValue;

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          final columnValues =
              tempColumn != null ? _getColumnValues(jobProvider, tempColumn!) : <dynamic>[];

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
                      child: CommonDropdown<SearchColumn>(
                        value: tempColumn,
                        items: [
                          DropdownMenuItem<SearchColumn>(
                            value: null,
                            child: Text(
                              'Select Column',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          ...SearchColumn.values.map((column) {
                            return DropdownMenuItem<SearchColumn>(
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

  Widget _buildDataTable(
    BuildContext context,
    JobProvider jobProvider,
    List<dynamic> filteredJobs,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64, // Account for padding
        ),
        child: DataTable(
          sortColumnIndex: jobProvider.sortColumnIndex,
          showCheckboxColumn: false,
          columnSpacing: 20,
          dataRowMinHeight: 56,
          dataRowMaxHeight: 56,
          columns: [
            DataColumn(
              label: Expanded(
                child: Text(
                  'Job No',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  jobProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                flex: 2,
                child: Text(
                  'Customer',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  jobProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                flex: 2,
                child: Text(
                  'Site',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  jobProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                child: Center(
                  child: Text(
                    'Status',
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  jobProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Start Date',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  jobProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'End Date',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
              onSort: (columnIndex, _) {
                setState(() {
                  jobProvider.sortColumnIndex = columnIndex;
                });
              },
            ),
          ],
          rows: List.generate(filteredJobs.length, (index) {
            final data = filteredJobs[index];
            final isEven = index % 2 == 0;

            return DataRow(
              onSelectChanged: (selected) {
                if (selected == true) {
                  NavigationService().navigateTo(
                    AppRoutes.jobRegister,
                    arguments: {'jobId': data.jobId},
                  );
                }
              },
              color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                return isEven ? context.colors.primary.withOpacity(0.05) : null;
              }),
              cells: [
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      data.jobId ?? '-',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      data.clientName ?? '-',
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
                      data.siteName ?? '-',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(data.startJobNow ?? false),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(data.startJobNow ?? false),
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.onPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      _formatDate(data.estimatedStartDate),
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      _formatDate(data.estimatedEndDate),
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
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
    JobProvider jobProvider,
    List<dynamic> filteredJobs,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(filteredJobs.length, (index) {
        final data = filteredJobs[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              NavigationService().navigateTo(
                AppRoutes.jobRegister,
                arguments: {'jobId': data.jobId},
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.jobId ?? '-',
                          style: context.topology.textTheme.titleMedium?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(data.startJobNow ?? false),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(data.startJobNow ?? false),
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customer: ${data.clientName ?? '-'}',
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Site: ${data.siteName ?? '-'}',
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color: context.colors.primary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: context.colors.primary.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_formatDate(data.estimatedStartDate)} - ${_formatDate(data.estimatedEndDate)}',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final hasSearchOrFilter =
        _searchController.text.isNotEmpty || (selectedColumn != null && selectedValue != null);

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Padding(
            padding: context.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Text(
                  hasSearchOrFilter ? 'No jobs found' : 'You have no job created',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasSearchOrFilter ? 'Try adjusting your search or filter' : 'Add your first job',
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
            child: Image.asset(
              'assets/images/bg_2.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
              height: context.screenHeight * 0.70,
            ),
          ),
          // Positioned(
          //   bottom: 16,
          //   right: 16,
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       // Navigate to create job screen
          //       NavigationService().navigateTo(AppRoutes.jobItemCreateScreen, arguments: null);
          //     },
          //     tooltip: 'Add New Job',
          //     backgroundColor: context.colors.primary,
          //     child: const Icon(Icons.add),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final filteredJobs = _getFilteredJobs(jobProvider);

        // Show empty state
        if (jobProvider.jobModel?.data?.isEmpty == true) {
          return _buildEmptyState(context);
        }

        final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
        final screenWidth = context.screenWidth;

        // Show job data
        return SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: context.paddingAll,
                  child: Column(
                    children: [
                      // Search bar
                      CommonTextField(
                        controller: _searchController,
                        hintText: 'Search by job no, customer, or site...',
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
                              onPressed: () => _showFilterDialog(context, jobProvider),
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
                              '${filteredJobs.length} job${filteredJobs.length != 1 ? 's' : ''} found',
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
                      // Job list or table
                      Expanded(
                        child:
                            filteredJobs.isEmpty
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
                                        'No jobs found',
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
                                  onRefresh: () => jobProvider.fetchJobModel(context),
                                  child:
                                      context.isTablet
                                          ? _buildDataTable(context, jobProvider, filteredJobs)
                                          : _buildMobileList(context, jobProvider, filteredJobs),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              // Floating Action Button
              Positioned(
                bottom: 50,
                right: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    // Navigate to create job screen
                    NavigationService().navigateTo(AppRoutes.jobAddNewScreen, arguments: null);
                  },
                  tooltip: 'Add New Job',
                  backgroundColor: context.colors.primary,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(bool status) {
    if (status) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  String _getStatusText(bool status) {
    if (status) {
      return 'Started';
    } else {
      return 'Not Started';
    }
  }
}
