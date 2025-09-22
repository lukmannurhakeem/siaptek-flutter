import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/category_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
    });
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<CategoryProvider>().searchCategories(searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: context.paddingAll,
              child: Column(
                children: [
                  CommonTextField(
                    controller: searchController,
                    hintText: 'Search categories...',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
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
                              searchController.text.isEmpty
                                  ? 'No categories available'
                                  : 'No categories found matching "${searchController.text}"',
                              style: context.topology.textTheme.bodyMedium?.copyWith(
                                color: context.colors.primary.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: provider.refresh,
                          child: ListView.builder(
                            itemCount: provider.totalItemCount,
                            itemBuilder: (context, index) {
                              final category = provider.getCategoryByIndex(index);
                              if (category == null) return const SizedBox.shrink();

                              return _buildCategoryItem(context, provider, category, index);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                NavigationService().navigateTo(AppRoutes.createCategories);
              },
              tooltip: 'Add New',
              backgroundColor: context.colors.primary,
              child: const Icon(Icons.add),
            ),
          ),
        ],
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
        ),
        margin: EdgeInsets.only(
          left: category.level * context.spacing.xl, // Indent based on level
          bottom: context.spacing.xs,
        ),
        padding: EdgeInsets.symmetric(vertical: context.spacing.s, horizontal: context.spacing.m),
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
                      )
                      : _getIndentationIcon(category.level),
            ),
            context.hS,

            // Show numbering only for root level categories
            if (category.level == 0) ...[
              Text(
                '$visualIndex.',
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.hS,
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: _getCategoryTextStyle(context, category)),
                  if (category.categoryCode != null)
                    Text(
                      'Code: ${category.categoryCode}',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary.withOpacity(0.6),
                      ),
                    ),
                  if (category.description != null && category.description!.isNotEmpty)
                    Text(
                      category.description!,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary.withOpacity(0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Children count badge
            if (category.children.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.only(right: context.spacing.s),
                child: Chip(
                  label: Text(
                    '${category.children.length}',
                    style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                  backgroundColor: context.colors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            context.hM,

            if (category.canHaveChildItems)
              SizedBox(
                width: 100,
                child: CommonButton(
                  text: 'Create',
                  onPressed: () {
                    NavigationService().navigateTo(
                      AppRoutes.createCategories,
                      arguments: {'categoryId': category.id ?? ''},
                    );
                  },
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
        fontWeight: FontWeight.w500,
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
