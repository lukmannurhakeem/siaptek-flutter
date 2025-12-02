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
            'Basic Information',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          context.divider,
          context.vM,
          _buildTextField('Report Name *', _reportNameController),
          context.vS,
          _buildTextField('Description', _descriptionController, maxLines: 3),
          context.vS,
          _buildTextField('Document Code', _documentCodeController),
          context.vS,
          _buildTextField('Batch Report Type', _batchReportTypeController),
          if (_isEditMode) ...[
            context.vS,
            _buildTextField('Category ID', _categoryIDController, enabled: false),
          ],
          context.vL,
          Text(
            'Report Settings',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          context.divider,
          context.vM,
          _buildCheckboxField('External Report', _isExternalReport, (value) {
            setState(() => _isExternalReport = value ?? false);
          }),
          _buildCheckboxField('Default as Draft', _defaultAsDraft, (value) {
            setState(() => _defaultAsDraft = value ?? true);
          }),
          _buildCheckboxField('Archived', _archived, (value) {
            setState(() => _archived = value ?? false);
          }),
          _buildCheckboxField('Update Item Status', _updateItemStatus, (value) {
            setState(() => _updateItemStatus = value ?? true);
          }),
          _buildCheckboxField('Update Item Dates', _updateItemDates, (value) {
            setState(() => _updateItemDates = value ?? true);
          }),
          context.vL,
          Text(
            'Status Configuration',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          context.divider,
          context.vM,
          _buildCheckboxField('Status Required', _isStatusRequired, (value) {
            setState(() => _isStatusRequired = value ?? true);
          }),
          context.vS,
          _buildTextField(
            'Possible Statuses (comma separated)',
            _possibleStatusController,
            hint: 'e.g., draft,pending,approved,rejected',
          ),
          context.vL,
          Text(
            'Permissions',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          context.divider,
          context.vM,
          _buildTextField(
            'Permissions (comma separated)',
            _permissionController,
            hint: 'e.g., admin,manager,user',
          ),
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
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addReportField,
              icon: Icon(Icons.add, size: 18),
              label: Text('Add Field'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        context.divider,
        context.vM,
        if (_reportFields?.isEmpty ?? true)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                  context.vM,
                  Text(
                    'No fields added yet',
                    style: context.topology.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  context.vS,
                  Text(
                    'Click "Add Field" to create a new field',
                    style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _reportFields?.length ?? 0,
              itemBuilder: (context, index) {
                final fieldType = _reportFields?[index]['fieldType']?.toString() ?? 'text';

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Field ${index + 1}',
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () => _removeReportField(index),
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remove Field',
                            ),
                          ],
                        ),
                        context.vM,
                        _buildFieldTextField('Label Text *', index, 'labelText'),
                        context.vS,
                        _buildFieldTextField('Field Name *', index, 'name'),
                        context.vS,
                        _buildFieldDropdown('Field Type', index, 'fieldType', [
                          'text',
                          'number',
                          'decimal',
                          'date',
                          'checkbox',
                          'dropdown',
                          'textarea',
                          'file',
                          'label',
                          'section',
                        ]),
                        context.vS,
                        // Conditional fields based on field type
                        if (fieldType == 'dropdown') ...[
                          _buildFieldTextField('Default Value', index, 'defaultValue'),
                          context.vS,
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _reportFields?[index]['dropdownType'] = 'typed';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (_reportFields?[index]['dropdownType'] ?? 'typed') ==
                                                'typed'
                                            ? context.colors.primary
                                            : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Typed'),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _reportFields?[index]['dropdownType'] = 'lookup';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (_reportFields?[index]['dropdownType'] ?? 'typed') ==
                                                'lookup'
                                            ? context.colors.primary
                                            : Colors.grey,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Lookup'),
                                ),
                              ),
                            ],
                          ),
                          context.vS,
                          _buildFieldTextField('Options', index, 'options'),
                          context.vS,
                        ] else if (fieldType == 'file') ...[
                          _buildFieldCheckbox('Append PDF', index, 'appendPDF'),
                          context.vS,
                          _buildFieldTextField('File Extensions', index, 'fileExtensions'),
                          context.vS,
                        ] else if (fieldType == 'label' || fieldType == 'section') ...[
                          // Label and section types have minimal fields
                        ] else ...[
                          _buildFieldTextField('Default Value', index, 'defaultValue'),
                          context.vS,
                        ],
                        _buildFieldTextFieldWithSuggestions('Section', index, 'section'),
                        context.vS,
                        _buildFieldTextField('Only available if', index, 'onlyAvailable'),
                        context.vS,
                        _buildFieldCheckbox('Required', index, 'isRequired'),
                        context.vS,
                        _buildFieldTextField('Info Text', index, 'infoText'),
                        context.vS,
                        if (fieldType == 'label' || fieldType == 'section')
                          _buildFieldCheckbox('Hide/Archive?', index, 'isArchive')
                        else
                          _buildFieldCheckbox('Do Not Copy', index, 'doNotCopy'),
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
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addStatusRule,
              icon: Icon(Icons.add, size: 18),
              label: Text('Add Rule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        context.divider,
        context.vM,
        if (_statusRuleReports?.isEmpty ?? true)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rule_outlined, size: 64, color: Colors.grey),
                  context.vM,
                  Text(
                    'No status rules added yet',
                    style: context.topology.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  context.vS,
                  Text(
                    'Click "Add Rule" to create a new status rule',
                    style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _statusRuleReports?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Rule ${index + 1}',
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () => _removeStatusRule(index),
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remove Rule',
                            ),
                          ],
                        ),
                        context.vM,
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
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addReportTypeDate,
              icon: Icon(Icons.add, size: 18),
              label: Text('Add Date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        context.divider,
        context.vM,
        if (_reportTypeDates?.isEmpty ?? true)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                  context.vM,
                  Text(
                    'No date configurations added yet',
                    style: context.topology.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  context.vS,
                  Text(
                    'Click "Add Date" to create a new date configuration',
                    style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _reportTypeDates?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Date ${index + 1}',
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () => _removeReportTypeDate(index),
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remove Date',
                            ),
                          ],
                        ),
                        context.vM,
                        _buildDateTextField('Date Name *', index, 'name'),
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
                        Wrap(
                          spacing: 16,
                          children: [
                            _buildDateCheckbox('Required', index, 'isRequired'),
                            _buildDateCheckbox('Disable Free Type', index, 'disableFreeType'),
                          ],
                        ),
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
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addActionReport,
              icon: Icon(Icons.add, size: 18),
              label: Text('Add Action'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        context.divider,
        context.vM,
        if (_actionReports?.isEmpty ?? true)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_outlined, size: 64, color: Colors.grey),
                  context.vM,
                  Text(
                    'No action reports added yet',
                    style: context.topology.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  context.vS,
                  Text(
                    'Click "Add Action" to create a new action report',
                    style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _actionReports?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Action ${index + 1}',
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () => _removeActionReport(index),
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remove Action',
                            ),
                          ],
                        ),
                        context.vM,
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
                        _buildActionCheckbox('Archive', index, 'isArchive'),
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
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addCompetencyReport,
              icon: Icon(Icons.add, size: 18),
              label: Text('Add Competency'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        context.divider,
        context.vM,
        if (_competencyReports?.isEmpty ?? true)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology_outlined, size: 64, color: Colors.grey),
                  context.vM,
                  Text(
                    'No competency reports added yet',
                    style: context.topology.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  context.vS,
                  Text(
                    'Click "Add Competency" to create a new competency report',
                    style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _competencyReports?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Competency ${index + 1}',
                                style: context.topology.textTheme.titleSmall?.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () => _removeCompetencyReport(index),
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remove Competency',
                            ),
                          ],
                        ),
                        context.vM,
                        _buildCompetencyTextField('Name *', index, 'name'),
                        context.vS,
                        _buildCompetencyDropdown('Type', index, 'internalExternal', [
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
  List<String> _getAvailableSections() {
    final sections = <String>{};
    for (var field in _reportFields ?? []) {
      if (field['fieldType'] == 'section' && field['labelText'] != null) {
        final sectionName = field['labelText'].toString().trim();
        if (sectionName.isNotEmpty) {
          sections.add(sectionName);
        }
      }
    }
    return sections.toList();
  }

  Widget _buildFieldTextFieldWithSuggestions(String label, int index, String key) {
    final currentValue = _reportFields?[index][key]?.toString() ?? '';
    final availableSections = _getAvailableSections();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        if (availableSections.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                availableSections.map((section) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _reportFields?[index][key] = section;
                      });
                    },
                    child: Chip(
                      label: Text(
                        section,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: currentValue == section ? Colors.white : context.colors.primary,
                        ),
                      ),
                      backgroundColor:
                          currentValue == section
                              ? context.colors.primary
                              : context.colors.primary.withOpacity(0.1),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 8),
        ],
        CommonTextField(
          controller: TextEditingController(text: currentValue)
            ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          onChanged: (value) {
            setState(() {
              _reportFields?[index][key] = value;
            });
          },
          hintText:
              availableSections.isEmpty ? 'Enter section name' : 'Select or enter section name',
        ),
      ],
    );
  }

  Widget _buildFieldTextField(String label, int index, String key) {
    final currentValue = _reportFields?[index][key]?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        CommonTextField(
          controller: TextEditingController(text: currentValue)
            ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          onChanged: (value) {
            setState(() {
              _reportFields?[index][key] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFieldDropdown(String label, int index, String key, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _reportFields?[index][key]?.toString(),
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
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
      ],
    );
  }

  Widget _buildFieldCheckbox(String label, int index, String key) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _reportFields?[index][key] ?? false,
          onChanged: (bool? value) {
            setState(() {
              _reportFields?[index][key] = value ?? false;
            });
          },
          activeColor: context.colors.primary,
        ),
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }

  // Helper methods for Status Rules step
  Widget _buildStatusRuleTextField(String label, int index, String key) {
    final currentValue = _statusRuleReports?[index][key]?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        CommonTextField(
          controller: TextEditingController(text: currentValue)
            ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          onChanged: (value) {
            setState(() {
              _statusRuleReports?[index][key] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStatusRuleDropdown(String label, int index, String key, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _statusRuleReports?[index][key]?.toString(),
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
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
      ],
    );
  }

  // Helper methods for Dates step
  Widget _buildDateTextField(String label, int index, String key) {
    final currentValue = _reportTypeDates?[index][key]?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        CommonTextField(
          controller: TextEditingController(text: currentValue)
            ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          onChanged: (value) {
            setState(() {
              _reportTypeDates?[index][key] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateDropdown(String label, int index, String key, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _reportTypeDates?[index][key]?.toString(),
              isExpanded: true,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
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
      ],
    );
  }

  Widget _buildDateCheckbox(String label, int index, String key) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _reportTypeDates?[index][key] ?? false,
          onChanged: (bool? value) {
            setState(() {
              _reportTypeDates?[index][key] = value ?? false;
            });
          },
          activeColor: context.colors.primary,
        ),
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }

  // Helper methods for Actions step
  Widget _buildActionTextField(String label, int index, String key) {
    final currentValue = _actionReports?[index][key]?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        CommonTextField(
          controller: TextEditingController(text: currentValue)
            ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          onChanged: (value) {
            setState(() {
              _actionReports?[index][key] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionDropdown(String label, int index, String key, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _actionReports?[index][key]?.toString(),
              isExpanded: true,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
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
      ],
    );
  }

  Widget _buildActionCheckbox(String label, int index, String key) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _actionReports?[index][key] ?? false,
          onChanged: (bool? value) {
            setState(() {
              _actionReports?[index][key] = value ?? false;
            });
          },
          activeColor: context.colors.primary,
        ),
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }

  // Helper methods for Competency step
  Widget _buildCompetencyTextField(String label, int index, String key) {
    final currentValue = _competencyReports?[index][key]?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        CommonTextField(
          controller: TextEditingController(text: currentValue)
            ..selection = TextSelection.fromPosition(TextPosition(offset: currentValue.length)),
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          onChanged: (value) {
            setState(() {
              _competencyReports?[index][key] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCompetencyDropdown(String label, int index, String key, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _competencyReports?[index][key]?.toString(),
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
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
      ],
    );
  }

  Widget _buildCompetencyCheckbox(String label, int index, String key) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _competencyReports?[index][key] ?? false,
          onChanged: (bool? value) {
            setState(() {
              _competencyReports?[index][key] = value ?? false;
            });
          },
          activeColor: context.colors.primary,
        ),
        Text(
          label,
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodyMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        CommonTextField(
          controller: controller,
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          maxLines: maxLines,
          enabled: enabled,
          hintText: hint,
        ),
      ],
    );
  }

  Widget _buildCheckboxField(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged, activeColor: context.colors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
          ),
        ],
      ),
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
      _statusRuleReports?.add({"status": "draft", "field": "", "operator": "==", "value": ""});
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
        "applyCycle": "daily",
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
        "actionType": "status_update",
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

  // Update the _submitReport method in your ReportCreateScreen

  // Update the _submitReport method in your ReportCreateScreen

  Future<void> _submitReport() async {
    // Validate required fields
    if (_reportNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a report name')));
      setState(() => _currentStep = 0);
      return;
    }

    try {
      final provider = Provider.of<SystemProvider>(context, listen: false);

      // Clean up reportFields before submission
      final cleanedReportFields =
          (_reportFields ?? []).map((field) {
            final cleanField = Map<String, dynamic>.from(field);

            // Remove created_at and updated_at fields
            cleanField.remove('created_at');
            cleanField.remove('updated_at');
            cleanField.remove('createdAt');
            cleanField.remove('updatedAt');

            // Ensure all required fields exist with proper types
            cleanField['labelText'] = cleanField['labelText']?.toString() ?? '';
            cleanField['name'] = cleanField['name']?.toString() ?? '';
            cleanField['fieldType'] = cleanField['fieldType']?.toString() ?? 'text';
            cleanField['section'] = cleanField['section']?.toString() ?? '';
            cleanField['onlyAvailable'] = cleanField['onlyAvailable']?.toString() ?? 'all';
            cleanField['permissionField'] = cleanField['permissionField']?.toString() ?? '';
            cleanField['infoText'] = cleanField['infoText']?.toString() ?? '';

            // Handle defaultValue - ensure it's a string
            if (cleanField['defaultValue'] != null) {
              if (cleanField['defaultValue'] is List || cleanField['defaultValue'] is Map) {
                cleanField['defaultValue'] = '';
              } else {
                cleanField['defaultValue'] = cleanField['defaultValue'].toString();
              }
            } else {
              cleanField['defaultValue'] = '';
            }

            // Ensure boolean fields are proper booleans
            cleanField['isRequired'] = cleanField['isRequired'] == true;
            cleanField['doNotCopy'] = cleanField['doNotCopy'] == true;
            cleanField['isArchive'] = cleanField['isArchive'] == true;

            return cleanField;
          }).toList();

      // Clean up statusRuleReports
      final cleanedStatusRules =
          (_statusRuleReports ?? []).map((rule) {
            final cleanRule = Map<String, dynamic>.from(rule);

            // Remove created_at and updated_at fields
            cleanRule.remove('created_at');
            cleanRule.remove('updated_at');
            cleanRule.remove('createdAt');
            cleanRule.remove('updatedAt');

            return {
              'status': cleanRule['status']?.toString() ?? '',
              'field': cleanRule['field']?.toString() ?? '',
              'operator': cleanRule['operator']?.toString() ?? '==',
              'value': cleanRule['value']?.toString() ?? '',
            };
          }).toList();

      // Clean up reportTypeDates
      final cleanedReportDates =
          (_reportTypeDates ?? []).map((date) {
            final cleanDate = Map<String, dynamic>.from(date);

            // Remove created_at and updated_at fields
            cleanDate.remove('created_at');
            cleanDate.remove('updated_at');
            cleanDate.remove('createdAt');
            cleanDate.remove('updatedAt');

            return {
              'name': cleanDate['name']?.toString() ?? '',
              'applyCycle': cleanDate['applyCycle']?.toString() ?? 'daily',
              'isRequired': cleanDate['isRequired'] == true,
              'disableFreeType': cleanDate['disableFreeType'] == true,
            };
          }).toList();

      // Clean up actionReports
      final cleanedActionReports =
          (_actionReports ?? []).map((action) {
            final cleanAction = Map<String, dynamic>.from(action);

            // Remove created_at and updated_at fields
            cleanAction.remove('created_at');
            cleanAction.remove('updated_at');
            cleanAction.remove('createdAt');
            cleanAction.remove('updatedAt');

            return {
              'description': cleanAction['description']?.toString() ?? '',
              'isArchive': cleanAction['isArchive'] == true,
              'applyAction': cleanAction['applyAction']?.toString() ?? '',
              'match': cleanAction['match']?.toString() ?? '',
              'actionType': cleanAction['actionType']?.toString() ?? 'status_update',
              'sourceTable': cleanAction['sourceTable']?.toString() ?? '',
              'sourceField': cleanAction['sourceField']?.toString() ?? '',
              'destinationTable': cleanAction['destinationTable']?.toString() ?? '',
              'destinationField': cleanAction['destinationField']?.toString() ?? '',
            };
          }).toList();

      // Clean up competencyReports
      final cleanedCompetencyReports =
          (_competencyReports ?? []).map((competency) {
            final cleanCompetency = Map<String, dynamic>.from(competency);

            // Remove created_at and updated_at fields
            cleanCompetency.remove('created_at');
            cleanCompetency.remove('updated_at');
            cleanCompetency.remove('createdAt');
            cleanCompetency.remove('updatedAt');

            return {
              'internalExternal': cleanCompetency['internalExternal']?.toString() ?? 'internal',
              'name': cleanCompetency['name']?.toString() ?? '',
              'canCreate': cleanCompetency['canCreate'] == true,
            };
          }).toList();

      // Build the reportType object according to the new format
      final reportType = {
        "reportName": _reportNameController.text.trim(),
        "description": _descriptionController.text.trim(),
        "documentCode": _documentCodeController.text.trim(),
        "isExternalReport": _isExternalReport,
        "defaultAsDraft": _defaultAsDraft,
        "archived": _archived,
        "updateItemStatus": _updateItemStatus,
        "updateItemDates": _updateItemDates,
        "batchReportType": _batchReportTypeController.text.trim(),
        "isStatusRequired": _isStatusRequired,
        "possibleStatus": _possibleStatusController.text.trim(),
        "permission": _permissionController.text.trim(),
        "categoryID":
            _isEditMode && _categoryIDController.text.isNotEmpty
                ? _categoryIDController.text.trim()
                : null,
      };

      if (_isEditMode) {
        await provider.updateReport(
          reportId: _editReportData?.categoryId ?? '',
          reportType: reportType,
          competencyReports: cleanedCompetencyReports,
          reportTypeDates: cleanedReportDates,
          statusRuleReports: cleanedStatusRules,
          reportFields: cleanedReportFields,
          actionReports: cleanedActionReports,
        );
      } else {
        await provider.createReport(
          reportType: reportType,
          competencyReports: cleanedCompetencyReports,
          reportTypeDates: cleanedReportDates,
          statusRuleReports: cleanedStatusRules,
          reportFields: cleanedReportFields,
          actionReports: cleanedActionReports,
        );
      }

      if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${provider.errorMessage}'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Report updated successfully!' : 'Report created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        NavigationService().goBack();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }
}
