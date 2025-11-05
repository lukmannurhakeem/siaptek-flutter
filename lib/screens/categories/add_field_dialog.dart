// add_field_dialog.dart - Updated with all field types
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/model/field_model.dart';
import 'package:base_app/providers/category_provider.dart';
import 'package:base_app/widget/common__checklist.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddFieldDialog extends StatefulWidget {
  const AddFieldDialog({Key? key}) : super(key: key);

  @override
  State<AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<AddFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelTextController = TextEditingController();
  final _nameController = TextEditingController();
  final _defaultValueController = TextEditingController();
  final _fileExtensionController = TextEditingController();
  final _conditionalSourceController = TextEditingController();
  final _conditionalValueController = TextEditingController();
  final _minValueController = TextEditingController();
  final _maxValueController = TextEditingController();
  final _stepValueController = TextEditingController();
  final _decimalPlacesController = TextEditingController();

  String _selectedFieldType = 'Text';
  bool _isReadOnly = false;
  bool _isRequired = false;
  String _selectedSection = '';
  String _conditionalOperator = 'equals';

  // For dropdown options
  final List<String> _dropdownOptions = [];
  final _dropdownOptionController = TextEditingController();

  @override
  void dispose() {
    _labelTextController.dispose();
    _nameController.dispose();
    _defaultValueController.dispose();
    _fileExtensionController.dispose();
    _conditionalSourceController.dispose();
    _conditionalValueController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    _stepValueController.dispose();
    _decimalPlacesController.dispose();
    _dropdownOptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final field = FieldModel(
        id: '',
        labelText: _labelTextController.text.trim(),
        name: _nameController.text.trim(),
        fieldType: _selectedFieldType,
        defaultValue: _defaultValueController.text.trim(),
        isReadOnly: _isReadOnly,
        required: _isRequired,
        section: _selectedSection,
        dropdownOptions: _dropdownOptions.isNotEmpty ? _dropdownOptions : null,
        fileExtension:
            _fileExtensionController.text.trim().isNotEmpty
                ? _fileExtensionController.text.trim()
                : null,
        conditionalSource:
            _conditionalSourceController.text.trim().isNotEmpty
                ? _conditionalSourceController.text.trim()
                : null,
        conditionalOperator: _conditionalOperator,
        conditionalValue:
            _conditionalValueController.text.trim().isNotEmpty
                ? _conditionalValueController.text.trim()
                : null,
        minValue: double.tryParse(_minValueController.text.trim()),
        maxValue: double.tryParse(_maxValueController.text.trim()),
        stepValue: double.tryParse(_stepValueController.text.trim()),
        decimalPlaces: int.tryParse(_decimalPlacesController.text.trim()),
      );

      context.read<CategoryProvider>().addField(field);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Field added successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildFieldTypeSpecificOptions() {
    switch (_selectedFieldType) {
      case 'Dropdown':
      case 'Override Dropdown':
        return _buildDropdownOptions();

      case 'Conditional Dropdown':
        return _buildConditionalDropdownOptions();

      case 'File':
        return _buildFileOptions();

      case 'Numeric':
        return _buildNumericOptions();

      case 'Decimal':
        return _buildDecimalOptions();

      case 'Checklist Item':
        return _buildChecklistOptions();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDropdownOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        context.vS,
        Text(
          'Dropdown Options',
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
        context.vXs,
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: _dropdownOptionController,
                hintText: 'Enter option',
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_dropdownOptionController.text.trim().isNotEmpty) {
                  setState(() {
                    _dropdownOptions.add(_dropdownOptionController.text.trim());
                    _dropdownOptionController.clear();
                  });
                }
              },
            ),
          ],
        ),
        if (_dropdownOptions.isNotEmpty) ...[
          context.vXs,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _dropdownOptions.map((option) {
                  return Chip(
                    label: Text(option),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _dropdownOptions.remove(option);
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildConditionalDropdownOptions() {
    return Column(
      children: [
        context.vS,
        CommonTextField(
          controller: _conditionalSourceController,
          hintText: 'Condition Source Field',
        ),
        context.vS,
        CommonDropdown(
          value: _conditionalOperator,
          items: const [
            DropdownMenuItem(value: 'equals', child: Text('Equals')),
            DropdownMenuItem(value: 'not_equals', child: Text('Not Equals')),
            DropdownMenuItem(value: 'contains', child: Text('Contains')),
            DropdownMenuItem(value: 'greater_than', child: Text('Greater Than')),
            DropdownMenuItem(value: 'less_than', child: Text('Less Than')),
          ],
          onChanged: (value) {
            setState(() {
              _conditionalOperator = value!;
            });
          },
        ),
        context.vS,
        CommonTextField(controller: _conditionalValueController, hintText: 'Condition Value'),
        _buildDropdownOptions(),
      ],
    );
  }

  Widget _buildFileOptions() {
    return Column(
      children: [
        context.vS,
        CommonTextField(
          controller: _fileExtensionController,
          hintText: 'File Extension (e.g., .pdf, .jpg)',
        ),
      ],
    );
  }

  Widget _buildNumericOptions() {
    return Column(
      children: [
        context.vS,
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: _minValueController,
                hintText: 'Min Value',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CommonTextField(
                controller: _maxValueController,
                hintText: 'Max Value',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        context.vS,
        CommonTextField(
          controller: _stepValueController,
          hintText: 'Step Value',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDecimalOptions() {
    return Column(
      children: [
        context.vS,
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: _minValueController,
                hintText: 'Min Value',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CommonTextField(
                controller: _maxValueController,
                hintText: 'Max Value',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        context.vS,
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: _stepValueController,
                hintText: 'Step Value',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CommonTextField(
                controller: _decimalPlacesController,
                hintText: 'Decimal Places',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistOptions() {
    return Column(
      children: [
        context.vS,
        CommonTextField(
          controller: _defaultValueController,
          hintText: 'Checklist Values (comma-separated)',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldTypes = context.read<CategoryProvider>().availableFieldTypes;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Field',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  CommonButton.iconOnly(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icons.close,
                  ),
                ],
              ),
              context.vM,

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonTextField(
                        controller: _labelTextController,
                        hintText: 'Label Text',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Label Text is required';
                          }
                          return null;
                        },
                      ),
                      context.vS,
                      CommonTextField(
                        controller: _nameController,
                        hintText: 'Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      context.vS,
                      CommonDropdown(
                        value: _selectedFieldType,
                        items:
                            fieldTypes.map((type) {
                              return DropdownMenuItem(value: type, child: Text(type));
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFieldType = value!;
                          });
                        },
                      ),

                      // Field type specific options
                      _buildFieldTypeSpecificOptions(),

                      // Only show default value for non-specialized fields
                      if (![
                        'Dropdown',
                        'Override Dropdown',
                        'Conditional Dropdown',
                        'Checklist Item',
                      ].contains(_selectedFieldType)) ...[
                        context.vS,
                        CommonTextField(
                          controller: _defaultValueController,
                          hintText: 'Default Value',
                        ),
                      ],

                      context.vS,
                      CommonChecklistTile(
                        title: 'Is Read Only',
                        value: _isReadOnly,
                        onChanged: (value) {
                          setState(() {
                            _isReadOnly = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      CommonChecklistTile(
                        title: 'Required',
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('OK'),
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
