import 'package:INSPECT/core/extension/date_time_extension.dart';
import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/providers/category_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_dialog.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class JobRegisterModel {
  final String id;
  final String item;
  final String description;
  final String category;
  final String location;
  final String status;
  final DateTime inspectedOn;
  final DateTime? expiryDate;
  final String archived;

  JobRegisterModel({
    required this.id,
    required this.item,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.inspectedOn,
    required this.expiryDate,
    required this.archived,
  });
}

class CategoryDetails extends StatefulWidget {
  const CategoryDetails({super.key});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> with TickerProviderStateMixin {
  late TabController _tabController;
  CategoryItem? selectedCategory;
  int sortColumnIndex = 0;
  Set<int> selectedRows = <int>{};
  bool selectAll = false;
  TextEditingController searchController = TextEditingController();
  List<JobRegisterModel> filteredList = [];

  final List<Tab> tabs = const [
    Tab(text: 'Overview'),
    Tab(text: 'Items'),
    Tab(text: 'Active Items'),
    Tab(text: 'Pending Items'),
    Tab(text: 'Archived Items'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    searchController.addListener(_onSearchChanged);

    // Get category data from navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is CategoryItem) {
        setState(() {
          selectedCategory = args;
          _loadCategoryItems();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterItems();
  }

  void _filterItems() {
    setState(() {
      final query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredList = List.from(_getCategoryItems());
      } else {
        filteredList =
            _getCategoryItems().where((item) {
              return item.item.toLowerCase().contains(query) ||
                  item.description.toLowerCase().contains(query) ||
                  item.category.toLowerCase().contains(query) ||
                  item.location.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  // Load items for the selected category
  void _loadCategoryItems() {
    if (selectedCategory == null) return;

    // Generate sample items based on the category
    final categoryItems = _generateSampleItemsForCategory(selectedCategory!);
    setState(() {
      filteredList = categoryItems;
    });
  }

  // Generate sample data based on category
  List<JobRegisterModel> _generateSampleItemsForCategory(CategoryItem category) {
    // This would normally come from an API call
    // For now, generating sample data based on category

    final List<JobRegisterModel> items = [];

    // Generate 3-5 sample items per category
    for (int i = 1; i <= 4; i++) {
      items.add(
        JobRegisterModel(
          id: '${category.id}_$i',
          item: '${category.name} Item $i',
          description: 'Sample ${category.name.toLowerCase()} item for testing purposes',
          category: category.name,
          location: 'Location ${String.fromCharCode(64 + i)}',
          // A, B, C, D
          status: _getRandomStatus(),
          inspectedOn: DateTime.now().subtract(Duration(days: i * 5)),
          expiryDate: DateTime.now().add(Duration(days: 30 + (i * 10))),
          archived: i == 4 ? 'Archived' : 'Active',
        ),
      );
    }

    return items;
  }

  String _getRandomStatus() {
    final statuses = ['Accepted', 'Pending', 'Rejected'];
    return statuses[DateTime.now().millisecond % 3];
  }

  List<JobRegisterModel> _getCategoryItems() {
    return filteredList;
  }

  // Filter list based on current tab
  List<JobRegisterModel> _getFilteredList() {
    final baseList = _getCategoryItems();

    switch (_tabController.index) {
      case 0: // Overview - show category info
        return [];
      case 1: // All Items
        return baseList;
      case 2: // Active
        return baseList.where((item) => item.status.toLowerCase() == 'accepted').toList();
      case 3: // Pending
        return baseList.where((item) => item.status.toLowerCase() == 'pending').toList();
      case 4: // Archived
        return baseList.where((item) => item.archived.toLowerCase() == 'archived').toList();
      default:
        return baseList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory?.name ?? 'Category Details',
          style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body:
          selectedCategory == null
              ? Center(
                child: Text(
                  'No category data found',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              )
              : Padding(
                padding: context.paddingHorizontal,
                child: Column(
                  children: [
                    // Search bar (only show for non-overview tabs)
                    if (_tabController.index > 0) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CommonTextField(
                          controller: searchController,
                          hintText: 'Search items...',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                          ),
                          suffixIcon: Icon(Icons.search, color: context.colors.primary),
                        ),
                      ),
                    ],

                    // Tab bar
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        tabs: tabs,
                        labelColor: context.colors.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: context.colors.primary,
                        indicatorWeight: 3,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        padding: EdgeInsets.zero,
                        onTap: (index) {
                          setState(() {
                            // Clear selections when switching tabs
                            selectedRows.clear();
                            selectAll = false;
                            _filterItems(); // Re-apply filters
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(), // Overview
                          _buildItemsTab(), // All Items
                          _buildItemsTab(), // Active
                          _buildItemsTab(), // Pending
                          _buildItemsTab(), // Archived
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: _tabController.index > 0 ? _buildFloatingActionButton(context) : null,
    );
  }

  Widget _buildOverviewTab() {
    if (selectedCategory == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Information',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow('Category Name', selectedCategory!.name),
                  if (selectedCategory!.categoryCode != null)
                    _buildInfoRow('Category Code', selectedCategory!.categoryCode!),
                  _buildInfoRow('Category ID', selectedCategory!.id),
                  if (selectedCategory!.description != null)
                    _buildInfoRow('Description', selectedCategory!.description!),
                  _buildInfoRow(
                    'Can Have Child Items',
                    selectedCategory!.canHaveChildItems ? 'Yes' : 'No',
                  ),
                  if (selectedCategory!.parentId != null)
                    _buildInfoRow('Parent ID', selectedCategory!.parentId!),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Items',
                          _getCategoryItems().length.toString(),
                          Icons.inventory,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Active Items',
                          _getCategoryItems()
                              .where((item) => item.status.toLowerCase() == 'accepted')
                              .length
                              .toString(),
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending Items',
                          _getCategoryItems()
                              .where((item) => item.status.toLowerCase() == 'pending')
                              .length
                              .toString(),
                          Icons.pending,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Child Categories',
                          selectedCategory!.children.length.toString(),
                          Icons.category,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (selectedCategory!.children.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Child Categories',
                      style: context.topology.textTheme.titleMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...selectedCategory!.children.map(
                      (child) => ListTile(
                        title: Text(child.name),
                        subtitle:
                            child.categoryCode != null ? Text('Code: ${child.categoryCode}') : null,
                        leading: Icon(Icons.subdirectory_arrow_right),
                        onTap: () {
                          // Navigate to child category
                          NavigationService().navigateTo(
                            AppRoutes.categoryDetails,
                            arguments: child,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: context.topology.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.primary.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Icon(icon, color: context.colors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.topology.textTheme.titleLarge?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: context.colors.primary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTab() {
    final filteredList = _getFilteredList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: context.colors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchController.text.isEmpty
                  ? 'No items found in this category'
                  : 'No items match your search criteria',
              style: context.topology.textTheme.bodyMedium?.copyWith(
                color: context.colors.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return context.isTablet
        ? _buildTabletView(context, filteredList)
        : _buildMobileView(context, filteredList);
  }

  Widget _buildTabletView(BuildContext context, List<JobRegisterModel> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: IntrinsicWidth(
                  stepWidth: double.infinity,
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    showCheckboxColumn: true,
                    columnSpacing: 20,
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 56,
                    onSelectAll: (value) {
                      setState(() {
                        selectAll = value ?? false;
                        if (selectAll) {
                          selectedRows = Set<int>.from(
                            List.generate(list.length, (index) => index),
                          );
                        } else {
                          selectedRows.clear();
                        }
                      });
                    },
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Item',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            list.sort((a, b) => a.item.compareTo(b.item));
                          });
                        },
                      ),
                      DataColumn(
                        label: Expanded(
                          flex: 2,
                          child: Text(
                            'Description',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Location',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Center(
                            child: Text(
                              'Status',
                              style: context.topology.textTheme.titleSmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Inspected On',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Expiry Date',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: List.generate(list.length, (index) {
                      final data = list[index];
                      final isEven = index % 2 == 0;

                      return DataRow(
                        selected: selectedRows.contains(index),
                        onSelectChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              selectedRows.add(index);
                            } else {
                              selectedRows.remove(index);
                            }
                            selectAll = selectedRows.length == list.length;
                          });
                        },
                        color: MaterialStateProperty.resolveWith<Color?>((
                          Set<MaterialState> states,
                        ) {
                          return isEven ? context.colors.primary.withOpacity(0.05) : null;
                        }),
                        cells: [
                          DataCell(
                            InkWell(
                              onTap: () {
                                NavigationService().navigateTo(
                                  AppRoutes.jobItemDetails,
                                  arguments: {'item': data.item, 'site': data.location},
                                );
                              },
                              child: Text(
                                data.item,
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.description,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          DataCell(
                            Text(
                              data.location,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(data.status),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  data.status,
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.inspectedOn.formatShortDate,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.expiryDate?.formatShortDate ?? '',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, List<JobRegisterModel> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: sortColumnIndex,
          showCheckboxColumn: true,
          onSelectAll: (value) {
            setState(() {
              selectAll = value ?? false;
              if (selectAll) {
                selectedRows = Set<int>.from(List.generate(list.length, (index) => index));
              } else {
                selectedRows.clear();
              }
            });
          },
          columns: [
            DataColumn(
              label: Text(
                'Item',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Description',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Location',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Inspected On',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Expiry Date',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
          rows: List.generate(list.length, (index) {
            final data = list[index];
            final isEven = index % 2 == 0;

            return DataRow(
              selected: selectedRows.contains(index),
              onSelectChanged: (selected) {
                setState(() {
                  if (selected == true) {
                    selectedRows.add(index);
                  } else {
                    selectedRows.remove(index);
                  }
                  selectAll = selectedRows.length == list.length;
                });
              },
              color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                return isEven ? context.colors.primary.withOpacity(0.05) : null;
              }),
              cells: [
                DataCell(
                  Text(
                    data.item,
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.description,
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.location,
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(data.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.status,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.inspectedOn.formatShortDate,
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    data.expiryDate?.formatShortDate ?? '',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        CommonDialog.show(
          context,
          widget: SizedBox(
            height: context.screenHeight / 2,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Item',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CommonTextField(
                        hintText: 'Item Name',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Category',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CommonTextField(
                        hintText: selectedCategory?.name ?? 'Category',
                        enabled: false, // Pre-filled with current category
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Location',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CommonTextField(
                        hintText: 'Location',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vS,
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Status',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CommonTextField(
                        hintText: 'Status',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vL,
                CommonButton(
                  text: 'Add Item',
                  onPressed: () {
                    // TODO: Implement add item functionality
                    NavigationService().goBack();
                  },
                ),
              ],
            ),
          ),
        );
      },
      tooltip: 'Add Item',
      backgroundColor: context.colors.primary,
      child: const Icon(Icons.add),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
