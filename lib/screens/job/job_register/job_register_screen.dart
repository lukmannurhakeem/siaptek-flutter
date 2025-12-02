import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/core/utils/file_export_stub.dart'
    if (dart.library.html) 'package:base_app/core/utils/file_export_web.dart'
    if (dart.library.io) 'package:base_app/core/utils/file_export_mobile.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/model/report_approval_model.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobRegisterScreen extends StatefulWidget {
  final String jobId;

  const JobRegisterScreen({super.key, required this.jobId});

  @override
  State<JobRegisterScreen> createState() => _JobRegisterScreenState();
}

class _JobRegisterScreenState extends State<JobRegisterScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int sortColumnIndex = 0;
  Set<int> selectedRows = <int>{};
  bool selectAll = false;

  Map<String, bool> selectedColumns = {
    'item': true,
    'description': true,
    'category': true,
    'location': true,
    'status': true,
    'inspectedOn': true,
    'expiryDate': true,
  };

  final List<Tab> tabs = const [
    Tab(text: 'Item Register'),
    Tab(text: 'Inspection Register'),
    Tab(text: 'Report Approvals'),
    Tab(text: 'Reporting'),
    Tab(text: 'Files'),
    Tab(text: 'Job Progress'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<JobProvider>();
      await provider.fetchJobRegisterModel(context, widget.jobId);
      await provider.fetchReportApprovals(context, widget.jobId);
      if (mounted) setState(() {});
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void didUpdateWidget(JobRegisterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jobId != widget.jobId) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = context.read<JobProvider>();
        await provider.fetchJobRegisterModel(context, widget.jobId);
        await provider.fetchReportApprovals(context, widget.jobId);
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showColumnSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Columns to Export',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: const Text('Item'),
                      value: selectedColumns['item'],
                      onChanged:
                          (value) => setState(() => selectedColumns['item'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Description'),
                      value: selectedColumns['description'],
                      onChanged:
                          (value) =>
                              setState(() => selectedColumns['description'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Category'),
                      value: selectedColumns['category'],
                      onChanged:
                          (value) => setState(() => selectedColumns['category'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Location'),
                      value: selectedColumns['location'],
                      onChanged:
                          (value) => setState(() => selectedColumns['location'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Status'),
                      value: selectedColumns['status'],
                      onChanged:
                          (value) => setState(() => selectedColumns['status'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Inspected On'),
                      value: selectedColumns['inspectedOn'],
                      onChanged:
                          (value) =>
                              setState(() => selectedColumns['inspectedOn'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Expiry Date'),
                      value: selectedColumns['expiryDate'],
                      onChanged:
                          (value) => setState(() => selectedColumns['expiryDate'] = value ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Export Data',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
          content: Text(
            'Export ${selectedRows.length} selected rows to CSV file?',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                await _exportToCSV();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CSV file exported successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Export'),
            ),
          ],
        );
      },
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
                      if (report.regulation != null && report.regulation!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.rule, size: 14, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                report.regulation!,
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        isApprove
                            ? Colors.green.withOpacity(0.05)
                            : Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          isApprove
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isApprove ? Icons.info_outline : Icons.warning_amber,
                        size: 16,
                        color: isApprove ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isApprove
                              ? 'This report will be marked as approved and moved to approved list.'
                              : 'This report will be marked as rejected. You may need to provide comments.',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: isApprove ? Colors.green.shade700 : Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
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
    // Validate report ID

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
                      const SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
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

      print('🎯 UI: Starting approval action...');
      print('   Report ID: ${report.itemID}');
      print('   Job ID: ${widget.jobId}');
      print('   Action: ${isApprove ? "Approve" : "Reject"}');
      print('   Comments: ${comments ?? "None"}');

      // ADD THIS LINE - Call the provider method
      final result = await provider.updateReportApprovalStatus(context, report.itemID ?? 'itemId');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Check result and show appropriate message
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wasQueued
                              ? 'Saved Offline'
                              : (isApprove ? 'Report Approved!' : 'Report Rejected'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (wasQueued)
                          const Text(
                            'Will sync when connection is restored',
                            style: TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: wasQueued ? Colors.blue : (isApprove ? Colors.green : Colors.orange),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              action:
                  wasQueued
                      ? SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {})
                      : null,
            ),
          );
        }

        print('✅ UI: Approval action completed successfully');
      } else {
        throw Exception(result?['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('❌ UI: Error in approval action - $e');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Failed to Update', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
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

  Future<void> _exportToCSV() async {
    if (selectedRows.isEmpty) return;

    final provider = context.read<JobProvider>();
    final filteredList = provider.searchItems(_searchQuery, _tabController.index);

    List<String> headers = [];
    if (selectedColumns['item'] == true) headers.add('Item');
    if (selectedColumns['description'] == true) headers.add('Description');
    if (selectedColumns['category'] == true) headers.add('Category');
    if (selectedColumns['location'] == true) headers.add('Location');
    if (selectedColumns['status'] == true) headers.add('Status');
    if (selectedColumns['inspectedOn'] == true) headers.add('Inspected On');
    if (selectedColumns['expiryDate'] == true) headers.add('Expiry Date');

    List<List<String>> rows = [headers];

    for (int index in selectedRows) {
      if (index >= filteredList.length) continue;
      final data = filteredList[index];
      List<String> row = [];

      if (selectedColumns['item'] == true) row.add(_escapeCSVField(data.itemNo ?? ''));
      if (selectedColumns['description'] == true) row.add(_escapeCSVField(data.description ?? ''));
      if (selectedColumns['category'] == true) row.add(_escapeCSVField(data.categoryId ?? ''));
      if (selectedColumns['location'] == true)
        row.add(_escapeCSVField(data.detailedLocation ?? ''));
      if (selectedColumns['status'] == true) row.add(_escapeCSVField(data.status ?? ''));
      if (selectedColumns['inspectedOn'] == true)
        row.add(_escapeCSVField(data.firstUseDate?.formatShortDate ?? ''));
      if (selectedColumns['expiryDate'] == true)
        row.add(_escapeCSVField(data.expiryDateTimeStamp?.formatShortDate ?? ''));

      rows.add(row);
    }

    String csvContent = rows.map((row) => row.join(',')).join('\n');

    try {
      await exportCSV(csvContent, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _escapeCSVField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job Register - ${widget.jobId}',
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        leading: IconButton(
          onPressed: () => NavigationService().goBack(),
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading data: ${provider.error}',
                    style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchJobRegisterModel(context, widget.jobId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: context.paddingHorizontal,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: tabs,
                    labelColor: context.colors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: context.colors.primary,
                    indicatorWeight: 3,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.zero,
                    onTap: (index) {
                      setState(() {
                        selectedRows.clear();
                        selectAll = false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(provider),
                      _buildInspectionRegisterTab(provider),
                      _buildReportApprovalsTab(provider),
                      _buildTabContent(provider),
                      _buildTabContent(provider),
                      _buildTabContent(provider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: context.topology.textTheme.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String text,
    bool isActive,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? Colors.teal : Colors.transparent,
        foregroundColor: isActive ? Colors.white : Colors.grey[700],
        side: BorderSide(color: isActive ? Colors.teal : Colors.grey[400]!, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: context.topology.textTheme.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(text),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withOpacity(0.1),
                      Colors.blue.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: context.colors.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Items Yet',
                style: context.topology.textTheme.titleLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start building your inventory by creating\nyour first item for this job',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(
                    AppRoutes.jobItemCreateScreen,
                    arguments: {'jobId': widget.jobId},
                  );
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Create First Item'),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'What you can do:',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      context,
                      Icons.check_circle_outline,
                      'Track items and inspections',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context,
                      Icons.location_on_outlined,
                      'Manage locations and categories',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(context, Icons.download_outlined, 'Export reports and data'),
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
        Icon(icon, size: 20, color: Colors.blue),
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

  // PART 2 OF 2: Add these methods to the _JobRegisterScreenState class
  // (Replace the closing brace } from Part 1 with this code)

  Widget _buildTabContent(JobProvider provider) {
    final filteredList = provider.searchItems(_searchQuery, _tabController.index);

    if (filteredList.isEmpty && !provider.isLoading) {
      if (_searchQuery.isEmpty) {
        return _buildEmptyState(context);
      }

      return Container(
        padding: const EdgeInsets.only(top: 16),
        child: ListView(
          children: [
            CommonTextField(
              controller: _searchController,
              hintText: 'Search items',
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                      : null,
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No items found',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search',
                    style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return context.isTablet
        ? _buildTabletView(context, filteredList)
        : _buildMobileView(context, filteredList);
  }

  Widget _buildTabletView(BuildContext context, List<Item> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              CommonTextField(
                controller: _searchController,
                hintText: 'Search items',
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionButton(context, 'Create Item', Icons.add, Colors.blue, () {
                        NavigationService().navigateTo(
                          AppRoutes.jobItemCreateScreen,
                          arguments: {'jobId': widget.jobId},
                        );
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'Export Grid',
                        Icons.download,
                        Colors.blue,
                        () => _showExportDialog(context),
                      ),
                      const SizedBox(width: 8),
                      _buildToggleButton(
                        context,
                        'All',
                        _tabController.index == 0,
                        () => _tabController.animateTo(0),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Not Inspected',
                        _tabController.index == 2,
                        () => _tabController.animateTo(2),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(context, 'Draft', false, () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Draft filter clicked')));
                      }),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Inspected',
                        _tabController.index == 1,
                        () => _tabController.animateTo(1),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Include Archived',
                        _tabController.index == 3,
                        () => _tabController.animateTo(3),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(context, 'Items I Can Inspect', false, () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Items I Can Inspect clicked')),
                        );
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'Column visibility',
                        Icons.view_column,
                        Colors.teal,
                        () => _showColumnSelectionDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: IntrinsicWidth(
                  stepWidth: double.infinity,
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    showCheckboxColumn: true,
                    columnSpacing: 20,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 56,
                    onSelectAll: (value) {
                      setState(() {
                        selectAll = value ?? false;
                        if (selectAll) {
                          selectedRows = Set<int>.from(
                            List.generate(list.length, (index) => index),
                          );
                        } else {
                          selectedRows.clear();
                        }
                      });
                    },
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Item',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        onSort: (columnIndex, _) {},
                      ),
                      DataColumn(
                        label: Expanded(
                          flex: 2,
                          child: Text(
                            'Description',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Category',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Location',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
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
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Inspected On',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Expiry Date',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: List.generate(list.length, (index) {
                      final data = list.elementAt(index);
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
                          DataCell(
                            InkWell(
                              onTap: () {
                                NavigationService().navigateTo(
                                  AppRoutes.jobItemDetails,
                                  arguments: {'item': data},
                                );
                              },
                              child: Text(
                                data.itemId ?? '-',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.description ?? '-',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          DataCell(
                            Text(
                              data.categoryId ?? '-',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          DataCell(
                            Text(
                              data.locationId ?? '-',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(data.status ?? ''),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  data.status ?? '-',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.expiryDateTimeStamp?.formatShortDate ?? '-',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.expiryDateTimeStamp?.formatShortDate ?? '',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
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

  Widget _buildMobileView(BuildContext context, List<Item> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: sortColumnIndex,
          showCheckboxColumn: true,
          onSelectAll: (value) {
            setState(() {
              selectAll = value ?? false;
              if (selectAll) {
                selectedRows = Set<int>.from(List.generate(list.length, (index) => index));
              } else {
                selectedRows.clear();
              }
            });
          },
          columns: [
            DataColumn(
              label: Text(
                'Item',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Description',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Category',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Location',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Inspected On',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Expiry Date',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
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
              color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                return isEven ? context.colors.primary.withOpacity(0.05) : null;
              }),
              cells: [
                DataCell(
                  Text(
                    data.itemId ?? '-',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.description ?? '-',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.categoryId ?? '-',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.locationId ?? '-',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data.status ?? ''),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.status ?? '-',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.expiryDateTimeStamp?.formatShortDate ?? '-',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.expiryDateTimeStamp?.formatShortDate ?? '',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  } // PART 3 OF 3 (FINAL): Add these remaining methods to complete the class

  // ==================== INSPECTION REGISTER TAB ====================

  Widget _buildInspectionRegisterTab(JobProvider provider) {
    final filteredList = provider.searchItems(_searchQuery, 1);

    if (filteredList.isEmpty && !provider.isLoading) {
      if (_searchQuery.isEmpty) {
        return _buildInspectionEmptyState(context);
      }
      return _buildInspectionSearchEmpty(context);
    }

    return context.isTablet
        ? _buildInspectionTabletView(context, filteredList)
        : _buildInspectionMobileView(context, filteredList);
  }

  Widget _buildInspectionEmptyState(BuildContext context) {
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
                    colors: [Colors.teal.withOpacity(0.15), Colors.green.withOpacity(0.08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: Icon(Icons.fact_check_outlined, size: 70, color: Colors.teal.shade600),
              ),
              const SizedBox(height: 28),
              Text(
                'No Inspections Yet',
                style: context.topology.textTheme.headlineSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Begin your inspection journey by\nconducting your first inspection',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(
                    AppRoutes.reportCreate,
                    arguments: {'jobId': widget.jobId},
                  );
                },
                icon: const Icon(Icons.playlist_add_check, size: 22),
                label: const Text('Start Inspection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
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
              _buildInspectionInfoCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectionInfoCards(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.teal.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Inspection Benefits',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInspectionBenefit(
            context,
            Icons.verified_outlined,
            'Quality Assurance',
            'Ensure all items meet safety standards',
          ),
          const SizedBox(height: 12),
          _buildInspectionBenefit(
            context,
            Icons.track_changes_outlined,
            'Track Progress',
            'Monitor inspection status in real-time',
          ),
          const SizedBox(height: 12),
          _buildInspectionBenefit(
            context,
            Icons.analytics_outlined,
            'Generate Reports',
            'Create comprehensive inspection reports',
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionBenefit(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.teal.shade700),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionSearchEmpty(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: ListView(
        children: [
          CommonTextField(
            controller: _searchController,
            hintText: 'Search inspections',
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                    : null,
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: Icon(Icons.search_off, size: 72, color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                Text(
                  'No inspections found',
                  style: context.topology.textTheme.titleLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Try adjusting your search criteria',
                  style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionTabletView(BuildContext context, List<Item> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              CommonTextField(
                controller: _searchController,
                hintText: 'Search inspections by item, category, or status...',
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatsCard(
                        context,
                        'Total Inspections',
                        list.length.toString(),
                        Icons.fact_check,
                        Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatsCard(
                        context,
                        'Completed',
                        list
                            .where((item) => item.inspectionStatus?.toLowerCase() == 'accepted')
                            .length
                            .toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatsCard(
                        context,
                        'Pending',
                        list
                            .where((item) => item.inspectionStatus?.toLowerCase() == 'pending')
                            .length
                            .toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionButton(
                        context,
                        'New Inspection',
                        Icons.add_task,
                        Colors.teal,
                        () {
                          NavigationService().navigateTo(
                            AppRoutes.reportCreate,
                            arguments: {'jobId': widget.jobId},
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'Export Report',
                        Icons.file_download,
                        Colors.blue,
                        () => _showExportDialog(context),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'Filter Results',
                        Icons.filter_list,
                        Colors.deepPurple,
                        () {},
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.teal.withOpacity(0.08)),
                      headingRowHeight: 60,
                      dataRowMinHeight: 70,
                      dataRowMaxHeight: 70,
                      showCheckboxColumn: true,
                      columnSpacing: 24,
                      onSelectAll: (value) {
                        setState(() {
                          selectAll = value ?? false;
                          if (selectAll) {
                            selectedRows = Set<int>.from(
                              List.generate(list.length, (index) => index),
                            );
                          } else {
                            selectedRows.clear();
                          }
                        });
                      },
                      columns: [
                        _buildDataColumn(context, 'Item No'),
                        _buildDataColumn(context, 'Description', flex: 2),
                        _buildDataColumn(context, 'Category'),
                        _buildDataColumn(context, 'Location'),
                        _buildDataColumn(context, 'Inspector'),
                        _buildDataColumn(context, 'Inspection Date'),
                        _buildDataColumn(context, 'Status', centered: true),
                        _buildDataColumn(context, 'Actions', centered: true),
                      ],
                      rows: List.generate(list.length, (index) {
                        final item = list[index];
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
                          color: MaterialStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.teal.withOpacity(0.12);
                            }
                            return isEven ? Colors.grey.withOpacity(0.03) : null;
                          }),
                          cells: [
                            DataCell(
                              InkWell(
                                onTap: () {
                                  NavigationService().navigateTo(
                                    AppRoutes.jobItemDetails,
                                    arguments: {'item': item},
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.itemNo ?? '-',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.description ?? '-',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            DataCell(
                              _buildChip(
                                context,
                                item.categoryId ?? '-',
                                Colors.purple.shade50,
                                Colors.purple.shade700,
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.locationId ?? '-',
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.teal.shade100,
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.inspectionStatus ?? 'Not Assigned',
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.firstUseDate?.formatShortDate ?? '-',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Center(
                                child: _buildInspectionStatusBadge(
                                  context,
                                  item.inspectionStatus ?? 'pending',
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 20),
                                      color: Colors.blue.shade600,
                                      tooltip: 'View Details',
                                      onPressed: () {
                                        NavigationService().navigateTo(
                                          AppRoutes.jobItemDetails,
                                          arguments: {'item': item},
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      color: Colors.orange.shade600,
                                      tooltip: 'Edit Inspection',
                                      onPressed: () {},
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInspectionMobileView(BuildContext context, List<Item> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: ListView(
        children: [
          CommonTextField(
            controller: _searchController,
            hintText: 'Search inspections...',
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                    : null,
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCompactStatsCard(
                  context,
                  list.length.toString(),
                  'Total',
                  Icons.fact_check,
                  Colors.teal,
                ),
                const SizedBox(width: 12),
                _buildCompactStatsCard(
                  context,
                  list
                      .where((item) => item.inspectionStatus?.toLowerCase() == 'accepted')
                      .length
                      .toString(),
                  'Completed',
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildCompactStatsCard(
                  context,
                  list
                      .where((item) => item.inspectionStatus?.toLowerCase() == 'pending')
                      .length
                      .toString(),
                  'Pending',
                  Icons.pending,
                  Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...list.map((item) => _buildInspectionMobileCard(context, item)).toList(),
        ],
      ),
    );
  }

  Widget _buildInspectionMobileCard(BuildContext context, Item item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          NavigationService().navigateTo(AppRoutes.jobItemDetails, arguments: {'item': item});
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.itemNo ?? '-',
                      style: context.topology.textTheme.labelLarge?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildInspectionStatusBadge(context, item.inspectionStatus ?? 'pending'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.description ?? '-',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMobileInfoItem(
                      context,
                      Icons.category,
                      'Category',
                      item.categoryId ?? '-',
                    ),
                  ),
                  Expanded(
                    child: _buildMobileInfoItem(
                      context,
                      Icons.location_on,
                      'Location',
                      item.locationId ?? '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildMobileInfoItem(
                      context,
                      Icons.person,
                      'Inspector',
                      item.inspectionStatus ?? 'Not Assigned',
                    ),
                  ),
                  Expanded(
                    child: _buildMobileInfoItem(
                      context,
                      Icons.calendar_today,
                      'Date',
                      item.firstUseDate?.formatShortDate ?? '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        NavigationService().navigateTo(
                          AppRoutes.jobItemDetails,
                          arguments: {'item': item},
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade700,
                        side: BorderSide(color: Colors.orange.shade200),
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
  }

  DataColumn _buildDataColumn(
    BuildContext context,
    String label, {
    int flex = 1,
    bool centered = false,
  }) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child:
            centered
                ? Center(
                  child: Text(
                    label,
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
                : Text(
                  label,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: Colors.teal.shade800,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
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

  Widget _buildCompactStatsCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: context.topology.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
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

  Widget _buildMobileInfoItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.topology.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  } // PART 4 OF 4 (FINAL): Report Approvals Tab - Add these methods and close the class

  // ==================== REPORT APPROVALS TAB ====================

  Widget _buildReportApprovalsTab(JobProvider provider) {
    final approvalReports = provider.reportApprovals; // Now using real data

    // if (approvalReports.isEmpty && !provider.isLoading) {
    //   if (_searchQuery.isEmpty) {
    //     return _buildReportApprovalsEmptyState(context);
    //   }
    //   return _buildReportApprovalsSearchEmpty(context);
    // }

    return context.isTablet
        ? _buildReportApprovalsTabletView(context, approvalReports)
        : _buildReportApprovalsMobileView(context, approvalReports);
  }

  Widget _buildReportApprovalsEmptyState(BuildContext context) {
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
                    colors: [Colors.indigo.withOpacity(0.15), Colors.blue.withOpacity(0.08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(Icons.approval_outlined, size: 70, color: Colors.indigo.shade600),
              ),
              const SizedBox(height: 28),
              Text(
                'No Reports Pending Approval',
                style: context.topology.textTheme.headlineSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'All inspection reports have been\nreviewed and approved',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(
                    AppRoutes.reportCreate,
                    arguments: {'jobId': widget.jobId},
                  );
                },
                icon: const Icon(Icons.post_add, size: 22),
                label: const Text('Create New Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
              _buildApprovalInfoCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalInfoCards(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.indigo.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Approval Workflow',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: Colors.indigo.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildApprovalFeature(
            context,
            Icons.rate_review_outlined,
            'Review Reports',
            'Examine inspection details thoroughly',
          ),
          const SizedBox(height: 12),
          _buildApprovalFeature(
            context,
            Icons.thumbs_up_down_outlined,
            'Approve or Reject',
            'Make informed decisions on report quality',
          ),
          const SizedBox(height: 12),
          _buildApprovalFeature(
            context,
            Icons.history_outlined,
            'Track History',
            'Monitor all approval activities and changes',
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalFeature(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.indigo.shade700),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
      case 'draft':
        color = Colors.grey;
        icon = Icons.edit_note;
        displayText = 'DRAFT';
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
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportApprovalsSearchEmpty(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: ListView(
        children: [
          CommonTextField(
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
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: Icon(Icons.search_off, size: 72, color: Colors.grey[400]),
                ),
                const SizedBox(height: 24),
                Text(
                  'No reports found',
                  style: context.topology.textTheme.titleLarge?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Try adjusting your search criteria',
                  style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportApprovalsTabletView(BuildContext context, List<ReportApprovalData> reports) {
    final provider = context.watch<JobProvider>();
    final stats = provider.getApprovalStats();

    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              CommonTextField(
                controller: _searchController,
                hintText: 'Search reports by name, item, inspector, or regulation...',
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
              ),

              // Stats Cards
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
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
                    const SizedBox(width: 12),
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
              ),

              // Action Buttons with WORKING filters
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // ✅ WORKING FILTER BUTTONS
                      _buildToggleButton(
                        context,
                        'All',
                        provider.currentApprovalFilter == 'all',
                        () {
                          provider.setApprovalFilter('all');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Pending (${stats['pending']})',
                        provider.currentApprovalFilter == 'pending',
                        () {
                          provider.setApprovalFilter('pending');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Approved (${stats['approved']})',
                        provider.currentApprovalFilter == 'approved',
                        () {
                          provider.setApprovalFilter('approved');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'Export Reports',
                        Icons.file_download,
                        Colors.blue,
                        () => _showExportDialog(context),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(context, 'Refresh', Icons.refresh, Colors.teal, () async {
                        await provider.fetchReportApprovals(context, widget.jobId);
                      }),
                    ],
                  ),
                ),
              ),

              // Data Table
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.indigo.withOpacity(0.08)),
                      headingRowHeight: 60,
                      dataRowMinHeight: 70,
                      dataRowMaxHeight: 70,
                      showCheckboxColumn: true,
                      columnSpacing: 24,
                      onSelectAll: (value) {
                        setState(() {
                          selectAll = value ?? false;
                          if (selectAll) {
                            selectedRows = Set<int>.from(
                              List.generate(reports.length, (index) => index),
                            );
                          } else {
                            selectedRows.clear();
                          }
                        });
                      },
                      columns: [
                        _buildDataColumn(context, 'Report Name', flex: 2),
                        _buildDataColumn(context, 'Item No'),
                        _buildDataColumn(context, 'Inspector'),
                        _buildDataColumn(context, 'Report Date'),
                        _buildDataColumn(context, 'Expiry Date'),
                        _buildDataColumn(context, 'Status', centered: true),
                        _buildDataColumn(context, 'Approval', centered: true),
                        _buildDataColumn(context, 'Actions', centered: true),
                      ],
                      rows: List.generate(reports.length, (index) {
                        final report = reports[index];
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
                              selectAll = selectedRows.length == reports.length;
                            });
                          },
                          color: MaterialStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.indigo.withOpacity(0.12);
                            }
                            return isEven ? Colors.grey.withOpacity(0.03) : null;
                          }),
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    report.reportName ?? '-',
                                    style: context.topology.textTheme.bodyMedium?.copyWith(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    report.regulation ?? '-',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              _buildChip(
                                context,
                                report.itemNo ?? '-',
                                Colors.blue.shade50,
                                Colors.blue.shade700,
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.indigo.shade100,
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.indigo.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      report.displayInspector,
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    report.reportDateTime?.formatShortDate ?? '-',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Icon(Icons.event_busy, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    report.expiryDateTime?.formatShortDate ?? '-',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Center(
                                child: _buildApprovalStatusBadge(context, report.status ?? 'draft'),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: _buildApprovalStatusBadge(
                                  context,
                                  report.approvalStatus ?? 'pending',
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 20),
                                      color: Colors.blue.shade600,
                                      tooltip: 'View Report',
                                      onPressed: () {
                                        // TODO: Navigate to report details
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('View: ${report.reportName}')),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check, size: 20),
                                      color: Colors.green.shade600,
                                      tooltip: 'Approve',
                                      onPressed: () => _showApprovalDialog(context, report, true),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      color: Colors.red.shade600,
                                      tooltip: 'Reject',
                                      onPressed: () {},
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Update _buildReportApprovalsMobileView with working filter chips:

  Widget _buildReportApprovalsMobileView(BuildContext context, List<ReportApprovalData> reports) {
    final provider = context.watch<JobProvider>();
    final stats = provider.getApprovalStats();

    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: ListView(
        children: [
          CommonTextField(
            controller: _searchController,
            hintText: 'Search reports...',
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                    : null,
          ),
          const SizedBox(height: 16),

          // Stats
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCompactStatsCard(
                  context,
                  stats['total'].toString(),
                  'Total',
                  Icons.description,
                  Colors.indigo,
                ),
                const SizedBox(width: 12),
                _buildCompactStatsCard(
                  context,
                  stats['pending'].toString(),
                  'Pending',
                  Icons.pending,
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildCompactStatsCard(
                  context,
                  stats['approved'].toString(),
                  'Approved',
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildCompactStatsCard(
                  context,
                  stats['rejected'].toString(),
                  'Rejected',
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ WORKING FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'All', provider.currentApprovalFilter == 'all', () {
                  provider.setApprovalFilter('all');
                  setState(() {});
                }),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Pending',
                  provider.currentApprovalFilter == 'pending',
                  () {
                    provider.setApprovalFilter('pending');
                    setState(() {});
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Approved',
                  provider.currentApprovalFilter == 'approved',
                  () {
                    provider.setApprovalFilter('approved');
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Report Cards
          ...reports.map((report) => _buildReportApprovalMobileCard(context, report)).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onTap(),
      selectedColor: Colors.indigo.withOpacity(0.2),
      checkmarkColor: Colors.indigo,
      labelStyle: context.topology.textTheme.bodySmall?.copyWith(
        color: isSelected ? Colors.indigo : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildReportApprovalMobileCard(BuildContext context, dynamic report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
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
                          'Report Name',
                          style: context.topology.textTheme.titleSmall?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Regulation Text',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildApprovalStatusBadge(context, 'draft'),
                      const SizedBox(height: 4),
                      _buildApprovalStatusBadge(context, 'pending'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMobileInfoItem(
                            context,
                            Icons.inventory_2,
                            'Item No',
                            'ITEM-001',
                          ),
                        ),
                        Expanded(
                          child: _buildMobileInfoItem(
                            context,
                            Icons.person,
                            'Inspector',
                            'Inspector Name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMobileInfoItem(
                            context,
                            Icons.calendar_today,
                            'Report Date',
                            '2025-10-02',
                          ),
                        ),
                        Expanded(
                          child: _buildMobileInfoItem(
                            context,
                            Icons.event_busy,
                            'Expiry',
                            '2025-11-19',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        side: BorderSide(color: Colors.blue.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.close),
                    color: Colors.red.shade600,
                    style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
