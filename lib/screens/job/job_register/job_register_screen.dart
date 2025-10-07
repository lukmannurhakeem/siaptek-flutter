import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
// Conditional imports - these will only be imported on respective platforms
import 'package:base_app/core/utils/file_export_stub.dart'
    if (dart.library.html) 'package:base_app/core/utils/file_export_web.dart'
    if (dart.library.io) 'package:base_app/core/utils/file_export_mobile.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobRegisterScreen extends StatefulWidget {
  final String jobId;

  const JobRegisterScreen({super.key, required this.jobId});

  @override
  State<JobRegisterScreen> createState() => _JobRegisterScreenState();
}

class _JobRegisterScreenState extends State<JobRegisterScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int sortColumnIndex = 0;
  Set<int> selectedRows = <int>{};
  bool selectAll = false;

  // Column selection for export
  Map<String, bool> selectedColumns = {
    'item': true,
    'description': true,
    'category': true,
    'location': true,
    'status': true,
    'inspectedOn': true,
    'expiryDate': true,
  };

  final List<Tab> tabs = const [
    Tab(text: 'Item Register'),
    Tab(text: 'Inspection Register'),
    Tab(text: 'Report Approvals'),
    Tab(text: 'Reporting'),
    Tab(text: 'Files'),
    Tab(text: 'Job Progress'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch job register data if not already loaded
      final provider = context.read<JobProvider>();
      if (provider.jobRegisterModel == null) {
        provider.fetchJobRegisterModel(context);
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                      title: Text('Item'),
                      value: selectedColumns['item'],
                      onChanged: (value) {
                        setState(() {
                          selectedColumns['item'] = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Description'),
                      value: selectedColumns['description'],
                      onChanged: (value) {
                        setState(() {
                          selectedColumns['description'] = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Category'),
                      value: selectedColumns['category'],
                      onChanged: (value) {
                        setState(() {
                          selectedColumns['category'] = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Location'),
                      value: selectedColumns['location'],
                      onChanged: (value) {
                        setState(() {
                          selectedColumns['location'] = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Status'),
                      value: selectedColumns['status'],
                      onChanged: (value) {
                        setState(() {
                          selectedColumns['status'] = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Inspected On'),
                      value: selectedColumns['inspectedOn'],
                      onChanged: (value) {
                        setState(() {
                          selectedColumns['inspectedOn'] = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Expiry Date'),
                      value: selectedColumns['expiryDate'],
                      onChanged: (value) {
                        setState(() {
                          selectedColumns['expiryDate'] = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {}); // Update main widget state
                    Navigator.of(context).pop();
                  },
                  child: Text('Apply'),
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _exportToCSV();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('CSV file exported successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Export'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportToCSV() async {
    if (selectedRows.isEmpty) return;

    final provider = context.read<JobProvider>();
    final filteredList = provider.searchItems(_searchQuery, _tabController.index);

    // Generate CSV content
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

    // Use the platform-specific export function
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job Register',
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
      body: Consumer<JobProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading data: ${provider.error}',
                    style: context.topology.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchJobRegisterModel(context),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: context.paddingHorizontal,
            child: Column(
              children: [
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
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(provider), // All Items
                      _buildTabContent(provider), // Active
                      _buildTabContent(provider), // Pending
                      _buildTabContent(provider), // Archived
                      _buildTabContent(provider),
                      _buildTabContent(provider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

  Widget _buildTabContent(JobProvider provider) {
    final filteredList = provider.searchItems(_searchQuery, _tabController.index);

    if (filteredList.isEmpty && !provider.isLoading) {
      return Center(
        child: Text(
          'No items found',
          style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.primary),
        ),
      );
    }

    return context.isTablet
        ? _buildTabletView(context, filteredList)
        : _buildMobileView(context, filteredList);
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
                          onPressed: () {
                            _searchController.clear();
                          },
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
                      _buildToggleButton(
                        context,
                        'All',
                        _tabController.index == 0,
                        () => _tabController.animateTo(0),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Not Inspected',
                        _tabController.index == 2,
                        () => _tabController.animateTo(2),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Draft',
                        false, // You can add draft filtering logic
                        () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Draft filter clicked')));
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Inspected',
                        _tabController.index == 1,
                        () => _tabController.animateTo(1),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Include Archived',
                        _tabController.index == 3,
                        () => _tabController.animateTo(3),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        context,
                        'Items I Can Inspect',
                        false, // Add your logic here
                        () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Items I Can Inspect clicked')));
                        },
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
                              data.expiryDateTimeStamp?.formatShortDate ?? '-',
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
                  Text(
                    data.itemId ?? '-',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
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
                    data.expiryDateTimeStamp?.formatShortDate ?? '-',
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
