import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SearchColumn { customer, jobNo, site, status }

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  // Search filters
  SearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobModel(context);
    });
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

  void _showSearchDialog(BuildContext context, JobProvider jobProvider) {
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
                        'Search By',
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
                        text: 'Search',
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
    return Container(
      padding: context.paddingHorizontal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: IntrinsicWidth(
                  stepWidth: double.infinity,
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
                    rows: List.generate(jobProvider.jobModel!.data!.length, (index) {
                      final data = jobProvider.jobModel!.data!.elementAt(index);
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
                        color: MaterialStateProperty.resolveWith<Color?>((
                          Set<MaterialState> states,
                        ) {
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
                                data.estimatedStartDate!.formatFullDate ?? '-',
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
                                data.estimatedEndDate!.formatFullDate ?? '-',
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    JobProvider jobProvider,
    List<dynamic> filteredJobs,
  ) {
    return ListView.builder(
      padding: context.paddingHorizontal,
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
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
                      Text(
                        data.jobId ?? '-',
                        style: context.topology.textTheme.titleMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
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
                      Text(
                        '${data.estimatedStartDate ?? '-'} - ${data.estimatedEndDate ?? '-'}',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        if (jobProvider.jobModel?.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredJobs = _getFilteredJobs(jobProvider);

        return Scaffold(
          body: SizedBox(
            width: context.screenWidth,
            height: context.screenHeight - (kToolbarHeight * 1.25),
            child: Stack(
              children: [
                // Main content - adapt based on screen size
                context.isTablet
                    ? _buildDataTable(context, jobProvider, filteredJobs)
                    : _buildMobileList(context, jobProvider, filteredJobs),

                // Floating Action Button
                Positioned(
                  bottom: 50,
                  right: 30,
                  child: FloatingActionButton(
                    onPressed: () => _showSearchDialog(context, jobProvider),
                    tooltip: 'Search',
                    backgroundColor: context.colors.primary,
                    child: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
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
