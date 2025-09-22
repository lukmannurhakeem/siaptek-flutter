import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:flutter/material.dart';

class ReportTypesDetails extends StatefulWidget {
  final String? reportTypeID;

  const ReportTypesDetails({super.key, this.reportTypeID});

  @override
  State<ReportTypesDetails> createState() => _ReportTypesDetailsState();
}

class _ReportTypesDetailsState extends State<ReportTypesDetails> with TickerProviderStateMixin {
  late TabController _tabController;
  ReportTypeData? reportData;
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

      // TODO: Replace with your actual API call
      final data = await _fetchReportTypeData(reportTypeID);

      setState(() {
        reportData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Mock API call - replace with your actual API service
  Future<ReportTypeData> _fetchReportTypeData(String reportTypeID) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // This is sample data based on your JSON structure
    // Replace this with your actual API call
    final sampleJson = {
      "reportType": {
        "reportTypeID": reportTypeID,
        "jobID": "25fc79f4-af06-43fa-a5af-b35532db36e1",
        "reportName": "Monthly Performance Report",
        "description": "Monthly performance evaluation report for employees",
        "documentCode": "MPR-001",
        "isExternalReport": false,
        "defaultAsDraft": true,
        "archived": false,
        "updateItemStatus": true,
        "updateItemDates": true,
        "batchReportType": "monthly",
        "isStatusRequired": true,
        "possibleStatus": "draft,pending,approved,rejected",
        "permission": "admin,manager",
        "categoryID": "01961ae9-24ec-4a70-af34-985d845d6adb",
        "fieldsID": "fields-001",
        "documentTemplate": "template-001",
        "labelTemplate": "label-001",
        "actionReportID": "action-001",
        "competencyID": "comp-001",
        "created_at": "2025-09-19T07:37:25.18362Z",
        "updated_at": "2025-09-19T07:37:25.18362Z",
      },
      "competencyReports": [
        {
          "competencyReportID": "2f7aed65-d89a-45d6-8cea-b0a9e9bc026f",
          "reportTypeID": reportTypeID,
          "internalExternal": "internal",
          "name": "Technical Skills Assessment",
          "canCreate": true,
          "created_at": "2025-09-19T07:37:25.18362Z",
          "updated_at": "2025-09-19T07:37:25.18362Z",
        },
      ],
      "reportTypeDates": [
        {
          "reportTypeDateID": "653c6c00-8cf1-400e-98f7-a4d681bd8044",
          "reportTypeID": reportTypeID,
          "name": "Start Date",
          "applyCycle": "monthly",
          "isRequired": true,
          "disableFreeType": false,
          "created_at": "2025-09-19T07:37:25.18362Z",
          "updated_at": "2025-09-19T07:37:25.18362Z",
        },
      ],
      "statusRuleReports": [
        {
          "statusRuleReportID": "0506d898-f4ce-4b36-b2f8-07180215eb37",
          "reportTypeID": reportTypeID,
          "status": "approved",
          "field": "score",
          "operator": ">=",
          "value": "80",
          "created_at": "2025-09-19T07:37:25.18362Z",
          "updated_at": "2025-09-19T07:37:25.18362Z",
        },
      ],
      "reportFields": [
        {
          "reportFieldID": "b2428429-1b72-4e58-9b21-5c7f698161a7",
          "reportTypeID": reportTypeID,
          "labelText": "Employee Name",
          "name": "employee_name",
          "fieldType": "text",
          "defaultValue": "",
          "section": "basic_info",
          "onlyAvailable": "all",
          "isRequired": true,
          "permissionField": "read,write",
          "doNotCopy": false,
          "infoText": "Enter the full name of the employee",
          "isArchive": false,
          "displayOrder": 1,
          "created_at": "2025-09-19T07:37:25.18362Z",
          "updated_at": "2025-09-19T07:37:25.18362Z",
        },
      ],
      "actionReports": [
        {
          "actionReportID": "a67af854-49e1-4521-96cf-8afad7764cc0",
          "reportTypeID": reportTypeID,
          "description": "Update employee status based on performance",
          "isArchive": false,
          "applyAction": "update_status",
          "match": "employee_id",
          "actionType": "status_update",
          "sourceTable": "performance_reports",
          "sourceField": "status",
          "destinationTable": "employees",
          "destinationField": "current_status",
          "created_at": "2025-09-19T07:37:25.18362Z",
          "updated_at": "2025-09-19T07:37:25.18362Z",
        },
      ],
    };

    return ReportTypeData.fromJson(sampleJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          reportData?.reportType.reportName ?? 'Report Type Details',
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading report data',
              style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.error),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CommonButton(text: 'Retry', onPressed: _loadReportTypeData),
          ],
        ),
      );
    }

    if (reportData == null) {
      return Center(
        child: Text(
          'No report data found',
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
      );
    }

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
    final reportType = reportData!.reportType;

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
                  _buildInfoRow('Report Name', reportType.reportName),
                  _buildInfoRow('Description', reportType.description),
                  _buildInfoRow('Document Code', reportType.documentCode),
                  _buildInfoRow('Report Type ID', reportType.reportTypeID),
                  _buildInfoRow('Job ID', reportType.jobID),
                  _buildInfoRow('Batch Type', reportType.batchReportType),
                  _buildInfoRow('External Report', reportType.isExternalReport ? 'Yes' : 'No'),
                  _buildInfoRow('Default as Draft', reportType.defaultAsDraft ? 'Yes' : 'No'),
                  _buildInfoRow('Status Required', reportType.isStatusRequired ? 'Yes' : 'No'),
                  _buildInfoRow('Update Item Status', reportType.updateItemStatus ? 'Yes' : 'No'),
                  _buildInfoRow('Update Item Dates', reportType.updateItemDates ? 'Yes' : 'No'),
                  _buildInfoRow('Archived', reportType.archived ? 'Yes' : 'No'),
                  _buildInfoRow('Created', reportType.createdAt.formatShortDate),
                  _buildInfoRow('Updated', reportType.updatedAt.formatShortDate),
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
                  reportData!.reportFields.length.toString(),
                  Icons.list_alt,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Status Rules',
                  reportData!.statusRuleReports.length.toString(),
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
                  reportData!.actionReports.length.toString(),
                  Icons.settings,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Competencies',
                  reportData!.competencyReports.length.toString(),
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
    final fields = reportData!.reportFields;

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
                        field.labelText,
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getFieldTypeColor(field.fieldType),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        field.fieldType,
                        style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Field Name', field.name),
                _buildInfoRow('Section', field.section),
                _buildInfoRow('Available To', field.onlyAvailable),
                _buildInfoRow('Permissions', field.permissionFieldList.join(', ')),
                _buildInfoRow('Required', field.isRequired ? 'Yes' : 'No'),
                _buildInfoRow('Display Order', field.displayOrder.toString()),
                if (field.infoText.isNotEmpty) _buildInfoRow('Info Text', field.infoText),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusRulesTab() {
    final statusRules = reportData!.statusRuleReports;

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
                        color: _getStatusColor(rule.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        rule.status.toUpperCase(),
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
                  'Rule: ${rule.field} ${rule.operator} ${rule.value}',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Field', rule.field),
                _buildInfoRow('Operator', rule.operator),
                _buildInfoRow('Value', rule.value),
                _buildInfoRow('Created', rule.createdAt.formatShortDate),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDatesTab() {
    final dates = reportData!.reportTypeDates;

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
                  date.name,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Apply Cycle', date.applyCycle),
                _buildInfoRow('Required', date.isRequired ? 'Yes' : 'No'),
                _buildInfoRow('Disable Free Type', date.disableFreeType ? 'Yes' : 'No'),
                _buildInfoRow('Created', date.createdAt.formatShortDate),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentTemplateTab() {
    final reportType = reportData!.reportType;

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
              _buildInfoRow('Template ID', reportType.documentTemplate),
              _buildInfoRow('Report Name', reportType.reportName),
              _buildInfoRow('Document Code', reportType.documentCode),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Edit Template',
                      onPressed: () {
                        // TODO: Navigate to template editor
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
                        // TODO: Preview template
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
    final reportType = reportData!.reportType;

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
              _buildInfoRow('Template ID', reportType.labelTemplate),
              _buildInfoRow('Report Name', reportType.reportName),
              _buildInfoRow('Document Code', reportType.documentCode),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: 'Edit Label Template',
                      onPressed: () {
                        // TODO: Navigate to label template editor
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
                        // TODO: Preview label template
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
    final actions = reportData!.actionReports;

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
                        action.description,
                        style: context.topology.textTheme.titleSmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: action.isArchive ? Colors.grey : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        action.isArchive ? 'Archived' : 'Active',
                        style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Action Type', action.actionType),
                _buildInfoRow('Apply Action', action.applyAction),
                _buildInfoRow('Match Field', action.match),
                const SizedBox(height: 8),
                Text(
                  'Source Configuration',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Table', action.sourceTable),
                _buildInfoRow('Field', action.sourceField),
                const SizedBox(height: 8),
                Text(
                  'Destination Configuration',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Table', action.destinationTable),
                _buildInfoRow('Field', action.destinationField),
                const SizedBox(height: 8),
                _buildInfoRow('Created', action.createdAt.formatShortDate),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompetencyTab() {
    final competencies = reportData!.competencyReports;

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
                        competency.name,
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
                        competency.internalExternal.toUpperCase(),
                        style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Can Create', competency.canCreate ? 'Yes' : 'No'),
                _buildInfoRow('Competency ID', competency.competencyReportID),
                _buildInfoRow('Created', competency.createdAt.formatShortDate),
                _buildInfoRow('Updated', competency.updatedAt.formatShortDate),
                if (competency.canCreate) ...[
                  const SizedBox(height: 12),
                  CommonButton(
                    text: 'Create Assessment',
                    onPressed: () {
                      // TODO: Navigate to competency assessment creation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Create ${competency.name} assessment')),
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

class ReportTypeData {
  final ReportType reportType;
  final List<CompetencyReport> competencyReports;
  final List<ReportTypeDate> reportTypeDates;
  final List<StatusRuleReport> statusRuleReports;
  final List<ReportField> reportFields;
  final List<ActionReport> actionReports;

  ReportTypeData({
    required this.reportType,
    required this.competencyReports,
    required this.reportTypeDates,
    required this.statusRuleReports,
    required this.reportFields,
    required this.actionReports,
  });

  factory ReportTypeData.fromJson(Map<String, dynamic> json) {
    return ReportTypeData(
      reportType: ReportType.fromJson(json['reportType']),
      competencyReports:
          (json['competencyReports'] as List<dynamic>?)
              ?.map((e) => CompetencyReport.fromJson(e))
              .toList() ??
          [],
      reportTypeDates:
          (json['reportTypeDates'] as List<dynamic>?)
              ?.map((e) => ReportTypeDate.fromJson(e))
              .toList() ??
          [],
      statusRuleReports:
          (json['statusRuleReports'] as List<dynamic>?)
              ?.map((e) => StatusRuleReport.fromJson(e))
              .toList() ??
          [],
      reportFields:
          (json['reportFields'] as List<dynamic>?)?.map((e) => ReportField.fromJson(e)).toList() ??
          [],
      actionReports:
          (json['actionReports'] as List<dynamic>?)
              ?.map((e) => ActionReport.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReportType {
  final String reportTypeID;
  final String jobID;
  final String reportName;
  final String description;
  final String documentCode;
  final bool isExternalReport;
  final bool defaultAsDraft;
  final bool archived;
  final bool updateItemStatus;
  final bool updateItemDates;
  final String batchReportType;
  final bool isStatusRequired;
  final String possibleStatus;
  final String permission;
  final String categoryID;
  final String fieldsID;
  final String documentTemplate;
  final String labelTemplate;
  final String actionReportID;
  final String competencyID;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportType({
    required this.reportTypeID,
    required this.jobID,
    required this.reportName,
    required this.description,
    required this.documentCode,
    required this.isExternalReport,
    required this.defaultAsDraft,
    required this.archived,
    required this.updateItemStatus,
    required this.updateItemDates,
    required this.batchReportType,
    required this.isStatusRequired,
    required this.possibleStatus,
    required this.permission,
    required this.categoryID,
    required this.fieldsID,
    required this.documentTemplate,
    required this.labelTemplate,
    required this.actionReportID,
    required this.competencyID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportType.fromJson(Map<String, dynamic> json) {
    return ReportType(
      reportTypeID: json['reportTypeID'],
      jobID: json['jobID'],
      reportName: json['reportName'],
      description: json['description'],
      documentCode: json['documentCode'],
      isExternalReport: json['isExternalReport'],
      defaultAsDraft: json['defaultAsDraft'],
      archived: json['archived'],
      updateItemStatus: json['updateItemStatus'],
      updateItemDates: json['updateItemDates'],
      batchReportType: json['batchReportType'],
      isStatusRequired: json['isStatusRequired'],
      possibleStatus: json['possibleStatus'],
      permission: json['permission'],
      categoryID: json['categoryID'],
      fieldsID: json['fieldsID'],
      documentTemplate: json['documentTemplate'],
      labelTemplate: json['labelTemplate'],
      actionReportID: json['actionReportID'],
      competencyID: json['competencyID'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  List<String> get possibleStatusList => possibleStatus.split(',').map((s) => s.trim()).toList();

  List<String> get permissionList => permission.split(',').map((s) => s.trim()).toList();
}

class CompetencyReport {
  final String competencyReportID;
  final String reportTypeID;
  final String internalExternal;
  final String name;
  final bool canCreate;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompetencyReport({
    required this.competencyReportID,
    required this.reportTypeID,
    required this.internalExternal,
    required this.name,
    required this.canCreate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompetencyReport.fromJson(Map<String, dynamic> json) {
    return CompetencyReport(
      competencyReportID: json['competencyReportID'],
      reportTypeID: json['reportTypeID'],
      internalExternal: json['internalExternal'],
      name: json['name'],
      canCreate: json['canCreate'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ReportTypeDate {
  final String reportTypeDateID;
  final String reportTypeID;
  final String name;
  final String applyCycle;
  final bool isRequired;
  final bool disableFreeType;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportTypeDate({
    required this.reportTypeDateID,
    required this.reportTypeID,
    required this.name,
    required this.applyCycle,
    required this.isRequired,
    required this.disableFreeType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportTypeDate.fromJson(Map<String, dynamic> json) {
    return ReportTypeDate(
      reportTypeDateID: json['reportTypeDateID'],
      reportTypeID: json['reportTypeID'],
      name: json['name'],
      applyCycle: json['applyCycle'],
      isRequired: json['isRequired'],
      disableFreeType: json['disableFreeType'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class StatusRuleReport {
  final String statusRuleReportID;
  final String reportTypeID;
  final String status;
  final String field;
  final String operator;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  StatusRuleReport({
    required this.statusRuleReportID,
    required this.reportTypeID,
    required this.status,
    required this.field,
    required this.operator,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StatusRuleReport.fromJson(Map<String, dynamic> json) {
    return StatusRuleReport(
      statusRuleReportID: json['statusRuleReportID'],
      reportTypeID: json['reportTypeID'],
      status: json['status'],
      field: json['field'],
      operator: json['operator'],
      value: json['value'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ReportField {
  final String reportFieldID;
  final String reportTypeID;
  final String labelText;
  final String name;
  final String fieldType;
  final dynamic defaultValue;
  final String section;
  final String onlyAvailable;
  final bool isRequired;
  final String permissionField;
  final bool doNotCopy;
  final String infoText;
  final bool isArchive;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportField({
    required this.reportFieldID,
    required this.reportTypeID,
    required this.labelText,
    required this.name,
    required this.fieldType,
    required this.defaultValue,
    required this.section,
    required this.onlyAvailable,
    required this.isRequired,
    required this.permissionField,
    required this.doNotCopy,
    required this.infoText,
    required this.isArchive,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportField.fromJson(Map<String, dynamic> json) {
    return ReportField(
      reportFieldID: json['reportFieldID'],
      reportTypeID: json['reportTypeID'],
      labelText: json['labelText'],
      name: json['name'],
      fieldType: json['fieldType'],
      defaultValue: json['defaultValue'],
      section: json['section'],
      onlyAvailable: json['onlyAvailable'],
      isRequired: json['isRequired'],
      permissionField: json['permissionField'],
      doNotCopy: json['doNotCopy'],
      infoText: json['infoText'],
      isArchive: json['isArchive'],
      displayOrder: json['displayOrder'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  List<String> get permissionFieldList => permissionField.split(',').map((s) => s.trim()).toList();
}

class ActionReport {
  final String actionReportID;
  final String reportTypeID;
  final String description;
  final bool isArchive;
  final String applyAction;
  final String match;
  final String actionType;
  final String sourceTable;
  final String sourceField;
  final String destinationTable;
  final String destinationField;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActionReport({
    required this.actionReportID,
    required this.reportTypeID,
    required this.description,
    required this.isArchive,
    required this.applyAction,
    required this.match,
    required this.actionType,
    required this.sourceTable,
    required this.sourceField,
    required this.destinationTable,
    required this.destinationField,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActionReport.fromJson(Map<String, dynamic> json) {
    return ActionReport(
      actionReportID: json['actionReportID'],
      reportTypeID: json['reportTypeID'],
      description: json['description'],
      isArchive: json['isArchive'],
      applyAction: json['applyAction'],
      match: json['match'],
      actionType: json['actionType'],
      sourceTable: json['sourceTable'],
      sourceField: json['sourceField'],
      destinationTable: json['destinationTable'],
      destinationField: json['destinationField'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
