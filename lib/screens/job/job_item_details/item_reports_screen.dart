import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemReportScreen extends StatefulWidget {
  const ItemReportScreen({super.key});

  @override
  State<ItemReportScreen> createState() => _ItemReportScreenState();
}

class _ItemReportScreenState extends State<ItemReportScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch report data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().fetchReportType();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        // Show loading indicator
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message
        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${provider.errorMessage}',
                  style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchReportType(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show empty state
        if (!provider.hasReport) {
          return Center(
            child: Text(
              'No reports available',
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
          );
        }

        final reports = provider.getReportTypeModel!.data!;

        return LayoutBuilder(
          builder: (context, con) {
            return ListView(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: con.maxWidth),
                  child: IntrinsicWidth(
                    stepWidth: double.infinity,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Report No',
                              style: context.topology.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          onSort: (columnIndex, _) {
                            setState(() {});
                          },
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Report Type',
                              style: context.topology.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          onSort: (columnIndex, _) {},
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Date',
                              style: context.topology.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          onSort: (columnIndex, _) {},
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Action',
                              style: context.topology.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: List.generate(reports.length, (index) {
                        final report = reports[index];
                        final isEven = index % 2 == 0;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((
                            Set<MaterialState> states,
                          ) {
                            return isEven ? context.colors.primary.withOpacity(0.05) : null;
                          }),
                          cells: [
                            DataCell(
                              Text(
                                _getReportCode(report),
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _getReportName(report),
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                _getReportDate(report),
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: CommonButton(
                                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                                  onPressed: () {
                                    _handleAction(context, _getReportId(report));
                                  },
                                  text: 'Action',
                                  textStyle: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onPrimary,
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
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        // Show loading indicator
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message
        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${provider.errorMessage}',
                  style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchReportType(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Show empty state
        if (!provider.hasReport) {
          return Center(
            child: Text(
              'No reports available',
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
          );
        }

        final reports = provider.getReportTypeModel!.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report No: ${_getReportCode(report)}',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getReportName(report),
                      style: context.topology.textTheme.bodyMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${_getReportDate(report)}',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CommonButton(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      onPressed: () {
                        _handleAction(context, _getReportId(report));
                      },
                      text: 'Action',
                      textStyle: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper methods to extract data from report object
  String _getReportCode(dynamic report) {
    try {
      return report.reportType?.documentCode ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getReportName(dynamic report) {
    try {
      return report.reportType?.reportName ?? report.reportType?.description ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getReportDate(dynamic report) {
    try {
      DateTime? date = report.reportType?.createdAt;

      if (date != null) {
        return _formatDate(date.toIso8601String());
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getReportId(dynamic report) {
    try {
      return report.reportType?.reportTypeId ?? '';
    } catch (e) {
      return '';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${_getMonthName(date.month)}-${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  void _handleAction(BuildContext context, String reportId) {
    // Implement your action logic here
    // For example, navigate to report details or show options
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Action'),
            content: Text('Action for report: $reportId'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
    );
  }
}
