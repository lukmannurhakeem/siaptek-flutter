import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/category_provider.dart';
import 'package:base_app/screens/categories/add_field_dialog.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesCreateScreen extends StatefulWidget {
  final String? categoryId;

  const CategoriesCreateScreen({super.key, this.categoryId});

  @override
  State<CategoriesCreateScreen> createState() => _CategoriesCreateScreenState();
}

class _CategoriesCreateScreenState extends State<CategoriesCreateScreen> {
  // Form controllers for category creation
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _categoryCodeController = TextEditingController();
  final _parentCategoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionTemplateController = TextEditingController();
  final _instructionController = TextEditingController();
  final _noteController = TextEditingController();
  final _replacementPeriodController = TextEditingController();

  bool _isEditMode = false;
  bool _hasPopulatedFields = false;

  bool _showArchived = false;
  bool _canHaveChild = false;
  bool _isWithdrawn = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = (widget.categoryId != null && widget.categoryId != '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CategoryProvider>();
      print('Henlo : ${widget.categoryId}');

      // Always fetch categories for parent selection
      provider.fetchCategories();

      // If categoryId is provided, fetch specific category for editing
      if (widget.categoryId != null && widget.categoryId != '') {
        print('Henlo here');
        provider.fetchCategoryById(widget.categoryId!);
      }
    });
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryCodeController.dispose();
    _parentCategoryController.dispose();
    _descriptionController.dispose();
    _descriptionTemplateController.dispose();
    _instructionController.dispose();
    _noteController.dispose();
    _replacementPeriodController.dispose();
    super.dispose();
  }

  void _populateFieldsFromCategory() {
    final provider = context.read<CategoryProvider>();
    if (provider.categoryById?.data != null && !_hasPopulatedFields) {
      final data = provider.categoryById!.data;

      _categoryNameController.text = data?.categoryName?.toString() ?? '';
      _categoryCodeController.text = data?.categoryCode?.toString() ?? '';
      _descriptionController.text = data?.description?.toString() ?? '';
      _descriptionTemplateController.text = data?.descriptionTemplate?.toString() ?? '';
      _instructionController.text = data?.instructions?.toString() ?? '';
      _parentCategoryController.text = data?.parentId?.toString() ?? '';
      _noteController.text = data?.notes?.toString() ?? '';
      _replacementPeriodController.text = data?.replacementPeriod?.toString() ?? '';
      _hasPopulatedFields = true;
      _canHaveChild = data?.canHaveChildItems ?? false;
      _isWithdrawn = data?.isWithdrawn ?? false;
    }
  }

  void toggleCanHaveChild() {
    setState(() {
      _canHaveChild = !_canHaveChild;
    });
  }

  void toggleIsWithdrawn() {
    setState(() {
      _isWithdrawn = !_isWithdrawn;
    });
  }

  Future<void> _handleSaveCategory() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<CategoryProvider>();

      final success = await provider.createCategory(
        categoryId: _isEditMode ? widget.categoryId : null,
        categoryName: _categoryNameController.text.trim(),
        categoryCode: _categoryCodeController.text.trim(),
        description: _descriptionController.text.trim(),
        descriptionTemplate: _descriptionTemplateController.text.trim(),
        replacementPeriod: int.tryParse(_replacementPeriodController.text.trim()),
        canHaveChildItems: provider.showCanHaveChild,
        instructions: _instructionController.text,
        notes: _noteController.text,
        // Add other optional parameters as needed
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode ? 'Category updated successfully!' : 'Category created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form state before navigating back
          provider.resetFormState();
          NavigationService().goBack();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.createErrorMessage ??
                    'Failed to ${_isEditMode ? 'update' : 'create'} category',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Category' : 'Create Category',
          style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
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
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (_isEditMode && provider.categoryById != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateFieldsFromCategory();
            });
          }

          return SingleChildScrollView(
            padding: context.paddingHorizontal,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show loading indicator if creating or loading category by ID
                  if (provider.isCreating || (_isEditMode && provider.isLoadingById))
                    const LinearProgressIndicator(),

                  // Show error for category creation
                  if (provider.createErrorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.createErrorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            onPressed: provider.clearCreateError,
                            icon: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                  // Show error for fetching category by ID
                  if (_isEditMode && provider.errorMessageById != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessageById!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            onPressed: provider.clearCategoryById,
                            icon: const Icon(Icons.close, color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                  _widgetForm('Category Name', controller: _categoryNameController, required: true),
                  context.vS,
                  _widgetForm('Code', controller: _categoryCodeController, required: true),
                  context.vS,
                  _widgetForm(
                    'Parent Category',
                    controller: _parentCategoryController,
                    required: false,
                  ),
                  context.vS,
                  _widgetForm('Description', controller: _descriptionController, required: true),
                  context.vS,
                  _widgetForm(
                    'Description Template',
                    controller: _descriptionTemplateController,
                    required: true,
                  ),
                  context.vM,
                  context.divider,
                  context.vM,

                  // Fields section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200,
                            child: CommonButton(
                              icon: Icons.add,
                              text: 'New Field',
                              onPressed: () {
                                _showAddFieldDialog(context);
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: provider.showArchived,
                                onChanged: (_) => provider.toggleShowArchived(),
                              ),
                              Text(
                                'Show Archived Fields',
                                style: context.topology.textTheme.titleMedium?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      context.vM,

                      // Dynamic DataTable that fills available width
                      SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width -
                                  (context.paddingHorizontal.horizontal),
                            ),
                            child: DataTable(
                              columnSpacing: 20,
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Label Text',
                                    style: context.topology.textTheme.titleSmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Field Type',
                                    style: context.topology.textTheme.titleSmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Default Value',
                                    style: context.topology.textTheme.titleSmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Create/Edit Permissions',
                                    style: context.topology.textTheme.titleSmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'View Permissions',
                                    style: context.topology.textTheme.titleSmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Actions',
                                    style: context.topology.textTheme.titleSmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                              ],
                              rows:
                                  provider.fields.map((field) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Row(
                                            children: [
                                              if (field.required)
                                                const Text(
                                                  '* ',
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                              Text(
                                                field.labelText,
                                                style: context.topology.textTheme.bodySmall
                                                    ?.copyWith(color: context.colors.primary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            field.fieldType,
                                            style: context.topology.textTheme.bodySmall?.copyWith(
                                              color: context.colors.primary,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            field.defaultValue,
                                            style: context.topology.textTheme.bodySmall?.copyWith(
                                              color: context.colors.primary,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            field.permissions['create'] ?? 'Any',
                                            style: context.topology.textTheme.bodySmall?.copyWith(
                                              color: context.colors.primary,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            field.permissions['view'] ?? 'Any',
                                            style: context.topology.textTheme.bodySmall?.copyWith(
                                              color: context.colors.primary,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              _showDeleteConfirmation(
                                                context,
                                                field.id,
                                                field.labelText,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),

                      context.vS,
                      _widgetForm(
                        'Replacement Period',
                        controller: _replacementPeriodController,
                        required: false,
                      ),
                      context.vS,
                      _widgetForm(
                        'Instructions',
                        controller: _instructionController,
                        required: true,
                      ),
                      context.vS,
                      _widgetForm('Note', controller: _noteController, required: true),

                      context.vS,
                      _widgetFormCheckList(
                        'Can Have Child Item',
                        value: _canHaveChild,
                        onChanged: (val) => toggleCanHaveChild(),
                      ),
                      context.vS,
                      _widgetFormCheckList(
                        'Withdraw',
                        value: _isWithdrawn,
                        onChanged: (val) => toggleIsWithdrawn(),
                      ),
                      context.vL,
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          alignment: Alignment.centerRight,
                          width: 200,
                          child: CommonButton(
                            icon: _isEditMode ? Icons.update : Icons.save,
                            text:
                                provider.isCreating
                                    ? (_isEditMode ? 'Updating...' : 'Saving...')
                                    : (_isEditMode ? 'Update' : 'Save'),
                            onPressed: provider.isCreating ? null : _handleSaveCategory,
                          ),
                        ),
                      ),
                      context.vXxl,
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _widgetForm(String text, {TextEditingController? controller, bool required = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (required) const Text('* ', style: TextStyle(color: Colors.red)),
              Text(
                text,
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: controller,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            validator:
                required
                    ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '$text is required';
                      }
                      return null;
                    }
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _widgetFormCheckList(
    String text, {
    bool value = false,
    bool required = false,
    ValueChanged<bool?>? onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (required) const Text('* ', style: TextStyle(color: Colors.red)),
              Flexible(
                child: Text(
                  text,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [Flexible(child: Checkbox(value: value, onChanged: onChanged))],
          ),
        ),
      ],
    );
  }

  void _showAddFieldDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddFieldDialog());
  }

  void _showDeleteConfirmation(BuildContext context, String fieldId, String fieldName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Field'),
            content: Text('Are you sure you want to delete "$fieldName"?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  context.read<CategoryProvider>().removeField(fieldId);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Field deleted successfully!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
