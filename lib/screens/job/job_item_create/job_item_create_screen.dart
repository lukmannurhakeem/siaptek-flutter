import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/category_provider.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobItemCreateScreen extends StatefulWidget {
  const JobItemCreateScreen({super.key});

  @override
  State<JobItemCreateScreen> createState() => _JobItemCreateScreenState();
}

class _JobItemCreateScreenState extends State<JobItemCreateScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _itemNoController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailedLocationController = TextEditingController();

  CategoryItem? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load categories when screen initializes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Job Item',
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
        actions: [
          TextButton(
            onPressed: _saveJobItem,
            child: Text('Save', style: TextStyle(color: context.colors.primary)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildFormFields(context)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [_buildFormFields(context)]));
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        _buildCategoryRow(context),
        context.vM,
        _buildRow(context, 'Item No', _itemNoController),
        context.vM,
        _buildRow(context, 'Description', _descriptionController, maxLines: 3),
        context.vM,
        _buildRow(context, 'Location', _locationController),
        context.vM,
        _buildRow(context, 'Detailed Location', _detailedLocationController, maxLines: 2),
        context.vM,
        _buildRow(context, 'Internal Notes', _descriptionController, maxLines: 3),
        context.vM,
        _buildRow(context, 'External Notes', _descriptionController, maxLines: 3),
        context.vM,
        _buildRow(context, 'Manufacturer', _descriptionController, maxLines: 3),
        context.vM,
        _buildRow(context, 'Manufacturer Address', _descriptionController, maxLines: 3),
        context.vM,
        _buildRow(context, 'Manufacture Date', _locationController),
        context.vM,
        _buildRow(context, 'First Use Date', _locationController),
      ],
    );
  }

  Widget _buildCategoryRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Category *',
              style: context.topology.textTheme.titleSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
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
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              title,
              style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
            ),
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

  void _saveJobItem() {
    // Validate required fields
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_itemNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item number'), backgroundColor: Colors.red),
      );
      return;
    }

    // TODO: Implement save logic here
    // You can access the form data like this:
    final jobItemData = {
      'categoryId': _selectedCategory!.id,
      'categoryName': _selectedCategory!.name,
      'itemNo': _itemNoController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'detailedLocation': _detailedLocationController.text.trim(),
    };

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job item saved successfully'), backgroundColor: Colors.green),
    );

    // Navigate back
    NavigationService().goBack();
  }
}

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
            // Header
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

            // Search field
            CommonTextField(
              controller: _searchController,
              hintText: 'Search categories...',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
              suffixIcon: Icon(Icons.search, color: context.colors.primary),
            ),
            context.vM,

            // Category list
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

            // Action buttons
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
        margin: EdgeInsets.only(
          left: category.level * 16.0, // Indent based on level
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // Expansion indicator
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

            // Selection indicator
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

            // Children count badge
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
      // Different opacity for different levels
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
