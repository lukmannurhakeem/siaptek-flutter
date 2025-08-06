import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/job_model.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_dialog.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  int sortColumnIndex = 0;

  List<JobModel> jobModel = [
    JobModel(
      'VEL/N8/2023/001',
      'Velesto Energy Berhad',
      'Naga 8',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'BSL/BTL/2022/001',
      'BSL Containers Sdn Bhd',
      'BSL Bintulu',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'SPT/KL/IMT/2022/001',
      'Trone Solutions & Technologies Sdn. Bhd.',
      'Trone Solutions & Technologies Sdn. Bhd. HQ',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'KHLHSB/KT/2022/001',
      'Johan Jitu Sdn Bhd',
      'Johan Jitu Yard, Kuala Terengganu',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'SPK0028',
      'Schlumberger (M) Sdn Bhd',
      'Malaysia',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel(
      'SPT/SSB/LBN/2023/001',
      'Serimatik Yard, Labuan',
      'Naga 8',
      Status.started,
      DateTime.now(),
      DateTime.now(),
    ),
    JobModel('SPK0018', 'DEME Group', 'Pinocchio', Status.started, DateTime.now(), DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return context.isTablet
        ? SizedBox(
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
                              showCheckboxColumn: false,
                              columnSpacing: 20,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 56,
                              columns: [
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Job No',
                                      style: context.topology.textTheme.titleSmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                  onSort: (columnIndex, _) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      jobModel.sort(
                                        (a, b) => a.registerNum.compareTo(b.registerNum),
                                      );
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Customer',
                                      style: context.topology.textTheme.titleSmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                  onSort: (columnIndex, _) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      jobModel.sort(
                                        (a, b) => a.customerName.compareTo(b.customerName),
                                      );
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Site',
                                      style: context.topology.textTheme.titleSmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                  onSort: (columnIndex, _) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      jobModel.sort((a, b) => a.siteName.compareTo(b.siteName));
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Status',
                                      style: context.topology.textTheme.titleSmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                  onSort: (columnIndex, _) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      jobModel.sort(
                                        (a, b) => a.statusCode.name.compareTo(b.statusCode.name),
                                      );
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Start Date',
                                      style: context.topology.textTheme.titleSmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                  onSort: (columnIndex, _) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      jobModel.sort((a, b) => a.startDate.compareTo(b.startDate));
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'End Date',
                                      style: context.topology.textTheme.titleSmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                  onSort: (columnIndex, _) {
                                    setState(() {
                                      sortColumnIndex = columnIndex;
                                      jobModel.sort((a, b) => a.endDate.compareTo(b.endDate));
                                    });
                                  },
                                ),
                              ],
                              rows: List.generate(jobModel.length, (index) {
                                final data = jobModel[index];
                                final isEven = index % 2 == 0;

                                return DataRow(
                                  onSelectChanged: (selected) {
                                    if (selected == true) {
                                      NavigationService().navigateTo(AppRoutes.jobRegister);
                                    }
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
                                        child: Text(
                                          data.registerNum,
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
                                          data.customerName,
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
                                          data.siteName,
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
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(data.statusCode),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _getStatusText(data.statusCode),
                                            style: context.topology.textTheme.bodySmall?.copyWith(
                                              color: context.colors.onPrimary,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          data.startDate.formatShortDate,
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
                                          data.endDate.formatShortDate,
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
              Positioned(
                bottom: 50,
                right: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    CommonDialog.show(
                      context,
                      widget: SizedBox(
                        height: context.screenHeight / 2.35,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Customer',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CommonTextField(
                                    hintText: 'Customer Name',
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
                                    'Job No',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CommonTextField(
                                    hintText: 'Job Number',
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
                                    'Site',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CommonTextField(
                                    hintText: 'Site Name',
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
        )
        : SizedBox(
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
                          'Job No',
                          style: context.topology.textTheme.titleSmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            jobModel.sort((a, b) => a.registerNum.compareTo(b.registerNum));
                          });
                        },
                      ),
                      DataColumn(
                        label: Text(
                          'Customer',
                          style: context.topology.textTheme.titleSmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            jobModel.sort((a, b) => a.customerName.compareTo(b.customerName));
                          });
                        },
                      ),
                      DataColumn(
                        label: Text(
                          'Site',
                          style: context.topology.textTheme.titleSmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            jobModel.sort((a, b) => a.siteName.compareTo(b.siteName));
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
                            jobModel.sort((a, b) => a.statusCode.name.compareTo(b.statusCode.name));
                          });
                        },
                      ),
                      DataColumn(
                        label: Text(
                          'Start Date',
                          style: context.topology.textTheme.titleSmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            jobModel.sort((a, b) => a.startDate.compareTo(b.startDate));
                          });
                        },
                      ),
                      DataColumn(
                        label: Text(
                          'End Date',
                          style: context.topology.textTheme.titleSmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            jobModel.sort((a, b) => a.endDate.compareTo(b.endDate));
                          });
                        },
                      ),
                    ],
                    rows: List.generate(jobModel.length, (index) {
                      final data = jobModel[index];
                      final isEven = index % 2 == 0;

                      return DataRow(
                        onSelectChanged: (selected) {
                          if (selected == true) {
                            NavigationService().navigateTo(AppRoutes.jobRegister);
                          }
                        },
                        color: MaterialStateProperty.resolveWith<Color?>((
                          Set<MaterialState> states,
                        ) {
                          return isEven ? context.colors.primary.withOpacity(0.05) : null;
                        }),
                        cells: [
                          DataCell(
                            Text(
                              data.registerNum,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.customerName,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.siteName,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(data.statusCode),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getStatusText(data.statusCode),
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.startDate.formatShortDate,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.endDate.formatShortDate,
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
              Positioned(
                bottom: 50,
                right: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    CommonDialog.show(
                      context,
                      widget: SizedBox(
                        height: context.screenHeight / 2.35,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Customer',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CommonTextField(
                                    hintText: 'Customer Name',
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
                                    'Job No',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CommonTextField(
                                    hintText: 'Job Number',
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
                                    'Site',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CommonTextField(
                                    hintText: 'Site Name',
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
        );
  }

  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.started:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(Status status) {
    switch (status) {
      case Status.started:
        return 'Started';
      default:
        return status.name;
    }
  }
}
