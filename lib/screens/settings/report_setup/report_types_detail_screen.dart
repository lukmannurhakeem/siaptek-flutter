import 'package:INSPECT/core/extension/date_time_extension.dart';
import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/get_report_type_model.dart';
import 'package:INSPECT/providers/system_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportTypesDetails extends StatefulWidget {
  final String? reportTypeID;

  const ReportTypesDetails({super.key, this.reportTypeID});

  @override
  State<ReportTypesDetails> createState() => _ReportTypesDetailsState();
}

class _ReportTypesDetailsState extends State<ReportTypesDetails> with TickerProviderStateMixin {
  late TabController _tabController;
  Datum? reportData;
  bool isLoading = true;
  String? errorMessage;
  TextEditingController searchController = TextEditingController();

  final List<Tab> tabs = const [
    Tab(text: 'Overview'),
    Tab(text: 'Fields'),
    Tab(text: 'Status Rules'),
    Tab(text: 'Dates'),
    Tab(text: 'Document Template'),
    Tab(text: 'Label Template'),
    Tab(text: 'Actions'),
    Tab(text: 'Competency'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _loadReportTypeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReportTypeData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Get reportTypeID from navigation arguments or widget parameter
      final args = ModalRoute.of(context)?.settings.arguments;
      String? reportTypeID = widget.reportTypeID;

      if (args is Map<String, dynamic> && args.containsKey('reportTypeID')) {
        reportTypeID = args['reportTypeID'] as String;
      } else if (args is String) {
        reportTypeID = args;
      }

      if (reportTypeID == null) {
        throw Exception('Report Type ID not provided');
      }

      // Get the provider and fetch data if not available
      final provider = Provider.of<SystemProvider>(context, listen: false);

      if (!provider.hasReport) {
        await provider.fetchReportType();
      }

      // Find the specific report data by ID
      final foundReport = _findReportById(provider.getReportTypeModel, reportTypeID);

      if (foundReport == null) {
        throw Exception('Report not found with ID: $reportTypeID');
      }

      setState(() {
        reportData = foundReport;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Helper method to find report by ID
  Datum? _findReportById(GetReportTypeModel? model, String reportTypeID) {
    if (model?.data == null) return null;

    try {
      return model!.data!.firstWhere(
        (datum) =>
            datum.reportType?.reportTypeId == reportTypeID ||
            datum.reportType?.categoryId == reportTypeID ||
            datum.reportType?.jobId == reportTypeID,
      );
    } catch (e) {
      // If no exact match found, return the first item for demo purposes
      // or create mock data based on the ID
      return model!.data!.isNotEmpty ? model.data!.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          reportData?.reportType?.reportName ?? 'Report Type Details',
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
      body: Consumer<SystemProvider>(
        builder: (context, provider, child) {
          // Handle loading state
          if (isLoading || (provider.isLoading && reportData == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (errorMessage != null || provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: context.colors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading report data',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage ?? provider.errorMessage ?? 'Unknown error',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CommonButton(text: 'Retry', onPressed: _loadReportTypeData),
                ],
              ),
            );
          }

          // Handle empty state
          if (reportData == null) {
            return Center(
              child: Text(
                'No report data found',
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            );
          }

          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          // Tab bar
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
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildFieldsTab(),
                _buildStatusRulesTab(),
                _buildDatesTab(),
                _buildDocumentTemplateTab(),
                _buildLabelTemplateTab(),
                _buildActionsTab(),
                _buildCompetencyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final reportType = reportData!.reportType!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Type Information',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Report Name', reportType.reportName ?? 'N/A'),
                  _buildInfoRow('Description', reportType.description ?? 'N/A'),
                  _buildInfoRow('Document Code', reportType.documentCode ?? 'N/A'),
                  _buildInfoRow('Report Type ID', reportType.reportTypeId ?? 'N/A'),
                  _buildInfoRow('Job ID', reportType.jobId ?? 'N/A'),
                  _buildInfoRow('Batch Type', reportType.batchReportType ?? 'N/A'),
                  _buildInfoRow(
                    'External Report',
                    reportType.isExternalReport == true ? 'Yes' : 'No',
                  ),
                  _buildInfoRow(
                    'Default as Draft',
                    reportType.defaultAsDraft == true ? 'Yes' : 'No',
                  ),
                  _buildInfoRow(
                    'Status Required',
                    reportType.isStatusRequired == true ? 'Yes' : 'No',
                  ),
                  _buildInfoRow(
                    'Update Item Status',
                    reportType.updateItemStatus == true ? 'Yes' : 'No',
                  ),
                  _buildInfoRow(
                    'Update Item Dates',
                    reportType.updateItemDates == true ? 'Yes' : 'No',
                  ),
                  _buildInfoRow('Archived', reportType.archived == true ? 'Yes' : 'No'),
                  _buildInfoRow('Created', reportType.createdAt?.formatShortDate ?? 'N/A'),
                  _buildInfoRow('Updated', reportType.updatedAt?.formatShortDate ?? 'N/A'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Fields',
                  (reportData!.reportFields?.length ?? 0).toString(),
                  Icons.list_alt,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Status Rules',
                  (reportData!.statusRuleReports?.length ?? 0).toString(),
                  Icons.rule,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Actions',
                  (reportData!.actionReports?.length ?? 0).toString(),
                  Icons.settings,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Competencies',
                  (reportData!.competencyReports?.length ?? 0).toString(),
                  Icons.psychology,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsTab() {
    final fields = reportData!.reportFields ?? [];

    if (fields.isEmpty) {
      return _buildEmptyState('No fields found', Icons.list_alt);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        field.labelText ?? 'N/A',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getFieldTypeColor(field.fieldType ?? 'text'),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        field.fieldType ?? 'text',
                        style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Field Name', field.name ?? 'N/A'),
                _buildInfoRow('Section', field.section ?? 'N/A'),
                _buildInfoRow('Available To', field.onlyAvailable ?? 'N/A'),
                _buildInfoRow('Permissions', field.permissionField ?? 'N/A'),
                _buildInfoRow('Required', field.isRequired == true ? 'Yes' : 'No'),

                if (field.infoText?.isNotEmpty == true) _buildInfoRow('Info Text', field.infoText!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRulesTab() {
    final statusRules = reportData!.statusRuleReports ?? [];

    if (statusRules.isEmpty) {
      return _buildEmptyState('No status rules found', Icons.rule);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: statusRules.length,
      itemBuilder: (context, index) {
        final rule = statusRules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(rule.status ?? 'draft'),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (rule.status ?? 'draft').toUpperCase(),
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rule: ${rule.field ?? 'N/A'} ${rule.statusRuleReportOperator ?? '=='} ${rule.value ?? 'N/A'}',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Field', rule.field ?? 'N/A'),
                _buildInfoRow('Operator', rule.statusRuleReportOperator ?? 'N/A'),
                _buildInfoRow('Value', rule.value ?? 'N/A'),
                _buildInfoRow('Created', rule.createdAt?.formatShortDate ?? 'N/A'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatesTab() {
    final dates = reportData!.reportTypeDates ?? [];

    if (dates.isEmpty) {
      return _buildEmptyState('No date configurations found', Icons.date_range);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.name ?? 'N/A',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Apply Cycle', date.applyCycle ?? 'N/A'),
                _buildInfoRow('Required', date.isRequired == true ? 'Yes' : 'No'),
                _buildInfoRow('Disable Free Type', date.disableFreeType == true ? 'Yes' : 'No'),
                _buildInfoRow('Created', date.createdAt?.formatShortDate ?? 'N/A'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentTemplateTab() {
    final reportType = reportData!.reportType!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Document Template Configuration',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Template ID', reportType.documentTemplate ?? 'N/A'),
              _buildInfoRow('Report Name', reportType.reportName ?? 'N/A'),
              _buildInfoRow('Document Code', reportType.documentCode ?? 'N/A'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Edit Template',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Template editor not implemented')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Preview',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Template preview not implemented')),
                        );
                      },
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

  Widget _buildLabelTemplateTab() {
    final reportType = reportData!.reportType!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Label Template Configuration',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Template ID', reportType.labelTemplate ?? 'N/A'),
              _buildInfoRow('Report Name', reportType.reportName ?? 'N/A'),
              _buildInfoRow('Document Code', reportType.documentCode ?? 'N/A'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Edit Label Template',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Label template editor not implemented')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonButton(
                      text: 'Preview Label',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Label template preview not implemented')),
                        );
                      },
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

  Widget _buildActionsTab() {
    final actions = reportData!.actionReports ?? [];

    if (actions.isEmpty) {
      return _buildEmptyState('No actions found', Icons.settings);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        action.description ?? 'N/A',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: action.isArchive == true ? Colors.grey : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        action.isArchive == true ? 'Archived' : 'Active',
                        style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Action Type', action.actionType ?? 'N/A'),
                _buildInfoRow('Apply Action', action.applyAction ?? 'N/A'),
                _buildInfoRow('Match Field', action.match ?? 'N/A'),
                const SizedBox(height: 8),
                Text(
                  'Source Configuration',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Table', action.sourceTable ?? 'N/A'),
                _buildInfoRow('Field', action.sourceField ?? 'N/A'),
                const SizedBox(height: 8),
                Text(
                  'Destination Configuration',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Table', action.destinationTable ?? 'N/A'),
                _buildInfoRow('Field', action.destinationField ?? 'N/A'),
                const SizedBox(height: 8),
                _buildInfoRow('Created', action.createdAt?.formatShortDate ?? 'N/A'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompetencyTab() {
    final competencies = reportData!.competencyReports ?? [];

    if (competencies.isEmpty) {
      return _buildEmptyState('No competency reports found', Icons.psychology);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: competencies.length,
      itemBuilder: (context, index) {
        final competency = competencies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        competency.name ?? 'N/A',
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            competency.internalExternal == 'internal' ? Colors.blue : Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (competency.internalExternal ?? 'internal').toUpperCase(),
                        style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Can Create', competency.canCreate == true ? 'Yes' : 'No'),
                _buildInfoRow('Competency ID', competency.competencyReportId ?? 'N/A'),
                _buildInfoRow('Created', competency.createdAt?.formatShortDate ?? 'N/A'),
                _buildInfoRow('Updated', competency.updatedAt?.formatShortDate ?? 'N/A'),
                if (competency.canCreate == true) ...[
                  const SizedBox(height: 12),
                  CommonButton(
                    text: 'Create Assessment',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Create ${competency.name ?? 'assessment'} assessment'),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: context.colors.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: context.topology.textTheme.bodyMedium?.copyWith(
              color: context.colors.primary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: context.topology.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Icon(icon, color: context.colors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.topology.textTheme.titleLarge?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: context.colors.primary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getFieldTypeColor(String fieldType) {
    switch (fieldType.toLowerCase()) {
      case 'text':
        return Colors.blue;
      case 'decimal':
      case 'number':
        return Colors.green;
      case 'date':
        return Colors.orange;
      case 'boolean':
        return Colors.purple;
      case 'select':
      case 'dropdown':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        return Colors.green;
      case 'pending':
      case 'draft':
        return Colors.orange;
      case 'rejected':
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
