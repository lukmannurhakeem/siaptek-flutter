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

  String _selectedFieldType = 'Text';
  bool _isReadOnly = false;
  bool _isRequired = false;
  String _selectedSection = '';

  @override
  void dispose() {
    _labelTextController.dispose();
    _nameController.dispose();
    _defaultValueController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final field = FieldModel(
        id: '',
        // Will be set by provider
        labelText: _labelTextController.text.trim(),
        name: _nameController.text.trim(),
        fieldType: _selectedFieldType,
        defaultValue: _defaultValueController.text.trim(),
        isReadOnly: _isReadOnly,
        required: _isRequired,
        section: _selectedSection,
      );

      context.read<CategoryProvider>().addField(field);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Field added successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldTypes = context.read<CategoryProvider>().availableFieldTypes;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600),
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
              CommonTextField(
                controller: _labelTextController,
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
              context.vS,
              CommonTextField(controller: _defaultValueController),
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
