import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/providers/category_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
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
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.totalItemCount == 0 && !provider.isLoading) {
          return _buildEmptyState(context);
        }

        return context.isTablet
            ? _buildTabletLayout(context, provider)
            : _buildMobileLayout(context, provider);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      children: [
        // Background image (fixed at bottom right)
        Positioned(
          bottom: 0,
          right: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/bg_4.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
        // Empty state content
        SizedBox(
          width: double.infinity,
          height: context.screenHeight - kToolbarHeight * 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              context.vXxl,
              Text(
                'You do not have categories right now',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
      
              Text(
                'Add your first category to get started',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary.withOpacity(0.7),
                ),
              ),
              context.vL,
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.createCategories);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, CategoryProvider provider) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          // Background image (fixed at bottom right)
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/bg_4.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
          // Foreground scrollable content
          Padding(
            padding: context.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed "Create" button with tooltip
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createCategories);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Category'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search categories...',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: context.colors.primary),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      Icon(Icons.search, color: context.colors.primary),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                context.vM,
                // Result count with helper text
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${provider.totalItemCount} ${provider.totalItemCount != 1 ? 'categories' : 'category'} found',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      Text(
                        'Click categories to expand/collapse',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(child: _buildCategoryList(context, provider)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CategoryProvider provider) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          // Background image (fixed at bottom right)
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/bg_4.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
          // Foreground scrollable content
          Padding(
            padding: context.paddingAll,
            child: Column(
              children: [
                // Create Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.createCategories);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search categories...',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: context.colors.primary),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      Icon(Icons.search, color: context.colors.primary),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                context.vM,
                // Result count
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.totalItemCount} ${provider.totalItemCount != 1 ? 'categories' : 'category'} found',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to expand/collapse categories',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _buildCategoryList(context, provider)),
              ],
            ),
          ),
          // Floating action button
          if (provider.totalItemCount > 0)
            Positioned(
              bottom: 50,
              right: 30,
              child: FloatingActionButton(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.createCategories);
                },
                tooltip: 'Add New Category',
                backgroundColor: context.colors.primary,
                child: const Icon(Icons.add),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, CategoryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => provider.refresh(), child: const Text('Retry')),
          ],
        ),
      );
    }

    if (provider.totalItemCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: context.colors.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Try adding a new category'
                  : 'Try adjusting your search',
              style: context.topology.textTheme.bodySmall?.copyWith(
                color: context.colors.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: provider.totalItemCount,
          itemBuilder: (context, index) {
            final category = provider.getCategoryByIndex(index);
            if (category == null) return const SizedBox.shrink();

            return _buildCategoryItem(context, provider, category, index);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryProvider provider,
    CategoryItem category,
    int index,
  ) {
    // Calculate visual index for numbering (only count items at level 0)
    int visualIndex = 1;
    for (int i = 0; i < index; i++) {
      final prevCategory = provider.getCategoryByIndex(i);
      if (prevCategory?.level == 0) {
        visualIndex++;
      }
    }

    return GestureDetector(
      onTap: () {
        if (category.children.isNotEmpty) {
          provider.toggleExpansion(category);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getCategoryBackgroundColor(context, category, index),
          borderRadius: BorderRadius.circular(4),
          border:
              category.level == 0
                  ? Border.all(color: context.colors.primary.withOpacity(0.1), width: 0.5)
                  : null,
        ),
        margin: EdgeInsets.only(left: category.level * 24.0, bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Expansion indicator
            SizedBox(
              width: 24,
              child:
                  category.children.isNotEmpty
                      ? Icon(
                        category.isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: context.colors.primary,
                        size: 20,
                      )
                      : _getIndentationIcon(category.level),
            ),
            const SizedBox(width: 8),

            // Show numbering only for root level categories
            if (category.level == 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$visualIndex',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(category.name, style: _getCategoryTextStyle(context, category)),
                      ),
                      if (category.level > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sub',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (category.categoryCode != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${category.categoryCode}',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary.withOpacity(0.6),
                      ),
                    ),
                  ],
                  if (category.description != null && category.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      category.description!,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary.withOpacity(0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Children count badge
            if (category.children.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.subdirectory_arrow_right, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${category.children.length}',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons
            SizedBox(
              width: 100,
              child: CommonButton(
                text: 'View',
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.categoryDetails, arguments: category);
                },
              ),
            ),
            const SizedBox(width: 8),

            // Add Sub-category button - creates child category under this parent
            if (category.canHaveChildItems)
              Tooltip(
                message: 'Create a sub-category under "${category.name}"',
                child: SizedBox(
                  width: 110,
                  child: CommonButton(
                    text: '+ Child',
                    onPressed: () {
                      NavigationService().navigateTo(
                        AppRoutes.createCategories,
                        arguments: {'categoryId': category.id ?? ''},
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryBackgroundColor(BuildContext context, CategoryItem category, int index) {
    if (category.level == 0) {
      return index.isEven ? context.colors.primary.withOpacity(0.05) : Colors.transparent;
    } else {
      // Different opacity for different levels
      double opacity = 0.02 + (category.level * 0.01);
      return context.colors.primary.withOpacity(opacity);
    }
  }

  TextStyle? _getCategoryTextStyle(BuildContext context, CategoryItem category) {
    if (category.level == 0) {
      return context.topology.textTheme.bodyMedium?.copyWith(
        color: context.colors.primary,
        fontWeight: FontWeight.w600,
      );
    } else {
      return context.topology.textTheme.bodySmall?.copyWith(
        color: context.colors.primary.withOpacity(0.8),
      );
    }
  }

  Widget? _getIndentationIcon(int level) {
    if (level == 0) return null;

    return Icon(
      level == 1 ? Icons.subdirectory_arrow_right : Icons.more_horiz,
      color: Colors.grey.withOpacity(0.6),
      size: 16,
    );
  }
}
