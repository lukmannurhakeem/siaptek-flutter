import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportCreateScreen extends StatefulWidget {
  const ReportCreateScreen({super.key});

  @override
  State<ReportCreateScreen> createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  int _currentStep = 0;
  bool _isEditMode = false;
  dynamic _editReportData;
  int? _editReportIndex;

  final List<String> _steps = [
    'Overview',
    'Fields',
    'Status Rules',
    'Dates',
    'Actions',
    'Competency',
  ];

  // Form controllers for Overview step
  final TextEditingController _reportNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _documentCodeController = TextEditingController();
  final TextEditingController _batchReportTypeController = TextEditingController();
  final TextEditingController _possibleStatusController = TextEditingController();
  final TextEditingController _permissionController = TextEditingController();
  final TextEditingController _categoryIDController = TextEditingController();
  final TextEditingController _fieldsIDController = TextEditingController();
  final TextEditingController _documentTemplateController = TextEditingController();
  final TextEditingController _labelTemplateController = TextEditingController();
  final TextEditingController _actionReportIDController = TextEditingController();
  final TextEditingController _competencyIDController = TextEditingController();

  // Boolean values for checkboxes
  bool _isExternalReport = false;
  bool _defaultAsDraft = true;
  bool _archived = false;
  bool _updateItemStatus = true;
  bool _updateItemDates = true;
  bool _isStatusRequired = true;

  // Lists to store dynamic data
  List<Map<String, dynamic>>? _reportFields = [];
  List<Map<String, dynamic>>? _statusRuleReports = [];
  List<Map<String, dynamic>>? _reportTypeDates = [];
  List<Map<String, dynamic>>? _actionReports = [];
  List<Map<String, dynamic>>? _competencyReports = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEditMode();
    });
  }

  void _checkEditMode() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _isEditMode = args['isEdit'] ?? false;
      _editReportData = args['reportData'];
      _editReportIndex = args['reportIndex'];

      if (_isEditMode && _editReportData != null) {
        _populateFormFields();
      }
    }
  }

  void _populateFormFields() async {
    if (_editReportData?.categoryId != null) {
      final provider = Provider.of<SystemProvider>(context, listen: false);
      final detailedData = await provider.getReportDetails(_editReportData!.categoryId);

      if (detailedData != null) {
        _reportNameController.text =
            detailedData['reportType']?['reportName'] ?? _editReportData?.reportName ?? '';
        _descriptionController.text =
            detailedData['reportType']?['description'] ?? _editReportData?.description ?? '';
        _documentCodeController.text =
            detailedData['reportType']?['documentCode'] ?? _editReportData?.documentCode ?? '';
        _batchReportTypeController.text = detailedData['reportType']?['batchReportType'] ?? '';
        _possibleStatusController.text = detailedData['reportType']?['possibleStatus'] ?? '';
        _permissionController.text = detailedData['reportType']?['permission'] ?? '';
        _categoryIDController.text =
            detailedData['reportType']?['categoryID'] ?? _editReportData?.categoryId ?? '';
        _fieldsIDController.text = detailedData['reportType']?['fieldsID'] ?? '';
        _documentTemplateController.text = detailedData['reportType']?['documentTemplate'] ?? '';
        _labelTemplateController.text = detailedData['reportType']?['labelTemplate'] ?? '';
        _actionReportIDController.text = detailedData['reportType']?['actionReportID'] ?? '';
        _competencyIDController.text =
            detailedData['reportType']?['competencyID'] ?? _editReportData?.competencyId ?? '';

        _isExternalReport = detailedData['reportType']?['isExternalReport'] ?? false;
        _defaultAsDraft = detailedData['reportType']?['defaultAsDraft'] ?? true;
        _archived = detailedData['reportType']?['archived'] ?? _editReportData?.archived ?? false;
        _updateItemStatus = detailedData['reportType']?['updateItemStatus'] ?? true;
        _updateItemDates = detailedData['reportType']?['updateItemDates'] ?? true;
        _isStatusRequired = detailedData['reportType']?['isStatusRequired'] ?? true;

        // Populate reportFields with proper structure
        if (detailedData['reportFields'] != null) {
          _reportFields = List<Map<String, dynamic>>.from(
            detailedData['reportFields'].map((field) {
              final fieldMap = Map<String, dynamic>.from(field);
              // Ensure defaultValue is a string
              if (fieldMap['defaultValue'] != null) {
                if (fieldMap['defaultValue'] is List) {
                  fieldMap['defaultValue'] = '';
                } else if (fieldMap['defaultValue'] is Map) {
                  fieldMap['defaultValue'] = fieldMap['defaultValue']['value']?.toString() ?? '';
                } else {
                  fieldMap['defaultValue'] = fieldMap['defaultValue'].toString();
                }
              }
              return fieldMap;
            }),
          );
        }

        if (detailedData['statusRuleReports'] != null) {
          _statusRuleReports = List<Map<String, dynamic>>.from(
            detailedData['statusRuleReports'].map((rule) => Map<String, dynamic>.from(rule)),
          );
        }

        if (detailedData['reportTypeDates'] != null) {
          _reportTypeDates = List<Map<String, dynamic>>.from(
            detailedData['reportTypeDates'].map((date) => Map<String, dynamic>.from(date)),
          );
        }

        if (detailedData['actionReports'] != null) {
          _actionReports = List<Map<String, dynamic>>.from(
            detailedData['actionReports'].map((action) => Map<String, dynamic>.from(action)),
          );
        }

        if (detailedData['competencyReports'] != null) {
          _competencyReports = List<Map<String, dynamic>>.from(
            detailedData['competencyReports'].map(
              (competency) => Map<String, dynamic>.from(competency),
            ),
          );
        }
      } else {
        _reportNameController.text = _editReportData?.reportName ?? '';
        _descriptionController.text = _editReportData?.description ?? '';
        _documentCodeController.text = _editReportData?.documentCode ?? '';
        _categoryIDController.text = _editReportData?.categoryId ?? '';
        _competencyIDController.text = _editReportData?.competencyId ?? '';
        _archived = _editReportData?.archived ?? false;
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _reportNameController.dispose();
    _descriptionController.dispose();
    _documentCodeController.dispose();
    _batchReportTypeController.dispose();
    _possibleStatusController.dispose();
    _permissionController.dispose();
    _categoryIDController.dispose();
    _fieldsIDController.dispose();
    _documentTemplateController.dispose();
    _labelTemplateController.dispose();
    _actionReportIDController.dispose();
    _competencyIDController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Report Template' : 'Create Report Template',
          style: context.topology.textTheme.titleLarge?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: Container(
        padding: context.paddingAll,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _steps.asMap().entries.map((entry) {
                      int index = entry.key;
                      String label = entry.value;
                      bool isActive = _currentStep == index;
                      bool isCompleted = index < _currentStep;

                      return Row(
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    isCompleted
                                        ? context.colors.primary
                                        : (isActive ? context.colors.secondary : Colors.grey),
                                child: Text(
                                  '${index + 1}',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              context.vS,
                              Text(
                                label,
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (index != _steps.length - 1)
                            Container(
                              width: 40,
                              height: 2,
                              color:
                                  index < _currentStep
                                      ? context.colors.primary
                                      : context.colors.secondary,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                            ),
                        ],
                      );
                    }).toList(),
              ),
            ),
            context.vL,
            Expanded(child: _getStepContent(_currentStep)),
            _buildNavigationButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: context.screenWidth / 2.5,
          child: CommonButton(
            onPressed: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
            text: 'Back',
          ),
        ),
        context.hM,
        SizedBox(
          width: context.screenWidth / 2.5,
          child: Consumer<SystemProvider>(
            builder: (context, provider, child) {
              return CommonButton(
                onPressed:
                    _currentStep < _steps.length - 1
                        ? () => setState(() => _currentStep++)
                        : provider.isLoading
                        ? null
                        : _submitReport,
                text:
                    _currentStep < _steps.length - 1
                        ? 'Next'
                        : provider.isLoading
                        ? (_isEditMode ? 'Updating...' : 'Creating...')
                        : (_isEditMode ? 'Update Report' : 'Create Report'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getStepContent(int step) {
    switch (step) {
      case 0:
        return _buildOverviewStep();
      case 1:
        return _buildFieldsStep();
      case 2:
        return _buildStatusRulesStep();
      case 3:
        return _buildDatesStep();
      case 4:
        return _buildActionsStep();
      case 5:
        return _buildCompetencyStep();
      default:
        return Text('Unknown Step', style: TextStyle(fontSize: 18));
    }
  }

  Widget _buildOverviewStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Details',
            style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
          ),
          context.divider,
          context.vS,
          _buildTextField('Report Name', _reportNameController),
          context.vS,
          _buildTextField('Description', _descriptionController),
          context.vS,
          _buildTextField('Document Code', _documentCodeController),
          context.vS,
          _buildCheckboxField('External Report', _isExternalReport, (value) {
            setState(() => _isExternalReport = value ?? false);
          }),
          context.vS,
          _buildCheckboxField('Default as Draft', _defaultAsDraft, (value) {
            setState(() => _defaultAsDraft = value ?? true);
          }),
          context.vS,
          _buildCheckboxField('Archived', _archived, (value) {
            setState(() => _archived = value ?? false);
          }),
          context.vM,
          Text(
            'Settings',
            style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
          ),
          context.divider,
          context.vS,
          _buildCheckboxField('Update Item Status', _updateItemStatus, (value) {
            setState(() => _updateItemStatus = value ?? true);
          }),
          context.vS,
          _buildCheckboxField('Update Item Dates', _updateItemDates, (value) {
            setState(() => _updateItemDates = value ?? true);
          }),
          context.vS,
          _buildTextField('Batch Report Type', _batchReportTypeController),
          context.vM,
          Text(
            'Status Configuration',
            style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
          ),
          context.divider,
          context.vS,
          _buildCheckboxField('Status Is Required', _isStatusRequired, (value) {
            setState(() => _isStatusRequired = value ?? true);
          }),
          context.vS,
          _buildTextField('Possible Statuses (comma separated)', _possibleStatusController),
          context.vM,
          Text(
            'Permissions & Associations',
            style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
          ),
          context.divider,
          context.vS,
          _buildTextField('Permissions (comma separated)', _permissionController),
          context.vS,
          _buildTextField('Category ID', _categoryIDController),
          context.vS,
          _buildTextField('Fields ID', _fieldsIDController),
          context.vS,
          _buildTextField('Document Template', _documentTemplateController),
          context.vS,
          _buildTextField('Label Template', _labelTemplateController),
          context.vS,
          _buildTextField('Action Report ID', _actionReportIDController),
          context.vS,
          _buildTextField('Competency ID', _competencyIDController),
        ],
      ),
    );
  }

  Widget _buildFieldsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Report Fields',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            IconButton(
              onPressed: _addReportField,
              icon: Icon(Icons.add_circle, color: context.colors.primary),
            ),
          ],
        ),
        context.divider,
        context.vS,
        Expanded(
          child: ListView.builder(
            itemCount: _reportFields?.length ?? 0,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Field ${index + 1}',
                              style: context.topology.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeReportField(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                      context.vS,
                      _buildFieldTextField('Label Text', index, 'labelText'),
                      context.vS,
                      _buildFieldTextField('Field Name', index, 'name'),
                      context.vS,
                      _buildFieldDropdown('Field Type', index, 'fieldType', [
                        'text',
                        'number',
                        'decimal',
                        'date',
                        'checkbox',
                        'dropdown',
                        'textarea',
                      ]),
                      context.vS,
                      _buildFieldTextField('Default Value', index, 'defaultValue'),
                      context.vS,
                      _buildFieldTextField('Section', index, 'section'),
                      context.vS,
                      _buildFieldDropdown('Only Available', index, 'onlyAvailable', [
                        'all',
                        'admin',
                        'manager',
                        'user',
                      ]),
                      context.vS,
                      _buildFieldTextField('Permission Field', index, 'permissionField'),
                      context.vS,
                      _buildFieldTextField('Info Text', index, 'infoText'),
                      context.vS,
                      _buildFieldCheckbox('Is Required', index, 'isRequired'),
                      context.vS,
                      _buildFieldCheckbox('Do Not Copy', index, 'doNotCopy'),
                      context.vS,
                      _buildFieldCheckbox('Is Archive', index, 'isArchive'),
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

  Widget _buildStatusRulesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Status Rules',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            IconButton(
              onPressed: _addStatusRule,
              icon: Icon(Icons.add_circle, color: context.colors.primary),
            ),
          ],
        ),
        context.divider,
        context.vS,
        Expanded(
          child: ListView.builder(
            itemCount: _statusRuleReports?.length ?? 0,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Status Rule ${index + 1}',
                              style: context.topology.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeStatusRule(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                      context.vS,
                      _buildStatusRuleDropdown('Status', index, 'status', [
                        'draft',
                        'pending',
                        'approved',
                        'rejected',
                        'in_progress',
                        'completed',
                      ]),
                      context.vS,
                      _buildStatusRuleTextField('Field', index, 'field'),
                      context.vS,
                      _buildStatusRuleDropdown('Operator', index, 'operator', [
                        '==',
                        '!=',
                        '>',
                        '<',
                        '>=',
                        '<=',
                        'contains',
                        'not_contains',
                      ]),
                      context.vS,
                      _buildStatusRuleTextField('Value', index, 'value'),
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

  Widget _buildDatesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Report Type Dates',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            IconButton(
              onPressed: _addReportTypeDate,
              icon: Icon(Icons.add_circle, color: context.colors.primary),
            ),
          ],
        ),
        context.divider,
        context.vS,
        Expanded(
          child: ListView.builder(
            itemCount: _reportTypeDates?.length ?? 0,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Date Configuration ${index + 1}',
                              style: context.topology.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeReportTypeDate(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                      context.vS,
                      _buildDateTextField('Date Name', index, 'name'),
                      context.vS,
                      _buildDateDropdown('Apply Cycle', index, 'applyCycle', [
                        'daily',
                        'weekly',
                        'monthly',
                        'quarterly',
                        'yearly',
                        'custom',
                      ]),
                      context.vS,
                      _buildDateCheckbox('Is Required', index, 'isRequired'),
                      context.vS,
                      _buildDateCheckbox('Disable Free Type', index, 'disableFreeType'),
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

  Widget _buildActionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Action Reports',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            IconButton(
              onPressed: _addActionReport,
              icon: Icon(Icons.add_circle, color: context.colors.primary),
            ),
          ],
        ),
        context.divider,
        context.vS,
        Expanded(
          child: ListView.builder(
            itemCount: _actionReports?.length ?? 0,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Action Report ${index + 1}',
                              style: context.topology.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeActionReport(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                      context.vS,
                      _buildActionTextField('Description', index, 'description'),
                      context.vS,
                      _buildActionTextField('Apply Action', index, 'applyAction'),
                      context.vS,
                      _buildActionTextField('Match Field', index, 'match'),
                      context.vS,
                      _buildActionDropdown('Action Type', index, 'actionType', [
                        'status_update',
                        'notification',
                        'email',
                        'data_transfer',
                        'calculation',
                        'workflow_trigger',
                      ]),
                      context.vS,
                      _buildActionTextField('Source Table', index, 'sourceTable'),
                      context.vS,
                      _buildActionTextField('Source Field', index, 'sourceField'),
                      context.vS,
                      _buildActionTextField('Destination Table', index, 'destinationTable'),
                      context.vS,
                      _buildActionTextField('Destination Field', index, 'destinationField'),
                      context.vS,
                      _buildActionCheckbox('Is Archive', index, 'isArchive'),
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

  Widget _buildCompetencyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Competency Reports',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            IconButton(
              onPressed: _addCompetencyReport,
              icon: Icon(Icons.add_circle, color: context.colors.primary),
            ),
          ],
        ),
        context.divider,
        context.vS,
        Expanded(
          child: ListView.builder(
            itemCount: _competencyReports?.length ?? 0,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Competency Report ${index + 1}',
                              style: context.topology.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeCompetencyReport(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                      context.vS,
                      _buildCompetencyTextField('Name', index, 'name'),
                      context.vS,
                      _buildCompetencyDropdown('Internal/External', index, 'internalExternal', [
                        'internal',
                        'external',
                      ]),
                      context.vS,
                      _buildCompetencyCheckbox('Can Create', index, 'canCreate'),
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

  // Helper methods for Fields step
  Widget _buildFieldTextField(String label, int index, String key) {
    final currentValue = _reportFields?[index][key]?.toString() ?? '';

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: TextEditingController(text: currentValue)
              ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            onChanged: (value) {
              setState(() {
                _reportFields?[index][key] = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFieldDropdown(String label, int index, String key, List<String> options) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _reportFields?[index][key]?.toString(),
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
                isExpanded: true,
                items:
                    options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: context.topology.textTheme.bodyMedium),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _reportFields?[index][key] = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCheckbox(String label, int index, String key) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Checkbox(
            value: _reportFields?[index][key] ?? false,
            onChanged: (bool? value) {
              setState(() {
                _reportFields?[index][key] = value ?? false;
              });
            },
            activeColor: context.colors.primary,
          ),
        ),
      ],
    );
  }

  // Helper methods for Status Rules step
  Widget _buildStatusRuleTextField(String label, int index, String key) {
    final currentValue = _statusRuleReports?[index][key]?.toString() ?? '';

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: TextEditingController(text: currentValue)
              ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            onChanged: (value) {
              setState(() {
                _statusRuleReports?[index][key] = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRuleDropdown(String label, int index, String key, List<String> options) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusRuleReports?[index][key]?.toString(),
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
                isExpanded: true,
                items:
                    options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: context.topology.textTheme.bodyMedium),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _statusRuleReports?[index][key] = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for Dates step
  Widget _buildDateTextField(String label, int index, String key) {
    final currentValue = _reportTypeDates?[index][key]?.toString() ?? '';

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: TextEditingController(text: currentValue)
              ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            onChanged: (value) {
              setState(() {
                _reportTypeDates?[index][key] = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateDropdown(String label, int index, String key, List<String> options) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _reportTypeDates?[index][key]?.toString(),
                isExpanded: true,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
                items:
                    options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: context.topology.textTheme.bodyMedium),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _reportTypeDates?[index][key] = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateCheckbox(String label, int index, String key) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Checkbox(
            value: _reportTypeDates?[index][key] ?? false,
            onChanged: (bool? value) {
              setState(() {
                _reportTypeDates?[index][key] = value ?? false;
              });
            },
            activeColor: context.colors.primary,
          ),
        ),
      ],
    );
  }

  // Helper methods for Actions step
  Widget _buildActionTextField(String label, int index, String key) {
    final currentValue = _actionReports?[index][key]?.toString() ?? '';

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: TextEditingController(text: currentValue)
              ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            onChanged: (value) {
              setState(() {
                _actionReports?[index][key] = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionDropdown(String label, int index, String key, List<String> options) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _actionReports?[index][key]?.toString(),
                isExpanded: true,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
                items:
                    options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: context.topology.textTheme.bodyMedium),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _actionReports?[index][key] = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCheckbox(String label, int index, String key) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Checkbox(
            value: _actionReports?[index][key] ?? false,
            onChanged: (bool? value) {
              setState(() {
                _actionReports?[index][key] = value ?? false;
              });
            },
            activeColor: context.colors.primary,
          ),
        ),
      ],
    );
  }

  // Helper methods for Competency step
  Widget _buildCompetencyTextField(String label, int index, String key) {
    final currentValue = _competencyReports?[index][key]?.toString() ?? '';

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: TextEditingController(text: currentValue)
              ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            onChanged: (value) {
              setState(() {
                _competencyReports?[index][key] = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencyDropdown(String label, int index, String key, List<String> options) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: context.colors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _competencyReports?[index][key]?.toString(),
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
                isExpanded: true,
                items:
                    options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _competencyReports?[index][key] = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencyCheckbox(String label, int index, String key) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Checkbox(
            value: _competencyReports?[index][key] ?? false,
            onChanged: (bool? value) {
              setState(() {
                _competencyReports?[index][key] = value ?? false;
              });
            },
            activeColor: context.colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: controller,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxField(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Checkbox(value: value, onChanged: onChanged, activeColor: context.colors.primary),
        ),
      ],
    );
  }

  // Methods to add/remove dynamic items
  void _addReportField() {
    setState(() {
      _reportFields?.add({
        "labelText": "",
        "name": "",
        "fieldType": "text",
        "defaultValue": "",
        "section": "",
        "onlyAvailable": "all",
        "isRequired": true,
        "permissionField": "read,write",
        "doNotCopy": false,
        "infoText": "",
        "isArchive": false,
      });
    });
  }

  void _removeReportField(int index) {
    setState(() {
      _reportFields?.removeAt(index);
    });
  }

  void _addStatusRule() {
    setState(() {
      _statusRuleReports?.add({"status": "", "field": "", "operator": "", "value": ""});
    });
  }

  void _removeStatusRule(int index) {
    setState(() {
      _statusRuleReports?.removeAt(index);
    });
  }

  void _addReportTypeDate() {
    setState(() {
      _reportTypeDates?.add({
        "name": "",
        "applyCycle": "",
        "isRequired": true,
        "disableFreeType": false,
      });
    });
  }

  void _removeReportTypeDate(int index) {
    setState(() {
      _reportTypeDates?.removeAt(index);
    });
  }

  void _addActionReport() {
    setState(() {
      _actionReports?.add({
        "description": "",
        "isArchive": false,
        "applyAction": "",
        "match": "",
        "actionType": "",
        "sourceTable": "",
        "sourceField": "",
        "destinationTable": "",
        "destinationField": "",
      });
    });
  }

  void _removeActionReport(int index) {
    setState(() {
      _actionReports?.removeAt(index);
    });
  }

  void _addCompetencyReport() {
    setState(() {
      _competencyReports?.add({"internalExternal": "internal", "name": "", "canCreate": true});
    });
  }

  void _removeCompetencyReport(int index) {
    setState(() {
      _competencyReports?.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    try {
      final provider = Provider.of<SystemProvider>(context, listen: false);

      // Clean up reportFields before submission
      final cleanedReportFields =
          _reportFields?.map((field) {
            final cleanField = Map<String, dynamic>.from(field);

            // Ensure defaultValue is a simple string
            if (cleanField['defaultValue'] != null) {
              if (cleanField['defaultValue'] is List || cleanField['defaultValue'] is Map) {
                cleanField['defaultValue'] = '';
              } else {
                cleanField['defaultValue'] = cleanField['defaultValue'].toString();
              }
            }

            return cleanField;
          }).toList();

      final reportType = {
        "reportName": _reportNameController.text,
        "description": _descriptionController.text,
        "documentCode": _documentCodeController.text,
        "isExternalReport": _isExternalReport,
        "defaultAsDraft": _defaultAsDraft,
        "archived": _archived,
        "updateItemStatus": _updateItemStatus,
        "updateItemDates": _updateItemDates,
        "batchReportType": _batchReportTypeController.text,
        "isStatusRequired": _isStatusRequired,
        "possibleStatus": _possibleStatusController.text,
        "permission": _permissionController.text,
        "fieldsID": _fieldsIDController.text,
        "documentTemplate": _documentTemplateController.text,
        "labelTemplate": _labelTemplateController.text,
        "actionReportID": _actionReportIDController.text,
        "competencyID": _competencyIDController.text,
      };

      if (_isEditMode) {
        await provider.updateReport(
          reportId: _editReportData?.categoryId ?? '',
          reportType: reportType,
          competencyReports: _competencyReports ?? [],
          reportTypeDates: _reportTypeDates ?? [],
          statusRuleReports: _statusRuleReports ?? [],
          reportFields: cleanedReportFields ?? [],
          actionReports: _actionReports ?? [],
        );
      } else {
        await provider.createReport(
          reportType: reportType,
          competencyReports: _competencyReports ?? [],
          reportTypeDates: _reportTypeDates ?? [],
          statusRuleReports: _statusRuleReports ?? [],
          reportFields: cleanedReportFields ?? [],
          actionReports: _actionReports ?? [],
        );
      }

      if (provider.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${provider.errorMessage}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Report updated successfully!' : 'Report created successfully!',
            ),
          ),
        );
        NavigationService().goBack();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
