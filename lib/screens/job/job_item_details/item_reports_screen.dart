import 'dart:html' as html;
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/screens/job/job_item_details/pdf_viewer_screen.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ItemReportScreen extends StatefulWidget {
  final Item item;

  const ItemReportScreen({super.key, required this.item});

  @override
  State<ItemReportScreen> createState() => _ItemReportScreenState();
}

class _ItemReportScreenState extends State<ItemReportScreen> {
  bool _isDownloadingAll = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Fetch report types first (needed for the dialog)
        await context.read<SystemProvider>().fetchReportType();
        // Then fetch item-specific report data
        await context.read<SystemProvider>().fetchReportDataType(widget.item.itemId ?? '');
      } catch (e) {
        // Error will be handled by the provider
        print('Error fetching report data: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
    );
  }

  // Beautiful Empty State Widget for Reports
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decorative Icon with gradient background
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withOpacity(0.1),
                      Colors.purple.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 60,
                  color: context.colors.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'No Reports Available',
                style: context.topology.textTheme.titleLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Create your first report to get started\nwith tracking and documentation',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Primary Action Button
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateDialog(context);
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Create First Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: context.topology.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 40),

              // Feature hints
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'Report Benefits:',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      context,
                      Icons.analytics_outlined,
                      'Track inspection history',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context,
                      Icons.picture_as_pdf_outlined,
                      'Generate PDF documents',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context,
                      Icons.cloud_upload_outlined,
                      'Share and archive reports',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for mobile file saving

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.purple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Consumer<SystemProvider>(
      builder: (context, provider, child) {
        // Show loading indicator while fetching data
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message with retry option
        if (provider.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline, size: 40, color: Colors.red[400]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage ?? 'Failed to load reports',
                    style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchReportType(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show beautiful empty state if no reports
        if (!provider.hasItemReport) {
          return _buildEmptyState(context);
        }

        // Main content - Reports Table
        return LayoutBuilder(
          builder: (context, con) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Section with Total Reports and Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.primary.withOpacity(0.1), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Side - Total Reports Count
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.description, color: context.colors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Reports',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${provider.itemReportModel?.length ?? 0}',
                                style: context.topology.textTheme.titleLarge?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right Side - Action Buttons
                      Row(
                        children: [
                          // Download All Button (only shows if reports exist)
                          if (provider.itemReportModel != null &&
                              provider.itemReportModel!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isDownloadingAll
                                        ? null
                                        : () => _downloadAllPdfs(context, provider),
                                icon:
                                    _isDownloadingAll
                                        ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                        : const Icon(Icons.download, size: 18),
                                label: Text(_isDownloadingAll ? 'Downloading...' : 'Download All'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),

                          // Create Report Button
                          ElevatedButton.icon(
                            onPressed: () {
                              _showCreateDialog(context);
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Create Report'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Data Table Section
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: con.maxWidth),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.colors.primary.withOpacity(0.1), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: IntrinsicWidth(
                        stepWidth: double.infinity,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            context.colors.primary.withOpacity(0.08),
                          ),

                          // Table Column Headers
                          columns: [
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Report No',
                                  style: context.topology.textTheme.titleSmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Report Type',
                                  style: context.topology.textTheme.titleSmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Date',
                                  style: context.topology.textTheme.titleSmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  'Action',
                                  style: context.topology.textTheme.titleSmall?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // Table Rows - Generate dynamically from reports
                          rows: List.generate(provider.itemReportModel?.length ?? 0, (index) {
                            final report = provider.itemReportModel?.elementAt(index);
                            final isEven = index % 2 == 0;

                            return DataRow(
                              // Alternate row colors for better readability
                              color: MaterialStateProperty.resolveWith<Color?>((
                                Set<MaterialState> states,
                              ) {
                                return isEven ? context.colors.primary.withOpacity(0.03) : null;
                              }),

                              cells: [
                                // Report Number Cell
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: context.colors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.tag,
                                          size: 14,
                                          color: context.colors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        report?.reportId ?? '-',
                                        style: context.topology.textTheme.bodySmall?.copyWith(
                                          color: context.colors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Report Type Cell
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

                                // Date Cell
                                DataCell(
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Text(
                                        report?.createdAt?.formatFullDate ?? '-',
                                        style: context.topology.textTheme.bodySmall?.copyWith(
                                          color: context.colors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Button Cell
                                DataCell(
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _printPdf(context, report?.reportId ?? '');
                                      },
                                      icon: const Icon(Icons.visibility, size: 16),
                                      label: const Text('View'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.colors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
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

        // Show error message with retry option
        if (provider.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline, size: 40, color: Colors.red[400]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage ?? 'Failed to load reports',
                    style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchReportType(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show beautiful empty state
        if (!provider.hasReport) {
          return _buildEmptyState(context);
        }

        final reports = provider.getReportTypeModel!.data!;

        return Column(
          children: [
            // Header with FAB-style create button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: context.colors.primary.withOpacity(0.1), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports',
                        style: context.topology.textTheme.titleMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reports.length} ${reports.length == 1 ? 'report' : 'reports'} available',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  FloatingActionButton.small(
                    onPressed: () => _showCreateDialog(context),
                    backgroundColor: context.colors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Report List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.colors.primary.withOpacity(0.1), width: 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _handleAction(context, _getReportId(report)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Report Number Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.tag, size: 14, color: context.colors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getReportCode(report),
                                        style: context.topology.textTheme.bodySmall?.copyWith(
                                          color: context.colors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Report Name
                            Text(
                              _getReportName(report),
                              style: context.topology.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Date with icon
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  _getReportDate(report),
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _handleAction(context, _getReportId(report));
                                },
                                icon: const Icon(Icons.visibility, size: 18),
                                label: const Text('View Report'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient background
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.colors.primary.withOpacity(0.1),
                        context.colors.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.assignment, color: context.colors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Select Report Type',
                            style: context.topology.textTheme.titleMedium?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: context.colors.primary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Scrollable list of report names
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          _handleAction(context, report.reportType?.reportTypeId ?? '');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.colors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.description,
                                  color: context.colors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  report.reportType?.reportName ?? '',
                                  style: context.topology.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadAllPdfs(BuildContext context, SystemProvider provider) async {
    final reports = provider.itemReportModel;

    // Check if there are any reports to download
    if (reports == null || reports.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No reports available to download'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Set downloading state to true (disables button, shows loading)
    setState(() {
      _isDownloadingAll = true;
    });

    int successCount = 0;
    int failCount = 0;

    try {
      // Create archive
      final archive = Archive();

      // Show progress
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preparing ${reports.length} reports for download...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Loop through all reports and fetch PDFs
      for (var report in reports) {
        final reportId = report.reportId;
        if (reportId == null || reportId.isEmpty) continue;

        try {
          // Fetch PDF bytes using the same method as view button
          final pdfBytes = await provider.fetchPdfReportById(reportId);

          if (pdfBytes != null) {
            // Create a meaningful filename
            String fileName;

            if (report.reportName != null && report.reportName!.isNotEmpty) {
              fileName = '${_sanitizeFileName(report.reportName!)}_$reportId.pdf';
            } else if (report.reportDate != null) {
              fileName = 'Report_${report.reportDate}_$reportId.pdf';
            } else {
              fileName = 'Report_$reportId.pdf';
            }

            // Add file to archive
            final archiveFile = ArchiveFile(fileName, pdfBytes.length, pdfBytes);
            archive.addFile(archiveFile);
            successCount++;
          } else {
            print('Failed to fetch PDF for report $reportId: null bytes');
            failCount++;
          }
        } catch (e) {
          print('Failed to download report $reportId: $e');
          failCount++;
        }
      }

      // Only proceed if we have at least one successful download
      if (successCount > 0) {
        // Encode archive to ZIP
        final zipEncoder = ZipEncoder();
        final zipBytes = zipEncoder.encode(archive);

        if (zipBytes != null) {
          final zipFileName = 'All_Reports_${_getDateTimeString()}.zip';

          if (kIsWeb) {
            // For web: Download ZIP file with proper encoding
            final bytes = Uint8List.fromList(zipBytes);
            final blob = html.Blob([bytes], 'application/zip', 'native');
            final url = html.Url.createObjectUrlFromBlob(blob);

            // Create anchor element properly
            final anchor = html.document.createElement('a') as html.AnchorElement;
            anchor.href = url;
            anchor.style.display = 'none';
            anchor.download = zipFileName;

            // Append to body, click, and remove
            html.document.body?.children.add(anchor);
            anchor.click();

            // Clean up
            Future.delayed(const Duration(milliseconds: 100), () {
              html.document.body?.children.remove(anchor);
              html.Url.revokeObjectUrl(url);
            });
          } else {
            // For mobile: Save to downloads folder
            await _saveMobileZipFile(zipBytes, zipFileName, context);
          }
        }
      }

      // Show result message
      if (context.mounted) {
        String message;
        Color backgroundColor;

        if (failCount == 0 && successCount > 0) {
          message = 'Successfully downloaded $successCount reports as ZIP';
          backgroundColor = Colors.green;
        } else if (successCount == 0) {
          message = 'Failed to download all reports';
          backgroundColor = Colors.red;
        } else {
          message = 'Downloaded $successCount reports as ZIP, $failCount failed';
          backgroundColor = Colors.orange;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error creating ZIP file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create ZIP file: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Always reset downloading state when done
      if (mounted) {
        setState(() {
          _isDownloadingAll = false;
        });
      }
    }
  }

  // Helper function to sanitize filename (remove invalid characters)
  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').replaceAll(RegExp(r'\s+'), '_').trim();
  }

  // Helper function to get formatted date-time string
  String _getDateTimeString() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveMobileZipFile(List<int> zipBytes, String fileName, BuildContext context) async {
    try {
      // Request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      // For Android 11+ (API 30+)
      if (io.Platform.isAndroid) {
        var manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          manageStatus = await Permission.manageExternalStorage.request();
        }
      }

      if (status.isGranted ||
          (io.Platform.isAndroid && await Permission.manageExternalStorage.isGranted)) {
        io.Directory? downloadsDir;

        if (io.Platform.isAndroid) {
          downloadsDir = io.Directory('/storage/emulated/0/Download');
          if (!await downloadsDir.exists()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else if (io.Platform.isIOS) {
          downloadsDir = await getApplicationDocumentsDirectory();
        }

        if (downloadsDir != null) {
          final filePath = '${downloadsDir.path}/$fileName';
          final file = io.File(filePath);
          await file.writeAsBytes(zipBytes);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ZIP saved to: ${downloadsDir.path}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission required'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving ZIP file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save ZIP: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
