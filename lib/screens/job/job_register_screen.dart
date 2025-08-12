// For mobile platforms, you'll need to add these dependencies to pubspec.yaml:
// path_provider: ^2.1.1
// permission_handler: ^11.0.1

import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
// Conditional imports - these will only be imported on respective platforms
import 'package:base_app/core/utils/file_export_stub.dart'
    if (dart.library.html) 'package:base_app/core/utils/file_export_web.dart'
    if (dart.library.io) 'package:base_app/core/utils/file_export_mobile.dart';
import 'package:base_app/model/job_register.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class JobRegisterScreen extends StatefulWidget {
  const JobRegisterScreen({super.key});

  @override
  State<JobRegisterScreen> createState() => _JobRegisterScreenState();
}

class _JobRegisterScreenState extends State<JobRegisterScreen> {
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
      final data = _list[index];
      List<String> row = [];

      if (selectedColumns['item'] == true) row.add(_escapeCSVField(data.item));
      if (selectedColumns['description'] == true) row.add(_escapeCSVField(data.description));
      if (selectedColumns['category'] == true) row.add(_escapeCSVField(data.category));
      if (selectedColumns['location'] == true) row.add(_escapeCSVField(data.location));
      if (selectedColumns['status'] == true) row.add(_escapeCSVField(data.status));
      if (selectedColumns['inspectedOn'] == true)
        row.add(_escapeCSVField(data.inspectedOn.formatShortDate));
      if (selectedColumns['expiryDate'] == true)
        row.add(_escapeCSVField(data.expiryDate!.formatShortDate));

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

  // Rest of your existing code remains the same...
  final List<JobRegisterModel> _list = [
    JobRegisterModel(
      id: '001',
      item: 'Fire Extinguisher',
      description: 'Class A fire extinguisher for office use',
      category: 'Safety Equipment',
      location: 'Office Floor 1',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '002',
      item: 'First Aid Kit',
      description: 'Emergency medical supplies kit',
      category: 'Medical Supplies',
      location: 'Kitchen Area',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '003',
      item: 'Laptop Computer',
      description: 'Dell Latitude 5520 for development work',
      category: 'Electronics',
      location: 'Development Lab',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '004',
      item: 'Safety Helmet',
      description: 'Hard hat for construction site work',
      category: 'Safety Equipment',
      location: 'Construction Site A',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '005',
      item: 'Chemical Reagent',
      description: 'Laboratory grade sodium chloride solution',
      category: 'Laboratory Supplies',
      location: 'Lab Storage Room',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '006',
      item: 'Office Chair',
      description: 'Ergonomic office chair with lumbar support',
      category: 'Furniture',
      location: 'Office Floor 2',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '007',
      item: 'Projector',
      description: 'Epson PowerLite projector for presentations',
      category: 'Electronics',
      location: 'Conference Room B',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '008',
      item: 'Smoke Detector',
      description: 'Battery-powered smoke detection device',
      category: 'Safety Equipment',
      location: 'Hallway Floor 3',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '009',
      item: 'Cleaning Supplies',
      description: 'All-purpose cleaning solution and tools',
      category: 'Maintenance',
      location: 'Janitor Closet',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
    JobRegisterModel(
      id: '010',
      item: 'Network Router',
      description: 'Cisco wireless router for office network',
      category: 'Networking',
      location: 'Server Room',
      status: 'Accepted',
      inspectedOn: DateTime.now(),
      expiryDate: DateTime.now(),
      archived: 'Active',
    ),
  ];

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
        actions: [
          if (selectedRows.isNotEmpty)
            IconButton(
              onPressed: () => _showExportDialog(context),
              icon: Icon(Icons.download),
              tooltip: 'Export Selected',
            ),
          IconButton(
            onPressed: () => _showColumnSelectionDialog(context),
            icon: Icon(Icons.view_column),
            tooltip: 'Select Columns',
          ),
        ],
      ),
      body: context.isTablet ? _buildTabletView(context) : _buildMobileView(context),
    );
  }

  Widget _buildTabletView(BuildContext context) {
    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - (kToolbarHeight * 1.25),
      child: Stack(
        children: [
          Container(
            padding: context.paddingHorizontal,
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
                                  List.generate(_list.length, (index) => index),
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
                                  _list.sort((a, b) => a.item.compareTo(b.item));
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
                              onSort: (columnIndex, _) {
                                setState(() {
                                  sortColumnIndex = columnIndex;
                                  _list.sort((a, b) => a.description.compareTo(b.description));
                                });
                              },
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
                              onSort: (columnIndex, _) {
                                setState(() {
                                  sortColumnIndex = columnIndex;
                                  _list.sort((a, b) => a.category.compareTo(b.category));
                                });
                              },
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
                              onSort: (columnIndex, _) {
                                setState(() {
                                  sortColumnIndex = columnIndex;
                                  _list.sort((a, b) => a.location.compareTo(b.location));
                                });
                              },
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
                              onSort: (columnIndex, _) {
                                setState(() {
                                  sortColumnIndex = columnIndex;
                                  _list.sort((a, b) => a.status.compareTo(b.status));
                                });
                              },
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
                              onSort: (columnIndex, _) {
                                setState(() {
                                  sortColumnIndex = columnIndex;
                                  _list.sort((a, b) => a.inspectedOn.compareTo(b.inspectedOn));
                                });
                              },
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
                              onSort: (columnIndex, _) {
                                setState(() {
                                  sortColumnIndex = columnIndex;
                                  _list.sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
                                });
                              },
                            ),
                          ],
                          rows: List.generate(_list.length, (index) {
                            final data = _list[index];
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
                                  selectAll = selectedRows.length == _list.length;
                                });
                              },
                              color: MaterialStateProperty.resolveWith<Color?>((
                                Set<MaterialState> states,
                              ) {
                                return isEven ? context.colors.primary.withOpacity(0.05) : null;
                              }),
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: InkWell(
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
                                ),
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      data.description,
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      data.category,
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      data.location,
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
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
                                ),
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      data.inspectedOn.formatShortDate,
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      data.expiryDate?.formatShortDate ?? '',
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - (kToolbarHeight * 1.25),
      child: Stack(
        children: [
          Container(
            padding: context.paddingHorizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: sortColumnIndex,
                showCheckboxColumn: true,
                onSelectAll: (value) {
                  setState(() {
                    selectAll = value ?? false;
                    if (selectAll) {
                      selectedRows = Set<int>.from(List.generate(_list.length, (index) => index));
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
                    onSort: (columnIndex, _) {
                      setState(() {
                        sortColumnIndex = columnIndex;
                        _list.sort((a, b) => a.item.compareTo(b.item));
                      });
                    },
                  ),
                  DataColumn(
                    label: Text(
                      'Description',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    onSort: (columnIndex, _) {
                      setState(() {
                        sortColumnIndex = columnIndex;
                        _list.sort((a, b) => a.description.compareTo(b.description));
                      });
                    },
                  ),
                  DataColumn(
                    label: Text(
                      'Category',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    onSort: (columnIndex, _) {
                      setState(() {
                        sortColumnIndex = columnIndex;
                        _list.sort((a, b) => a.category.compareTo(b.category));
                      });
                    },
                  ),
                  DataColumn(
                    label: Text(
                      'Location',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    onSort: (columnIndex, _) {
                      setState(() {
                        sortColumnIndex = columnIndex;
                        _list.sort((a, b) => a.location.compareTo(b.location));
                      });
                    },
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    onSort: (columnIndex, _) {
                      setState(() {
                        sortColumnIndex = columnIndex;
                        _list.sort((a, b) => a.status.compareTo(b.status));
                      });
                    },
                  ),
                  DataColumn(
                    label: Text(
                      'Inspected On',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    onSort: (columnIndex, _) {
                      setState(() {
                        sortColumnIndex = columnIndex;
                        _list.sort((a, b) => a.inspectedOn.compareTo(b.inspectedOn));
                      });
                    },
                  ),
                  DataColumn(
                    label: Text(
                      'Expiry Date',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    onSort: (columnIndex, _) {
                      setState(() {
                        sortColumnIndex = columnIndex;
                        _list.sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
                      });
                    },
                  ),
                ],
                rows: List.generate(_list.length, (index) {
                  final data = _list[index];
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
                        selectAll = selectedRows.length == _list.length;
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
                          data.category,
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
          ),
          _buildFloatingActionButton(context),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Positioned(
      bottom: 50,
      right: 30,
      child: FloatingActionButton(
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
                          hintText: 'Category',
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
                    text: 'Search',
                    onPressed: () {
                      NavigationService().goBack();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        tooltip: 'Search',
        backgroundColor: context.colors.primary,
        child: const Icon(Icons.search),
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

  // Your other existing methods...
}
