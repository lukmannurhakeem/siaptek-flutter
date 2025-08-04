import 'dart:math';

import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/model/job.dart';
import 'package:flutter/material.dart';

class OpenJobsScreen extends StatefulWidget {
  const OpenJobsScreen({super.key});

  @override
  State<OpenJobsScreen> createState() => _OpenJobsScreenState();
}

class _OpenJobsScreenState extends State<OpenJobsScreen> {
  DateTime? _randomDate;
  DateTime _startDate = DateTime(2020, 1, 1);
  DateTime _endDate = DateTime(2030, 12, 31);
  final Random _random = Random();
  int sortColumnIndex = 0;

  void _generateRandomDate() {
    final int daysBetween = _endDate.difference(_startDate).inDays;
    final int randomDays = _random.nextInt(daysBetween + 1);

    setState(() {
      _randomDate = _startDate.add(Duration(days: randomDays));
    });
  }

  void _generateRandomDateInRange(DateTime start, DateTime end) {
    final int daysBetween = end.difference(start).inDays;
    final int randomDays = _random.nextInt(daysBetween + 1);

    setState(() {
      _randomDate = start.add(Duration(days: randomDays));
    });
  }

  List<Job> jobs = [
    Job('Schlumberger (M) Sdn Bhd', 'Malaysia', 'SPK00028'),
    Job('Travailler Energy Sdn Bhd', 'Bintulu', 'QUO/SPT/KLM/2023/VII'),
    Job('Altus Oil & Gas Malaysia', 'Kemaman, Terenganu', 'MO/SPT/ALT'),
    Job('Petrofac (Malaysia) Ltd', 'Kuala Lumpur', 'PF/2023/001'),
    Job('Carigali-PTTEPI Operating Company Sdn Bhd', 'MD-Foxtrot', 'MO/SPT/KL/20/001'),
    Job('Petronas Carigali Sdn Bhd', 'Kuala Lumpur', 'PCSB/2023/002'),
    Job('MP Offsore Pte Ltd', 'MP PROSPER, KSB, Kemaman', 'MPO/PROSPER/2023/001'),
    Job('Schlumberger (M) Sdn Bhd', 'Malaysia', 'SPK00028'),
    Job('Travailler Energy Sdn Bhd', 'Bintulu', 'QUO/SPT/KLM/2023/VII'),
    Job('Altus Oil & Gas Malaysia', 'Kemaman, Terenganu', 'MO/SPT/ALT'),
    Job('Petrofac (Malaysia) Ltd', 'Kuala Lumpur', 'PF/2023/001'),
    Job('Carigali-PTTEPI Operating Company Sdn Bhd', 'MD-Foxtrot', 'MO/SPT/KL/20/001'),
    Job('Petronas Carigali Sdn Bhd', 'Kuala Lumpur', 'PCSB/2023/002'),
    Job('MP Offsore Pte Ltd', 'MP PROSPER, KSB, Kemaman', 'MPO/PROSPER/2023/001'),
  ];

  @override
  Widget build(BuildContext context) {
    return (context.isTablet)
        ? LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: IntrinsicWidth(
                    stepWidth: double.infinity,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      columns: [
                        DataColumn(
                          label: Expanded(
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
                              jobs.sort((a, b) => a.name.compareTo(b.name));
                            });
                          },
                        ),
                        DataColumn(
                          label: Expanded(
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
                              jobs.sort((a, b) => a.site.compareTo(b.site));
                            });
                          },
                        ),
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
                              jobs.sort((a, b) => a.id.compareTo(b.id));
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
                              jobs.sort((a, b) => a.id.compareTo(b.id));
                            });
                          },
                        ),
                      ],
                      rows: List.generate(jobs.length, (index) {
                        final data = jobs[index];
                        final isEven = index % 2 == 0;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((
                            Set<MaterialState> states,
                          ) {
                            return isEven ? context.colors.primary.withOpacity(0.05) : null;
                          }),
                          cells: [
                            DataCell(
                              Text(
                                data.name,
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                data.site,
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                data.id,
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '02-Jan-2025',
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
        )
        : ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Open Jobs Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    columns: [
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
                            jobs.sort((a, b) => a.name.compareTo(b.name));
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
                            jobs.sort((a, b) => a.site.compareTo(b.site));
                          });
                        },
                      ),
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
                            jobs.sort((a, b) => a.id.compareTo(b.id));
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
                            jobs.sort((a, b) => a.id.compareTo(b.id));
                          });
                        },
                      ),
                    ],
                    rows: List.generate(jobs.length, (index) {
                      final data = jobs[index];
                      final isEven = index % 2 == 0;

                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>((
                          Set<MaterialState> states,
                        ) {
                          return isEven ? context.colors.primary.withOpacity(0.05) : null;
                        }),
                        cells: [
                          DataCell(
                            Text(
                              data.name,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.site,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.id,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '02-Jan-2025',
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
          ],
        );
  }
}
