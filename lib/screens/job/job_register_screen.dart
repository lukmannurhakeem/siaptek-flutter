import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/job_register.dart';
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
      ),
      body: SizedBox(
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
                  showCheckboxColumn: false,
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
                  ],
                  rows: List.generate(_list.length, (index) {
                    final data = _list[index];
                    final isEven = index % 2 == 0;

                    return DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          // Handle row selection - navigate to detail screen or perform action
                          print('Selected item: ${data.item}');
                        }
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
                      ],
                    );
                  }),
                ),
              ),
            ),
            Positioned(
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
            ),
          ],
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
