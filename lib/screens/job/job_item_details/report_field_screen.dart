import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model for field configuration
class FieldConfig {
  final String name;
  final String label;
  final String type;
  final String? defaultValue;
  final List<String>? options;
  final String? section;
  final bool required;
  final String? infoText;

  FieldConfig({
    required this.name,
    required this.label,
    required this.type,
    this.defaultValue,
    this.options,
    this.section,
    this.required = false,
    this.infoText,
  });
}

class ReportFieldsScreen extends StatefulWidget {
  final String reportTypeId;
  final String reportName;
  final Item item;

  const ReportFieldsScreen({
    required this.reportTypeId,
    required this.reportName,
    super.key,
    required this.item,
  });

  @override
  State<ReportFieldsScreen> createState() => _ReportFieldsScreenState();
}

class _ReportFieldsScreenState extends State<ReportFieldsScreen> {
  // State variables
  Map<String, dynamic> _fieldValues = {};
  Map<String, TextEditingController> _controllers = {};
  List<FieldConfig> _fields = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  DateTime? _selectedReportDate;

  // Additional controllers for fixed fields
  final TextEditingController _itemIdController = TextEditingController();
  final TextEditingController _itemNoController = TextEditingController();
  final TextEditingController _regulationController = TextEditingController();
  String _selectedStatus = 'draft';
  String? _selectedInspectedById;

  @override
  void initState() {
    super.initState();

    // Pre-fill item data if available
    _itemIdController.text = widget.item.itemId ?? '';
    _itemNoController.text = widget.item.itemNo ?? '';

    _fetchReportFields();

    // Fetch personnel data for the dropdown
    Future.microtask(() {
      context.read<PersonnelProvider>().fetchPersonnel();
    });
  }

  Future<void> _fetchReportFields() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<SystemProvider>();
      final result = await provider.getReportFields(widget.reportTypeId);

      if (result == null || result['data'] == null) {
        setState(() {
          _fields = [];
          _isLoading = false;
        });
        return;
      }

      final dynamic data = result['data'];

      // Parse field configurations
      List<FieldConfig> parsedFields = [];

      if (data is List) {
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            // Parse structured field configuration
            parsedFields.add(_parseFieldConfig(item));
          } else if (item is String && item.isNotEmpty) {
            // Legacy: simple text field
            parsedFields.add(FieldConfig(name: item.trim(), label: item.trim(), type: 'text'));
          }
        }
      }

      setState(() {
        _fields = parsedFields;
        // Initialize controllers and values for each field
        for (var field in _fields) {
          if (field.type == 'text' || field.type == 'textarea' || field.type == 'number') {
            _controllers[field.name] = TextEditingController(text: field.defaultValue);
          } else if (field.type == 'dropdown') {
            _fieldValues[field.name] = field.defaultValue;
          } else if (field.type == 'checkbox') {
            _fieldValues[field.name] = field.defaultValue == 'true';
          } else if (field.type == 'date') {
            _fieldValues[field.name] = null;
          } else if (field.type == 'file') {
            _fieldValues[field.name] = null;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('not found') ||
          errorMessage.contains('no data') ||
          errorMessage.contains('404')) {
        setState(() {
          _fields = [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  FieldConfig _parseFieldConfig(Map<String, dynamic> data) {
    return FieldConfig(
      name: data['name'] ?? data['field_name'] ?? '',
      label: data['label'] ?? data['label_text'] ?? data['labelText'] ?? '',
      type: (data['type'] ?? data['field_type'] ?? data['fieldType'] ?? 'text').toLowerCase(),
      defaultValue: data['default_value']?.toString() ?? data['defaultValue']?.toString(),
      options:
          data['options'] != null
              ? (data['options'] as String).split(',').map((e) => e.trim()).toList()
              : null,
      section: data['section'],
      required:
          data['required'] == true || data['required'] == 'true' || data['isRequired'] == true,
      infoText: data['info_text'] ?? data['infoText'],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _itemIdController.dispose();
    _itemNoController.dispose();
    _regulationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reportName,
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body: Stack(
        children: [
          Column(children: [_buildFixedDataSection(), Expanded(child: _buildBody())]),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFixedDataSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: context.colors.primary.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Information',
            style: context.topology.textTheme.titleSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Report Type ID:', widget.reportTypeId),
          const SizedBox(height: 8),
          _buildInfoRow('Report Name:', widget.reportName),
          const SizedBox(height: 12),
          _buildDatePicker(),
          const SizedBox(height: 12),
          _buildStatusDropdown(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: context.colors.primary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Date',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedReportDate != null
                        ? _selectedReportDate!.formatMediumDate
                        : 'Select date',
                    style: context.topology.textTheme.bodyMedium?.copyWith(
                      color:
                          _selectedReportDate != null
                              ? context.colors.primary
                              : context.colors.primary.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: context.colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.onPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: context.colors.primary),
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
          items:
              ['draft', 'submitted', 'approved', 'rejected'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedStatus = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedReportDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary,
              onPrimary: context.colors.onPrimary,
              onSurface: context.colors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedReportDate) {
      setState(() {
        _selectedReportDate = picked;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
                'Failed to Load Fields',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchReportFields,
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

    return SingleChildScrollView(
      padding: context.paddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Information',
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          context.vM,
          _buildRequiredField('Item ID', _itemIdController, 'Enter item ID'),
          const SizedBox(height: 12),
          _buildRequiredField('Item No', _itemNoController, 'Enter item number'),
          const SizedBox(height: 12),
          _buildInspectedByDropdown(),
          const SizedBox(height: 12),
          _buildRequiredField('Regulation', _regulationController, 'Enter regulation'),

          // BEAUTIFIED REPORT FIELDS SECTION
          if (_fields.isNotEmpty) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary.withOpacity(0.08),
                    context.colors.primary.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.primary.withOpacity(0.2), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.article_outlined,
                          color: context.colors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report Fields',
                              style: context.topology.textTheme.titleLarge?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_fields.where((f) => f.type.toLowerCase() != 'section').length} field(s)',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ..._buildDynamicFields(),
                ],
              ),
            ),
          ],

          if (_fields.isEmpty) ...[
            context.vL,
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No custom fields defined for this report type. You can submit with the required information above.',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          context.vL,
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildRequiredField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.topology.textTheme.bodyMedium?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CommonTextField(
          controller: controller,
          hintText: hint,
          style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
        ),
      ],
    );
  }

  Widget _buildInspectedByDropdown() {
    return Consumer<PersonnelProvider>(
      builder: (context, personnelProvider, _) {
        final personnelList = personnelProvider.personnelList ?? [];

        if (personnelList.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inspected By',
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No personnel available. Please add personnel first.',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final items =
            personnelList.map((personnel) {
              final displayName =
                  personnel.displayName?.isNotEmpty == true
                      ? personnel.displayName!
                      : personnel.fullName ?? 'Unknown';
              final id = personnel.personnel?.personnelID ?? '';

              return DropdownMenuItem<String>(value: id, child: Text(displayName));
            }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspected By',
              style: context.topology.textTheme.bodyMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CommonDropdown<String>(
              value: _selectedInspectedById,
              items: items,
              onChanged: (value) {
                setState(() {
                  _selectedInspectedById = value;
                });
              },
              borderColor: context.colors.primary.withOpacity(0.3),
              backgroundColor: context.colors.onPrimary,
              label: null,
            ),
          ],
        );
      },
    );
  }

  // BEAUTIFIED DYNAMIC FIELDS BUILDER
  List<Widget> _buildDynamicFields() {
    List<Widget> widgets = [];

    for (var field in _fields) {
      // Handle section headers
      if (field.type.toLowerCase() == 'section') {
        if (widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: 24)); // Space before new section
        }

        widgets.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary.withOpacity(0.1),
                  context.colors.primary.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: context.colors.primary, width: 4)),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, color: context.colors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    field.label,
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        widgets.add(const SizedBox(height: 16));
        continue;
      }

      // Regular fields with card-like appearance
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.onPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.primary.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field label with required indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      field.label,
                      style: context.topology.textTheme.bodyLarge?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (field.required)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Required',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (field.infoText != null) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        field.infoText!,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              _buildFieldWidget(field),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildFieldWidget(FieldConfig field) {
    switch (field.type.toLowerCase()) {
      case 'text':
      case 'number':
        return CommonTextField(
          controller: _controllers[field.name],
          hintText: 'Enter ${field.label.toLowerCase()}',
          keyboardType: field.type == 'number' ? TextInputType.number : TextInputType.text,
        );

      case 'textarea':
        return CommonTextField(
          controller: _controllers[field.name],
          hintText: 'Enter ${field.label.toLowerCase()}',
          maxLines: 4,
        );

      case 'dropdown':
        return _buildCustomDropdown(field);

      case 'checkbox':
        return _buildCheckbox(field);

      case 'date':
        return _buildDateField(field);

      case 'file':
        return _buildFileField(field);

      case 'label':
        return _buildLabelField(field);

      default:
        return CommonTextField(
          controller: _controllers[field.name],
          hintText: 'Enter ${field.label.toLowerCase()}',
        );
    }
  }

  Widget _buildCustomDropdown(FieldConfig field) {
    final items =
        field.options
            ?.map((option) => DropdownMenuItem<String>(value: option, child: Text(option)))
            .toList() ??
        [];

    return CommonDropdown<String>(
      value: _fieldValues[field.name],
      items: items,
      onChanged: (value) {
        setState(() {
          _fieldValues[field.name] = value;
        });
      },
      borderColor: context.colors.primary.withOpacity(0.3),
      backgroundColor: context.colors.onPrimary,
      label: null,
    );
  }

  Widget _buildCheckbox(FieldConfig field) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.onPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 1),
      ),
      child: CheckboxListTile(
        title: Text(
          field.label,
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
        value: _fieldValues[field.name] ?? false,
        onChanged: (bool? value) {
          setState(() {
            _fieldValues[field.name] = value ?? false;
          });
        },
        activeColor: context.colors.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildDateField(FieldConfig field) {
    DateTime? selectedDate = _fieldValues[field.name];

    return InkWell(
      onTap: () => _selectFieldDate(context, field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null ? selectedDate.formatMediumDate : 'Select date',
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color:
                      selectedDate != null
                          ? context.colors.primary
                          : context.colors.primary.withOpacity(0.5),
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: context.colors.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFieldDate(BuildContext context, FieldConfig field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fieldValues[field.name] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary,
              onPrimary: context.colors.onPrimary,
              onSurface: context.colors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fieldValues[field.name] = picked;
      });
    }
  }

  Widget _buildFileField(FieldConfig field) {
    return InkWell(
      onTap: () => _selectFile(field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file, size: 20, color: context.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fieldValues[field.name] != null
                    ? 'File selected: ${_fieldValues[field.name]}'
                    : 'Choose file',
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color:
                      _fieldValues[field.name] != null
                          ? context.colors.primary
                          : context.colors.primary.withOpacity(0.5),
                ),
              ),
            ),
            Icon(Icons.upload, color: context.colors.primary),
          ],
        ),
      ),
    );
  }

  void _selectFile(FieldConfig field) {
    // Implement file picker logic here
    // For now, just a placeholder
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('File picker not implemented yet')));
  }

  Widget _buildLabelField(FieldConfig field) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              field.infoText ?? field.label,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.blue[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: context.colors.primary.withOpacity(0.5),
        ),
        child: Text(
          _isSubmitting ? 'Submitting...' : 'Submit',
          style: context.topology.textTheme.bodyMedium?.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    // Validate required fixed fields
    if (_selectedReportDate == null) {
      _showErrorSnackBar('Please select a report date');
      return;
    }

    if (_itemIdController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter Item ID');
      return;
    }

    if (_itemNoController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter Item No');
      return;
    }

    if (_selectedInspectedById == null || _selectedInspectedById!.isEmpty) {
      _showErrorSnackBar('Please select an inspector');
      return;
    }

    if (_regulationController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter Regulation');
      return;
    }

    // Validate required dynamic fields
    for (var field in _fields) {
      if (field.required) {
        if (field.type == 'text' || field.type == 'textarea' || field.type == 'number') {
          if (_controllers[field.name]?.text.trim().isEmpty ?? true) {
            _showErrorSnackBar('Please enter ${field.label}');
            return;
          }
        } else if (field.type == 'dropdown') {
          if (_fieldValues[field.name] == null) {
            _showErrorSnackBar('Please select ${field.label}');
            return;
          }
        } else if (field.type == 'date') {
          if (_fieldValues[field.name] == null) {
            _showErrorSnackBar('Please select ${field.label}');
            return;
          }
        }
      }
    }

    // Collect all field values
    Map<String, String> fieldValues = {};
    for (var field in _fields) {
      if (field.type == 'text' || field.type == 'textarea' || field.type == 'number') {
        fieldValues[field.name] = _controllers[field.name]?.text ?? '';
      } else if (field.type == 'dropdown') {
        fieldValues[field.name] = _fieldValues[field.name]?.toString() ?? '';
      } else if (field.type == 'checkbox') {
        fieldValues[field.name] = (_fieldValues[field.name] ?? false).toString();
      } else if (field.type == 'date') {
        final date = _fieldValues[field.name] as DateTime?;
        fieldValues[field.name] = date?.toIso8601String() ?? '';
      } else if (field.type == 'file') {
        fieldValues[field.name] = _fieldValues[field.name]?.toString() ?? '';
      }
    }

    // Get the selected inspector name
    final personnelProvider = context.read<PersonnelProvider>();
    final selectedPersonnel = personnelProvider.getPersonnelById(_selectedInspectedById!);
    final inspectedByName =
        selectedPersonnel?.displayName?.isNotEmpty == true
            ? selectedPersonnel!.displayName!
            : selectedPersonnel?.fullName ?? 'Unknown';

    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Submission'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationRow('Report Date:', _selectedReportDate!.formatMediumDate),
                  _buildConfirmationRow('Status:', _selectedStatus.toUpperCase()),
                  _buildConfirmationRow('Item ID:', _itemIdController.text),
                  _buildConfirmationRow('Item No:', _itemNoController.text),
                  _buildConfirmationRow('Inspected By:', inspectedByName),
                  _buildConfirmationRow('Regulation:', _regulationController.text),

                  if (fieldValues.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Field Values:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.primary),
                    ),
                    const SizedBox(height: 8),
                    ...fieldValues.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('${e.key}: ${e.value.isEmpty ? "(empty)" : e.value}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitReportData(fieldValues);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.primary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReportData(Map<String, String> fieldValues) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<SystemProvider>();

      // Format the report date to ISO 8601 format with timezone
      final reportDateISO = _selectedReportDate!.toUtc().toIso8601String();

      // Transform field values to match API structure
      Map<String, Map<String, String>> reportData = {};
      fieldValues.forEach((key, value) {
        reportData[key] = {"value": value};
      });

      // Get the selected inspector name
      final personnelProvider = context.read<PersonnelProvider>();
      final selectedPersonnel = personnelProvider.getPersonnelById(_selectedInspectedById!);
      final inspectedByName =
          selectedPersonnel?.displayName?.isNotEmpty == true
              ? selectedPersonnel!.displayName!
              : selectedPersonnel?.fullName ?? 'Unknown';

      // Call the createReportData method from SystemProvider
      final result = await provider.createReportData(
        reportTypeId: widget.reportTypeId,
        itemId: widget.item.itemId ?? '',
        itemNo: widget.item.itemNo ?? '',
        status: _selectedStatus,
        inspectedBy: inspectedByName,
        reportDate: reportDateISO,
        regulation: _regulationController.text.trim(),
        reportData: reportData,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show success message with result info if available
        final message =
            result != null && result['message'] != null
                ? result['message']
                : 'Report submitted successfully for ${_selectedReportDate!.formatMediumDate}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Clear form after successful submission (optional)
        _clearForm();

        // Navigate back after successful submission
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            NavigationService().goBack();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Extract meaningful error message
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          errorMessage = errorMessage.replaceFirst('Exception: ', '');
        }
        if (errorMessage.contains('Failed to create report data: ')) {
          errorMessage = errorMessage.replaceFirst('Failed to create report data: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () => _submitReportData(fieldValues),
            ),
          ),
        );
      }
    }
  }

  void _clearForm() {
    // Clear all text controllers except pre-filled ones
    _regulationController.clear();

    for (var controller in _controllers.values) {
      controller.clear();
    }

    setState(() {
      _selectedReportDate = null;
      _selectedStatus = 'draft';
      _selectedInspectedById = null;
      _fieldValues.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.orange));
  }
}
