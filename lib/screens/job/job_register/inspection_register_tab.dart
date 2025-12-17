import 'package:INSPECT/core/extension/date_time_extension.dart';
import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/core/utils/file_export_stub.dart';
import 'package:INSPECT/model/job_register.dart';
import 'package:INSPECT/providers/job_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InspectionRegisterTab extends StatefulWidget {
  final String jobId;

  const InspectionRegisterTab({super.key, required this.jobId});

  @override
  State<InspectionRegisterTab> createState() => _InspectionRegisterTabState();
}

class _InspectionRegisterTabState extends State<InspectionRegisterTab> {
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
    'report': true, // Added - matches tablet view
    'reportType': true, // Added - matches tablet view
    'status': true,
    'inspectedBy': true, // Changed from 'inspectedOn' to match tablet view
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

  Widget _buildInspectionEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.withOpacity(0.15), Colors.green.withOpacity(0.08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: Icon(Icons.fact_check_outlined, size: 70, color: Colors.teal.shade600),
              ),
              const SizedBox(height: 28),
              Text(
                'No Inspections Yet',
                style: context.topology.textTheme.titleLarge?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Begin your inspection journey by\nconducting your first inspection',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(
                    AppRoutes.reportCreate,
                    arguments: {'jobId': widget.jobId},
                  );
                },
                icon: const Icon(Icons.playlist_add_check, size: 22),
                label: const Text('Start Inspection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  textStyle: context.topology.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'What you can do:',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      context,
                      Icons.checklist_outlined,
                      'Conduct thorough inspections',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      context,
                      Icons.camera_alt_outlined,
                      'Capture photos and evidence',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      context,
                      Icons.description_outlined,
                      'Generate detailed reports',
                    ),
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
        Icon(icon, size: 20, color: context.colors.primary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionStatusBadge(BuildContext context, String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'accepted':
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
      case 'failed':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: context.topology.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _buildDataColumn(
    BuildContext context,
    String label, {
    int flex = 1,
    bool centered = false,
  }) {
    return DataColumn(
      label: Expanded(
        flex: flex,
        child:
            centered
                ? Center(
                  child: Text(
                    label,
                    style: context.topology.textTheme.titleSmall?.copyWith(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
                : Text(
                  label,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: Colors.teal.shade800,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        final filteredList = provider.searchItems(_searchQuery, 1);

        if (filteredList.isEmpty && !provider.isLoading) {
          if (_searchQuery.isEmpty) {
            return _buildInspectionEmptyState(context);
          }
          return Center(child: Text('No inspections found for "$_searchQuery"'));
        }

        return context.isTablet
            ? _buildTabletView(context, filteredList)
            : _buildMobileView(context, filteredList);

        // return Container(
        //   padding: const EdgeInsets.only(top: 16),
        //   child: ListView(
        //     children: [
        //       CommonTextField(
        //         controller: _searchController,
        //         hintText: 'Search inspections by item, category, or status...',
        //         suffixIcon:
        //             _searchQuery.isNotEmpty
        //                 ? IconButton(
        //                   icon: const Icon(Icons.clear),
        //                   onPressed: () => _searchController.clear(),
        //                 )
        //                 : null,
        //       ),
        //       Container(
        //         padding: const EdgeInsets.symmetric(vertical: 16),
        //         child: Row(
        //           children: [
        //             Expanded(
        //               child: _buildStatsCard(
        //                 context,
        //                 'Total Inspections',
        //                 filteredList.length.toString(),
        //                 Icons.fact_check,
        //                 Colors.teal,
        //               ),
        //             ),
        //             const SizedBox(width: 12),
        //             Expanded(
        //               child: _buildStatsCard(
        //                 context,
        //                 'Completed',
        //                 filteredList
        //                     .where((item) => item.inspectionStatus?.toLowerCase() == 'accepted')
        //                     .length
        //                     .toString(),
        //                 Icons.check_circle,
        //                 Colors.green,
        //               ),
        //             ),
        //             const SizedBox(width: 12),
        //             Expanded(
        //               child: _buildStatsCard(
        //                 context,
        //                 'Pending',
        //                 filteredList
        //                     .where((item) => item.inspectionStatus?.toLowerCase() == 'pending')
        //                     .length
        //                     .toString(),
        //                 Icons.pending,
        //                 Colors.orange,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //       Card(
        //         elevation: 2,
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        //         child: ClipRRect(
        //           borderRadius: BorderRadius.circular(12),
        //           child: SingleChildScrollView(
        //             scrollDirection: Axis.horizontal,
        //             child: DataTable(
        //               headingRowColor: MaterialStateProperty.all(Colors.teal.withOpacity(0.08)),
        //               headingRowHeight: 60,
        //               dataRowMinHeight: 70,
        //               dataRowMaxHeight: 70,
        //               showCheckboxColumn: true,
        //               columnSpacing: 24,
        //               onSelectAll: (value) {
        //                 setState(() {
        //                   selectAll = value ?? false;
        //                   if (selectAll) {
        //                     selectedRows = Set<int>.from(
        //                       List.generate(filteredList.length, (index) => index),
        //                     );
        //                   } else {
        //                     selectedRows.clear();
        //                   }
        //                 });
        //               },
        //               columns: [
        //                 _buildDataColumn(context, 'Item No'),
        //                 _buildDataColumn(context, 'Description', flex: 2),
        //                 _buildDataColumn(context, 'Category'),
        //                 _buildDataColumn(context, 'Location'),
        //                 _buildDataColumn(context, 'Inspector'),
        //                 _buildDataColumn(context, 'Inspection Date'),
        //                 _buildDataColumn(context, 'Status', centered: true),
        //                 _buildDataColumn(context, 'Actions', centered: true),
        //               ],
        //               rows: List.generate(filteredList.length, (index) {
        //                 final item = filteredList[index];
        //                 final isEven = index % 2 == 0;
        //
        //                 return DataRow(
        //                   selected: selectedRows.contains(index),
        //                   onSelectChanged: (selected) {
        //                     setState(() {
        //                       if (selected == true) {
        //                         selectedRows.add(index);
        //                       } else {
        //                         selectedRows.remove(index);
        //                       }
        //                       selectAll = selectedRows.length == filteredList.length;
        //                     });
        //                   },
        //                   color: MaterialStateProperty.resolveWith<Color?>((states) {
        //                     if (states.contains(MaterialState.selected)) {
        //                       return Colors.teal.withOpacity(0.12);
        //                     }
        //                     return isEven ? Colors.grey.withOpacity(0.03) : null;
        //                   }),
        //                   cells: [
        //                     DataCell(
        //                       InkWell(
        //                         onTap: () {
        //                           NavigationService().navigateTo(
        //                             AppRoutes.jobItemDetails,
        //                             arguments: {'item': item},
        //                           );
        //                         },
        //                         child: Container(
        //                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //                           decoration: BoxDecoration(
        //                             color: Colors.blue.withOpacity(0.08),
        //                             borderRadius: BorderRadius.circular(6),
        //                           ),
        //                           child: Text(
        //                             item.itemNo ?? '-',
        //                             style: context.topology.textTheme.bodySmall?.copyWith(
        //                               color: Colors.blue.shade700,
        //                               fontWeight: FontWeight.w600,
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                     DataCell(
        //                       Text(
        //                         item.description ?? '-',
        //                         style: context.topology.textTheme.bodySmall?.copyWith(
        //                           color: context.colors.primary,
        //                           fontWeight: FontWeight.w500,
        //                         ),
        //                         overflow: TextOverflow.ellipsis,
        //                         maxLines: 2,
        //                       ),
        //                     ),
        //                     DataCell(
        //                       Container(
        //                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        //                         decoration: BoxDecoration(
        //                           color: Colors.purple.shade50,
        //                           borderRadius: BorderRadius.circular(6),
        //                         ),
        //                         child: Text(
        //                           item.categoryId ?? '-',
        //                           style: context.topology.textTheme.bodySmall?.copyWith(
        //                             color: Colors.purple.shade700,
        //                             fontWeight: FontWeight.w600,
        //                             fontSize: 12,
        //                           ),
        //                           overflow: TextOverflow.ellipsis,
        //                         ),
        //                       ),
        //                     ),
        //                     DataCell(
        //                       Row(
        //                         children: [
        //                           Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
        //                           const SizedBox(width: 6),
        //                           Expanded(
        //                             child: Text(
        //                               item.locationId ?? '-',
        //                               style: context.topology.textTheme.bodySmall?.copyWith(
        //                                 color: context.colors.primary,
        //                               ),
        //                               overflow: TextOverflow.ellipsis,
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                     DataCell(
        //                       Row(
        //                         children: [
        //                           CircleAvatar(
        //                             radius: 14,
        //                             backgroundColor: Colors.teal.shade100,
        //                             child: Icon(
        //                               Icons.person,
        //                               size: 16,
        //                               color: Colors.teal.shade700,
        //                             ),
        //                           ),
        //                           const SizedBox(width: 8),
        //                           Expanded(
        //                             child: Text(
        //                               item.inspectionStatus ?? 'Not Assigned',
        //                               style: context.topology.textTheme.bodySmall?.copyWith(
        //                                 color: context.colors.primary,
        //                               ),
        //                               overflow: TextOverflow.ellipsis,
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                     DataCell(
        //                       Row(
        //                         children: [
        //                           Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
        //                           const SizedBox(width: 6),
        //                           Text(
        //                             item.firstUseDate?.formatShortDate ?? '-',
        //                             style: context.topology.textTheme.bodySmall?.copyWith(
        //                               color: context.colors.primary,
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                     DataCell(
        //                       Center(
        //                         child: _buildInspectionStatusBadge(
        //                           context,
        //                           item.inspectionStatus ?? 'pending',
        //                         ),
        //                       ),
        //                     ),
        //                     DataCell(
        //                       Center(
        //                         child: Row(
        //                           mainAxisSize: MainAxisSize.min,
        //                           children: [
        //                             IconButton(
        //                               icon: const Icon(Icons.visibility, size: 20),
        //                               color: Colors.blue.shade600,
        //                               tooltip: 'View Details',
        //                               onPressed: () {
        //                                 NavigationService().navigateTo(
        //                                   AppRoutes.jobItemDetails,
        //                                   arguments: {'item': item},
        //                                 );
        //                               },
        //                             ),
        //                             IconButton(
        //                               icon: const Icon(Icons.edit, size: 20),
        //                               color: Colors.orange.shade600,
        //                               tooltip: 'Edit Inspection',
        //                               onPressed: () {},
        //                             ),
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                   ],
        //                 );
        //               }),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // );
      },
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
                            'Report',
                            style: context.topology.textTheme.titleSmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Report Type',
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
                            'Inspected By',
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
                              data.locationId ?? '-',
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
                            _buildInspectionStatusBadge(
                              context,
                              data.inspectionStatus ?? 'pending',
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
                      _buildInspectionStatusBadge(context, data.inspectionStatus ?? 'pending'),
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
    final filteredList = provider.searchItems(
      _searchQuery,
      1,
    ); // Changed from 0 to 1 to match your data

    List<String> headers = [];
    if (selectedColumns['item'] == true) headers.add('Item');
    if (selectedColumns['description'] == true) headers.add('Description');
    if (selectedColumns['category'] == true) headers.add('Category');
    if (selectedColumns['location'] == true) headers.add('Location');
    if (selectedColumns['report'] == true) headers.add('Report');
    if (selectedColumns['reportType'] == true) headers.add('Report Type');
    if (selectedColumns['status'] == true) headers.add('Status');
    if (selectedColumns['inspectedBy'] == true) headers.add('Inspected By');
    if (selectedColumns['expiryDate'] == true) headers.add('Expiry Date');

    List<List<String>> rows = [headers];

    for (int index in selectedRows) {
      if (index >= filteredList.length) continue;
      final data = filteredList[index];
      List<String> row = [];

      if (selectedColumns['item'] == true) row.add(_escapeCSVField(data.itemId ?? ''));
      if (selectedColumns['description'] == true) row.add(_escapeCSVField(data.description ?? ''));
      if (selectedColumns['category'] == true) row.add(_escapeCSVField(data.categoryId ?? ''));
      if (selectedColumns['location'] == true) row.add(_escapeCSVField(data.locationId ?? ''));
      if (selectedColumns['report'] == true)
        row.add(_escapeCSVField(data.locationId ?? '')); // Update with correct field
      if (selectedColumns['reportType'] == true)
        row.add(_escapeCSVField(data.locationId ?? '')); // Update with correct field
      if (selectedColumns['status'] == true) row.add(_escapeCSVField(data.inspectionStatus ?? ''));
      if (selectedColumns['inspectedBy'] == true)
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
                child: SingleChildScrollView(
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
                        title: const Text('Report'),
                        value: selectedColumns['report'],
                        onChanged:
                            (value) => setState(() => selectedColumns['report'] = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Report Type'),
                        value: selectedColumns['reportType'],
                        onChanged:
                            (value) =>
                                setState(() => selectedColumns['reportType'] = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Status'),
                        value: selectedColumns['status'],
                        onChanged:
                            (value) => setState(() => selectedColumns['status'] = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Inspected By'),
                        value: selectedColumns['inspectedBy'],
                        onChanged:
                            (value) =>
                                setState(() => selectedColumns['inspectedBy'] = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Expiry Date'),
                        value: selectedColumns['expiryDate'],
                        onChanged:
                            (value) =>
                                setState(() => selectedColumns['expiryDate'] = value ?? false),
                      ),
                    ],
                  ),
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
}
