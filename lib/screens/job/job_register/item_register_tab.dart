// ==================== Tab 1: Item Register ====================
// lib/screens/job_register/item_register_tab.dart

import 'package:INSPECT/core/extension/date_time_extension.dart';
import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/core/utils/file_export_stub.dart'
    if (dart.library.html) 'package:INSPECT/core/utils/file_export_web.dart'
    if (dart.library.io) 'package:INSPECT/core/utils/file_export_mobile.dart';
import 'package:INSPECT/model/job_register.dart';
import 'package:INSPECT/providers/job_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemRegisterTab extends StatefulWidget {
  final String jobId;

  const ItemRegisterTab({super.key, required this.jobId});

  @override
  State<ItemRegisterTab> createState() => _ItemRegisterTabState();
}

class _ItemRegisterTabState extends State<ItemRegisterTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<int> selectedRows = <int>{};
  bool selectAll = false;
  int sortColumnIndex = 0;

  Map<String, bool> selectedColumns = {
    'item': true,
    'description': true,
    'category': true,
    'location': true,
    'status': true,
    'inspectedOn': true,
    'expiryDate': true,
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showColumnSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Columns to Export',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: const Text('Item'),
                      value: selectedColumns['item'],
                      onChanged:
                          (value) => setState(() => selectedColumns['item'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Description'),
                      value: selectedColumns['description'],
                      onChanged:
                          (value) =>
                              setState(() => selectedColumns['description'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Category'),
                      value: selectedColumns['category'],
                      onChanged:
                          (value) => setState(() => selectedColumns['category'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Location'),
                      value: selectedColumns['location'],
                      onChanged:
                          (value) => setState(() => selectedColumns['location'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Status'),
                      value: selectedColumns['status'],
                      onChanged:
                          (value) => setState(() => selectedColumns['status'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Inspected On'),
                      value: selectedColumns['inspectedOn'],
                      onChanged:
                          (value) =>
                              setState(() => selectedColumns['inspectedOn'] = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Expiry Date'),
                      value: selectedColumns['expiryDate'],
                      onChanged:
                          (value) => setState(() => selectedColumns['expiryDate'] = value ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Export Data',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
          content: Text(
            'Export ${selectedRows.length} selected rows to CSV file?',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                await _exportToCSV();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CSV file exported successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Export'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportToCSV() async {
    if (selectedRows.isEmpty) return;

    final provider = context.read<JobProvider>();
    final filteredList = provider.searchItems(_searchQuery, 0);

    List<String> headers = [];
    if (selectedColumns['item'] == true) headers.add('Item');
    if (selectedColumns['description'] == true) headers.add('Description');
    if (selectedColumns['category'] == true) headers.add('Category');
    if (selectedColumns['location'] == true) headers.add('Location');
    if (selectedColumns['status'] == true) headers.add('Status');
    if (selectedColumns['inspectedOn'] == true) headers.add('Inspected On');
    if (selectedColumns['expiryDate'] == true) headers.add('Expiry Date');

    List<List<String>> rows = [headers];

    for (int index in selectedRows) {
      if (index >= filteredList.length) continue;
      final data = filteredList[index];
      List<String> row = [];

      if (selectedColumns['item'] == true) row.add(_escapeCSVField(data.itemNo ?? ''));
      if (selectedColumns['description'] == true) row.add(_escapeCSVField(data.description ?? ''));
      if (selectedColumns['category'] == true) row.add(_escapeCSVField(data.categoryId ?? ''));
      if (selectedColumns['location'] == true)
        row.add(_escapeCSVField(data.detailedLocation ?? ''));
      if (selectedColumns['status'] == true) row.add(_escapeCSVField(data.status ?? ''));
      if (selectedColumns['inspectedOn'] == true)
        row.add(_escapeCSVField(data.firstUseDate?.formatShortDate ?? ''));
      if (selectedColumns['expiryDate'] == true)
        row.add(_escapeCSVField(data.expiryDateTimeStamp?.formatShortDate ?? ''));

      rows.add(row);
    }

    String csvContent = rows.map((row) => row.join(',')).join('\n');

    try {
      await exportCSV(csvContent, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _escapeCSVField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withOpacity(0.1),
                      Colors.blue.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: context.colors.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Items Yet',
                style: context.topology.textTheme.titleLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start building your inventory by creating\nyour first item for this job',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(
                    AppRoutes.jobItemCreateScreen,
                    arguments: {'jobId': widget.jobId},
                  );
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Create First Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: context.topology.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'What you can do:',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      context,
                      Icons.check_circle_outline,
                      'Track items and inspections',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context,
                      Icons.location_on_outlined,
                      'Manage locations and categories',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(context, Icons.download_outlined, 'Export reports and data'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: context.topology.textTheme.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String text,
    bool isActive,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? Colors.teal : Colors.transparent,
        foregroundColor: isActive ? Colors.white : Colors.grey[700],
        side: BorderSide(color: isActive ? Colors.teal : Colors.grey[400]!, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: context.topology.textTheme.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        final filteredList = provider.searchItems(_searchQuery, 0);

        if (filteredList.isEmpty && !provider.isLoading) {
          if (_searchQuery.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildSearchEmpty(context);
        }

        return context.isTablet
            ? _buildTabletView(context, filteredList)
            : _buildMobileView(context, filteredList);
      },
    );
  }

  Widget _buildSearchEmpty(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: ListView(
        children: [
          CommonTextField(
            controller: _searchController,
            hintText: 'Search items',
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                    : null,
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No items found',
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search',
                  style: context.topology.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletView(BuildContext context, List<Item> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              CommonTextField(
                controller: _searchController,
                hintText: 'Search items',
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionButton(context, 'Create Item', Icons.add, Colors.blue, () {
                        NavigationService().navigateTo(
                          AppRoutes.jobItemCreateScreen,
                          arguments: {'jobId': widget.jobId},
                        );
                      }),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'Export Grid',
                        Icons.download,
                        Colors.blue,
                        () => _showExportDialog(context),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        'Column visibility',
                        Icons.view_column,
                        Colors.teal,
                        () => _showColumnSelectionDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
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
                        onSort: (columnIndex, _) {},
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
                            'Category',
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
                      final data = list.elementAt(index);
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
                                  arguments: {'item': data},
                                );
                              },
                              child: Text(
                                data.itemId ?? '-',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.description ?? '-',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          DataCell(
                            Text(
                              data.categoryId ?? '-',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          DataCell(
                            Text(
                              data.locationId ?? '-',
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
                                  color: _getStatusColor(data.status ?? ''),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  data.status ?? '-',
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
                              data.firstUseDate?.formatShortDate ?? '-',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.expiryDateTimeStamp?.formatShortDate ?? '',
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

  Widget _buildMobileView(BuildContext context, List<Item> list) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: ListView(
        children: [
          CommonTextField(
            controller: _searchController,
            hintText: 'Search items',
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                    : null,
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
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
                    'Category',
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
                      InkWell(
                        onTap: () {
                          NavigationService().navigateTo(
                            AppRoutes.jobItemDetails,
                            arguments: {'item': data},
                          );
                        },
                        child: Text(
                          data.itemId ?? '-',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        data.description ?? '-',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        data.categoryId ?? '-',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        data.locationId ?? '-',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(data.status ?? ''),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data.status ?? '-',
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color: context.colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        data.firstUseDate?.formatShortDate ?? '-',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        data.expiryDateTimeStamp?.formatShortDate ?? '',
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
        ],
      ),
    );
  }
}
