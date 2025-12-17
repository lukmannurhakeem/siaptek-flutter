import 'package:INSPECT/core/extension/date_time_extension.dart';
import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/report_approval_model.dart';
import 'package:INSPECT/providers/job_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportApprovalsTab extends StatefulWidget {
  final String jobId;

  const ReportApprovalsTab({super.key, required this.jobId});

  @override
  State<ReportApprovalsTab> createState() => _ReportApprovalsTabState();
}

class _ReportApprovalsTabState extends State<ReportApprovalsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<int> selectedRows = <int>{};
  bool selectAll = false;
  String _currentView = 'pending'; // 'pending' or 'approved'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Filter reports by current view (pending/approved) and search query
  List<ReportApprovalData> _getFilteredReports(JobProvider provider) {
    return provider.searchReports(_searchQuery, _currentView);
  }

  // ✅ Check if there's any data at all (before search filter)
  bool _hasAnyData(JobProvider provider) {
    // Check if there's ANY data in either pending or approved lists
    // Don't just check the current view
    return provider.pendingReports.isNotEmpty || provider.approvedReports.isNotEmpty;
  }

  // ✅ Empty state when no data exists
  Widget _buildReportApprovalEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withOpacity(0.15),
                      Colors.blue.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 70,
                  color: context.colors.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'No Inspections Yet',
                style: context.topology.textTheme.titleLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Begin your inspection journey by\ncreating your first inspection',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(
                    AppRoutes.jobItemCreateScreen,
                    arguments: {'jobId': widget.jobId},
                  );
                },
                icon: const Icon(Icons.add_circle_outline, size: 22),
                label: const Text('Create First Inspection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  textStyle: context.topology.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'What you can do:',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      context,
                      Icons.checklist_outlined,
                      'Conduct thorough inspections',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      context,
                      Icons.camera_alt_outlined,
                      'Capture photos and evidence',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      context,
                      Icons.description_outlined,
                      'Generate detailed reports',
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

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colors.primary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Empty state when search returns no results
  Widget _buildSearchEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No reports found for "$_searchQuery"',
            style: context.topology.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _searchController.clear(),
            icon: const Icon(Icons.clear),
            label: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, ReportApprovalData report, bool isApprove) {
    final TextEditingController commentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isApprove ? Icons.check_circle : Icons.cancel,
                color: isApprove ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isApprove ? 'Approve Report' : 'Reject Report',
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              report.reportName ?? "Unknown Report",
                              style: context.topology.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2, size: 14, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Item: ${report.itemNo ?? "N/A"}',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentsController,
                  decoration: InputDecoration(
                    labelText: 'Comments (Optional)',
                    hintText: 'Add your comments here...',
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.comment),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _handleApprovalAction(
                  context,
                  report,
                  isApprove,
                  commentsController.text.trim().isEmpty ? null : commentsController.text.trim(),
                );
              },
              icon: Icon(isApprove ? Icons.check : Icons.close),
              label: Text(isApprove ? 'Approve' : 'Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      commentsController.dispose();
    });
  }

  Future<void> _handleApprovalAction(
    BuildContext context,
    ReportApprovalData report,
    bool isApprove,
    String? comments,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        isApprove ? 'Approving report...' : 'Rejecting report...',
                        style: context.topology.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );

    try {
      final provider = context.read<JobProvider>();
      final result = await provider.updateReportApprovalStatus(context, report.itemID ?? 'itemId');

      if (mounted) Navigator.of(context).pop();

      if (result != null && result['success'] == true) {
        final bool wasQueued = result['queued'] == true;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    wasQueued ? Icons.cloud_queue : (isApprove ? Icons.check_circle : Icons.cancel),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      wasQueued
                          ? 'Saved Offline - Will sync when online'
                          : (isApprove ? 'Report Approved!' : 'Report Rejected'),
                    ),
                  ),
                ],
              ),
              backgroundColor: wasQueued ? Colors.blue : (isApprove ? Colors.green : Colors.orange),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception(result?['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () => _handleApprovalAction(context, report, isApprove, comments),
            ),
          ),
        );
      }
    }
  }

  Widget _buildApprovalStatusBadge(BuildContext context, String status) {
    Color color;
    IconData icon;
    String displayText;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        displayText = 'APPROVED';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        displayText = 'REJECTED';
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        displayText = 'PENDING';
        break;
      default:
        color = Colors.blue;
        icon = Icons.help_outline;
        displayText = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: context.topology.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _buildDataColumn(BuildContext context, String label, {bool centered = false}) {
    return DataColumn(
      label:
          centered
              ? Center(
                child: Text(
                  label,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: Colors.indigo.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
              : Text(
                label,
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: Colors.indigo.shade800,
                  fontWeight: FontWeight.w700,
                ),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        // ✅ FIXED: Use searchReports instead of searchItems
        final filteredList = provider.searchReports(_searchQuery, _currentView);

        // ✅ Check if data has been fetched at least once
        if (!provider.hasAttemptedFetch) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ Check if there's any data at all (before search)
        final hasData = _hasAnyData(provider);

        if (!hasData && !provider.isLoading) {
          return _buildReportApprovalEmptyState(context);
        }

        // ✅ Check if search returned no results
        if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
          return _buildSearchEmptyState(context);
        }

        return context.isTablet
            ? _buildTabletView(context, filteredList)
            : _buildMobileView(context, filteredList);
      },
    );
  }

  // Replace your _buildTabletView method with this fixed version:

  // Complete fixed tablet view with view toggles and data display

  Widget _buildTabletView(BuildContext context, List<ReportApprovalData> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CommonTextField(
              controller: _searchController,
              hintText: 'Search reports by name, item, or inspector...',
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                      : null,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentView = 'pending';
                      });
                    },
                    icon: const Icon(Icons.pending, size: 18),
                    label: const Text('Pending'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentView == 'pending' ? Colors.teal : Colors.grey[300],
                      foregroundColor: _currentView == 'pending' ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentView = 'approved';
                      });
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentView == 'approved' ? Colors.teal : Colors.grey[300],
                      foregroundColor: _currentView == 'approved' ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Show message if no data
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty ? Icons.search_off : Icons.pending_actions,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No reports found for "$_searchQuery"'
                              : 'No ${_currentView} reports yet',
                          style: context.topology.textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 20,
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 56,
                      // onSelectAll: (value) {
                      //   setState(() {
                      //     selectAll = value ?? false;
                      //     if (selectAll) {
                      //       selectedRows = Set<int>.from(
                      //         List.generate(list.length, (index) => index),
                      //       );
                      //     } else {
                      //       selectedRows.clear();
                      //     }
                      //   });
                      // },
                      columns: [
                        DataColumn(
                          label: Text(
                            'Item No',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 250,
                            child: Text(
                              'Report Name',
                              style: context.topology.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Inspector',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Report Date',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Status',
                              style: context.topology.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (_currentView == 'pending')
                          DataColumn(
                            label: Center(
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
                      rows: List.generate(list.length, (index) {
                        final data = list[index];
                        final isEven = index % 2 == 0;

                        return DataRow(
                          selected: selectedRows.contains(index),
                          onSelectChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                selectedRows.add(index);
                              } else {
                                selectedRows.remove(index);
                              }
                              selectAll = selectedRows.length == list.length;
                            });
                          },
                          color: MaterialStateProperty.resolveWith<Color?>((
                            Set<MaterialState> states,
                          ) {
                            return isEven ? context.colors.primary.withOpacity(0.05) : null;
                          }),
                          cells: [
                            // Item No
                            DataCell(
                              Text(
                                data.itemNo ?? '-',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Report Name
                            DataCell(
                              SizedBox(
                                width: 250,
                                child: Text(
                                  data.reportName ?? '-',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            // Inspector
                            DataCell(
                              Text(
                                data.displayInspector,
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            // Report Date
                            DataCell(
                              Text(
                                data.reportDateTime?.formatShortDate ??
                                    data.reportDate?.substring(0, 10) ??
                                    '-',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            // Status Badge
                            DataCell(
                              Center(
                                child: _buildApprovalStatusBadge(
                                  context,
                                  data.approvalStatus ?? 'pending',
                                ),
                              ),
                            ),
                            // Action Buttons (only for pending)
                            if (_currentView == 'pending')
                              DataCell(
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 22,
                                        ),
                                        onPressed: () => _showApprovalDialog(context, data, true),
                                        tooltip: 'Approve',
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red, size: 22),
                                        onPressed: () => _showApprovalDialog(context, data, false),
                                        tooltip: 'Reject',
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionStatusBadge(BuildContext context, String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'accepted':
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
      case 'failed':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, List<ReportApprovalData> list) {
    return Column(
      children: [
        // Stats Cards Row
        Container(
          padding: const EdgeInsets.all(16),
          child: Consumer<JobProvider>(
            builder: (context, provider, _) {
              final stats = provider.getApprovalStats();
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          context,
                          'Total Reports',
                          stats['total'].toString(),
                          Icons.description,
                          Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatsCard(
                          context,
                          'Pending',
                          stats['pending'].toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          context,
                          'Approved',
                          stats['approved'].toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatsCard(
                          context,
                          'Rejected',
                          stats['rejected'].toString(),
                          Icons.cancel,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // View Toggle Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentView = 'pending';
                    });
                  },
                  icon: const Icon(Icons.pending, size: 18),
                  label: const Text('Pending'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentView == 'pending' ? Colors.teal : Colors.grey[300],
                    foregroundColor: _currentView == 'pending' ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentView = 'approved';
                    });
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentView == 'approved' ? Colors.teal : Colors.grey[300],
                    foregroundColor: _currentView == 'approved' ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CommonTextField(
            controller: _searchController,
            hintText: 'Search reports by name, item, or inspector...',
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                    : null,
          ),
        ),

        const SizedBox(height: 16),

        // Report List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final report = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              report.reportName ?? 'Unknown Report',
                              style: context.topology.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildApprovalStatusBadge(context, report.approvalStatus ?? 'pending'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.inventory_2, 'Item No', report.itemNo ?? 'N/A'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.person, 'Inspector', report.displayInspector),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Report Date',
                        report.reportDateTime?.formatShortDate ?? 'N/A',
                      ),
                      if (_currentView == 'pending') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showApprovalDialog(context, report, true),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showApprovalDialog(context, report, false),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
