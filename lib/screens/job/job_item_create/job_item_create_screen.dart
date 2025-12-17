import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/providers/category_provider.dart';
import 'package:INSPECT/providers/job_provider.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobItemCreateScreen extends StatefulWidget {
  final String jobId;

  const JobItemCreateScreen({super.key, required this.jobId});

  @override
  State<JobItemCreateScreen> createState() => _JobItemCreateScreenState();
}

class _JobItemCreateScreenState extends State<JobItemCreateScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _itemNoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailedLocationController = TextEditingController();
  final TextEditingController _internalNotesController = TextEditingController();
  final TextEditingController _externalNotesController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _manufacturerAddressController = TextEditingController();
  final TextEditingController _manufacturerDateController = TextEditingController();
  final TextEditingController _firstUseDateController = TextEditingController();

  CategoryItem? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _itemNoController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _detailedLocationController.dispose();
    _internalNotesController.dispose();
    _externalNotesController.dispose();
    _manufacturerController.dispose();
    _manufacturerAddressController.dispose();
    _manufacturerDateController.dispose();
    _firstUseDateController.dispose();
    super.dispose();
  }

  void _showCategorySelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => CategorySelectionDialog(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
                _categoryController.text = category.name;
              });
            },
            selectedCategory: _selectedCategory,
          ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: context.colors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, {IconData? icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    'Category *',
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: _showCategorySelectionDialog,
            child: AbsorbPointer(
              child: CommonTextField(
                controller: _categoryController,
                hintText: 'Select a category',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
                suffixIcon: Icon(Icons.arrow_drop_down, color: context.colors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    String title,
    TextEditingController controller, {
    int maxLines = 1,
    bool isRequired = false,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    title + (isRequired ? ' *' : ''),
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: isRequired ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: controller,
            maxLines: maxLines,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Basic Information', Icons.info_outline),
        context.vM,
        _buildCategoryRow(context, icon: Icons.category),
        context.vS,
        _buildRow(context, 'Item No', _itemNoController, isRequired: true, icon: Icons.tag),
        context.vS,
        _buildRow(
          context,
          'Description',
          _descriptionController,
          maxLines: 3,
          icon: Icons.description,
        ),
        context.vL,
        _buildSectionHeader(context, 'Location Details', Icons.location_on),
        context.vM,
        _buildRow(context, 'Location', _locationController, icon: Icons.place),
        context.vS,
        _buildRow(
          context,
          'Detailed Location',
          _detailedLocationController,
          maxLines: 2,
          icon: Icons.my_location,
        ),
        context.vL,
        _buildSectionHeader(context, 'Manufacturer Information', Icons.factory),
        context.vM,
        _buildRow(
          context,
          'Manufacturer',
          _manufacturerController,
          maxLines: 3,
          icon: Icons.business,
        ),
        context.vS,
        _buildRow(
          context,
          'Manufacturer Address',
          _manufacturerAddressController,
          maxLines: 3,
          icon: Icons.home,
        ),
        context.vS,
        _buildRow(
          context,
          'Manufacture Date',
          _manufacturerDateController,
          icon: Icons.calendar_today,
        ),
        context.vS,
        _buildRow(context, 'First Use Date', _firstUseDateController, icon: Icons.event),
        context.vL,
        _buildSectionHeader(context, 'Notes', Icons.note_outlined),
        context.vM,
        _buildRow(
          context,
          'Internal Notes',
          _internalNotesController,
          maxLines: 3,
          icon: Icons.notes,
        ),
        context.vS,
        _buildRow(
          context,
          'External Notes',
          _externalNotesController,
          maxLines: 3,
          icon: Icons.speaker_notes,
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Basic Information', Icons.info_outline),
                        context.vM,
                        _buildCategoryRow(context, icon: Icons.category),
                        context.vS,
                        _buildRow(
                          context,
                          'Item No',
                          _itemNoController,
                          isRequired: true,
                          icon: Icons.tag,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Description',
                          _descriptionController,
                          maxLines: 3,
                          icon: Icons.description,
                        ),
                        context.vL,
                        _buildSectionHeader(context, 'Location Details', Icons.location_on),
                        context.vM,
                        _buildRow(context, 'Location', _locationController, icon: Icons.place),
                        context.vS,
                        _buildRow(
                          context,
                          'Detailed Location',
                          _detailedLocationController,
                          maxLines: 2,
                          icon: Icons.my_location,
                        ),
                      ],
                    ),
                  ),
                ),
                context.hXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, 'Manufacturer Information', Icons.factory),
                        context.vM,
                        _buildRow(
                          context,
                          'Manufacturer',
                          _manufacturerController,
                          maxLines: 3,
                          icon: Icons.business,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Manufacturer Address',
                          _manufacturerAddressController,
                          maxLines: 3,
                          icon: Icons.home,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'Manufacture Date',
                          _manufacturerDateController,
                          icon: Icons.calendar_today,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'First Use Date',
                          _firstUseDateController,
                          icon: Icons.event,
                        ),
                        context.vL,
                        _buildSectionHeader(context, 'Notes', Icons.note_outlined),
                        context.vM,
                        _buildRow(
                          context,
                          'Internal Notes',
                          _internalNotesController,
                          maxLines: 3,
                          icon: Icons.notes,
                        ),
                        context.vS,
                        _buildRow(
                          context,
                          'External Notes',
                          _externalNotesController,
                          maxLines: 3,
                          icon: Icons.speaker_notes,
                        ),
                        context.vS,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          context.vL,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: CommonButton(
                  text: _isLoading ? 'Saving...' : 'Save Item',
                  onPressed: _isLoading ? null : _saveJobItem,
                ),
              ),
            ],
          ),
          context.vM,
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          context.vM,
          _buildFormFields(context),
          context.vL,
          CommonButton(
            text: _isLoading ? 'Saving...' : 'Save Item',
            onPressed: _isLoading ? null : _saveJobItem,
          ),
          context.vL,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_box, color: context.colors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Create Job Item',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: context.colors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Saving job item...',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                )
                : (context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context)),
      ),
    );
  }

  void _saveJobItem() {
    // Validate required fields
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Please select a category')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_itemNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Please enter an item number')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final jobItemData = {
      'jobID': widget.jobId,
      'categoryName': _selectedCategory!.name,
      "categoryID": _selectedCategory!.id,
      'itemNo': _itemNoController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'detailedLocation': _detailedLocationController.text.trim(),
      "internalNotes": _internalNotesController.text.trim(),
      "externalNotes": _externalNotesController.text.trim(),
      "manufacturer": _manufacturerController.text.trim(),
      "manufacturerAddress": _manufacturerAddressController.text.trim(),
      // "manufacturerDate": _manufacturerDateController.text.trim(),
      // "firstUseDate": _firstUseDateController.text.trim(),
    };

    context
        .read<JobProvider>()
        .createJobItem(context, jobItemData, widget.jobId)
        .then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Error: ${error.toString()}')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
  }
}

// CategorySelectionDialog remains the same
class CategorySelectionDialog extends StatefulWidget {
  final Function(CategoryItem) onCategorySelected;
  final CategoryItem? selectedCategory;

  const CategorySelectionDialog({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<CategorySelectionDialog> createState() => _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  CategoryItem? _tempSelectedCategory;

  @override
  void initState() {
    super.initState();
    _tempSelectedCategory = widget.selectedCategory;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<CategoryProvider>().searchCategories(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Category',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            CommonTextField(
              controller: _searchController,
              hintText: 'Search categories...',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
              suffixIcon: Icon(Icons.search, color: context.colors.primary),
            ),
            context.vM,
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.errorMessage!,
                            style: context.topology.textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.totalItemCount == 0) {
                    return Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No categories available'
                            : 'No categories found matching "${_searchController.text}"',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.totalItemCount,
                    itemBuilder: (context, index) {
                      final category = provider.getCategoryByIndex(index);
                      if (category == null) return const SizedBox.shrink();

                      return _buildCategorySelectionItem(context, provider, category);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _tempSelectedCategory != null
                          ? () {
                            widget.onCategorySelected(_tempSelectedCategory!);
                            Navigator.of(context).pop();
                          }
                          : null,
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionItem(
    BuildContext context,
    CategoryProvider provider,
    CategoryItem category,
  ) {
    final isSelected = _tempSelectedCategory?.id == category.id;

    return GestureDetector(
      onTap: () {
        if (category.children.isNotEmpty) {
          provider.toggleExpansion(category);
        }
        setState(() {
          _tempSelectedCategory = category;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? context.colors.primary.withOpacity(0.1)
                  : _getCategoryBackgroundColor(context, category),
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? Border.all(color: context.colors.primary, width: 1) : null,
        ),
        margin: EdgeInsets.only(left: category.level * 16.0, bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child:
                  category.children.isNotEmpty
                      ? Icon(
                        category.isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: context.colors.primary,
                        size: 18,
                      )
                      : _getIndentationIcon(category.level),
            ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? context.colors.primary : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? context.colors.primary : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: _getCategoryTextStyle(context, category, isSelected)),
                  if (category.categoryCode != null)
                    Text(
                      'Code: ${category.categoryCode}',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  if (category.description != null && category.description!.isNotEmpty)
                    Text(
                      category.description!,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary.withOpacity(0.5),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (category.children.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${category.children.length}',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryBackgroundColor(BuildContext context, CategoryItem category) {
    if (category.level == 0) {
      return Colors.transparent;
    } else {
      double opacity = 0.02 + (category.level * 0.01);
      return context.colors.primary.withOpacity(opacity);
    }
  }

  TextStyle? _getCategoryTextStyle(BuildContext context, CategoryItem category, bool isSelected) {
    if (category.level == 0) {
      return context.topology.textTheme.bodyMedium?.copyWith(
        color: isSelected ? context.colors.primary : context.colors.primary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      );
    } else {
      return context.topology.textTheme.bodySmall?.copyWith(
        color: isSelected ? context.colors.primary : context.colors.primary.withOpacity(0.8),
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      );
    }
  }

  Widget? _getIndentationIcon(int level) {
    if (level == 0) return null;

    return Icon(
      level == 1 ? Icons.subdirectory_arrow_right : Icons.more_horiz,
      color: Colors.grey.withOpacity(0.6),
      size: 14,
    );
  }
}
