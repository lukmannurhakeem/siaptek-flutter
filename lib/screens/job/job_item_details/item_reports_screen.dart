import 'dart:html' as html;

import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/screens/job/job_item_details/pdf_viewer_screen.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemReportScreen extends StatefulWidget {
  final Item item;

  const ItemReportScreen({super.key, required this.item});

  @override
  State<ItemReportScreen> createState() => _ItemReportScreenState();
}

class _ItemReportScreenState extends State<ItemReportScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemProvider>().fetchReportDataType(widget.item.itemId ?? '');
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
        if (!provider.hasItemReport) {
          return Center(
            child: Text(
              'No reports available',
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, con) {
            return ListView(
              children: [
                context.vM,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.itemReportModel?.length ?? 0} report found',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showCreateDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create'),
                      style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                    ),
                  ],
                ),
                context.vM,
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
                      rows: List.generate(provider.itemReportModel?.length ?? 0, (index) {
                        final report = provider.itemReportModel?.elementAt(index);
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
                                report?.reportId ?? '-',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                report?.reportName ?? '-',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                report?.createdAt?.formatFullDate ?? '-',
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
                                    _printPdf(context, report?.reportId ?? '');
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
      return 'N/A';
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
    // Get the report data to pass the report name
    final provider = context.read<SystemProvider>();
    final reports = provider.getReportTypeModel?.data ?? [];

    final report = reports.firstWhere(
      (r) => r.reportType?.reportTypeId == reportId,
      orElse: () => reports.first,
    );

    final reportName = report.reportType?.reportName ?? 'Report Details';

    // Navigate to ReportFieldsScreen using NavigationService
    NavigationService().navigateTo(
      AppRoutes.reportFieldsScreen,
      arguments: {'reportTypeId': reportId, 'reportName': reportName, 'item': widget.item},
    );
  }

  void _showCreateDialog(BuildContext context, [String? reportId]) {
    final provider = context.read<SystemProvider>();
    final reports = provider.getReportTypeModel?.data ?? [];

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Report Type',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: context.colors.primary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 1),

              // 🔹 Scrollable list of report names
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(reports.length, (index) {
                    final report = reports[index];
                    final isEven = index.isEven;

                    return GestureDetector(
                      onTap: () => _handleAction(context, report.reportType?.reportTypeId ?? ''),
                      child: Container(
                        color:
                            isEven ? context.colors.primary.withOpacity(0.05) : Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.reportType?.reportName ?? '',
                                style: context.topology.textTheme.bodyMedium?.copyWith(
                                  color: context.colors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _printPdf(BuildContext context, String reportId) async {
    final systemProvider = Provider.of<SystemProvider>(context, listen: false);

    try {
      if (context.isTablet) {
        final url = 'http://localhost:4000/api/v1/reportData/$reportId/view-pdf';
        html.window.open(url, '_blank');
      } else {
        final pdfBytes = await systemProvider.fetchPdfReportById(reportId);
        if (pdfBytes != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PdfViewerScreen(pdfData: pdfBytes, reportName: 'Report_$reportId'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
