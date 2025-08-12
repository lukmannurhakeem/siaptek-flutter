import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:flutter/material.dart';

class ItemReportScreen extends StatefulWidget {
  const ItemReportScreen({super.key});

  @override
  State<ItemReportScreen> createState() => _ItemReportScreenState();
}

class _ItemReportScreenState extends State<ItemReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, con) {
        return ListView(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: con.maxWidth),
              child: IntrinsicWidth(
                stepWidth: double.infinity,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Report No',
                          style: context.topology.textTheme.titleSmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, _) {
                        setState(() {});
                      },
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
                      onSort: (columnIndex, _) {},
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          'Date',
                          style: context.topology.textTheme.titleSmall?.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                      ),
                      onSort: (columnIndex, _) {},
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
                  rows: List.generate(2, (index) {
                    // final data = jobs[index];
                    // final isEven = index % 2 == 0;

                    return DataRow(
                      // color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      //   return isEven ? context.colors.primary.withOpacity(0.05) : null;
                      // }),
                      cells: [
                        DataCell(
                          Text(
                            'SPT/RPT/CCU/TCS0001/045',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            'This Report Complies With The Lifting Operations And Lifting Equipment Regulations 1998',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '09-Nov-202',
                            style: context.topology.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: CommonButton(
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                              onPressed: () {},
                              text: 'Action',
                              textStyle: context.topology.textTheme.bodySmall?.copyWith(
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
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Text('Mobile View');
  }
}
