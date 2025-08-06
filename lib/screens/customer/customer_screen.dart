import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/model/customer_model.dart';
import 'package:flutter/material.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int sortColumnIndex = 0;

  List<CustomerModel> _customer = [
    CustomerModel('Schlumberger (M) Sdn Bhd', 'Malaysia', 'SPK00028', 'Active'),
    CustomerModel('Travailler Energy Sdn Bhd', 'Bintulu', 'QUO/SPT/KLM/2023/VII', 'Active'),
    CustomerModel('Altus Oil & Gas Malaysia', 'Kemaman, Terenganu', 'MO/SPT/ALT', 'Active'),
    CustomerModel('Petrofac (Malaysia) Ltd', 'Kuala Lumpur', 'PF/2023/001', 'Active'),
    CustomerModel(
      'Carigali-PTTEPI Operating Company Sdn Bhd',
      'MD-Foxtrot',
      'MO/SPT/KL/20/001',
      'Active',
    ),
    CustomerModel('Petronas Carigali Sdn Bhd', 'Kuala Lumpur', 'PCSB/2023/002', 'Active'),
    CustomerModel(
      'MP Offsore Pte Ltd',
      'MP PROSPER, KSB, Kemaman',
      'MPO/PROSPER/2023/001',
      'Active',
    ),
    CustomerModel('Schlumberger (M) Sdn Bhd', 'Malaysia', 'SPK00028', 'Active'),
    CustomerModel('Travailler Energy Sdn Bhd', 'Bintulu', 'QUO/SPT/KLM/2023/VII', 'Active'),
    CustomerModel('Altus Oil & Gas Malaysia', 'Kemaman, Terenganu', 'MO/SPT/ALT', 'Active'),
    CustomerModel('Petrofac (Malaysia) Ltd', 'Kuala Lumpur', 'PF/2023/001', 'Active'),
    CustomerModel(
      'Carigali-PTTEPI Operating Company Sdn Bhd',
      'MD-Foxtrot',
      'MO/SPT/KL/20/001',
      'Active',
    ),
    CustomerModel('Petronas Carigali Sdn Bhd', 'Kuala Lumpur', 'PCSB/2023/002', 'Active'),
    CustomerModel(
      'MP Offsore Pte Ltd',
      'MP PROSPER, KSB, Kemaman',
      'MPO/PROSPER/2023/001',
      'Active',
    ),
    CustomerModel('Schlumberger (M) Sdn Bhd', 'Malaysia', 'SPK00028', 'Active'),
    CustomerModel('Travailler Energy Sdn Bhd', 'Bintulu', 'QUO/SPT/KLM/2023/VII', 'Active'),
    CustomerModel('Altus Oil & Gas Malaysia', 'Kemaman, Terenganu', 'MO/SPT/ALT', 'Active'),
    CustomerModel('Petrofac (Malaysia) Ltd', 'Kuala Lumpur', 'PF/2023/001', 'Active'),
    CustomerModel(
      'Carigali-PTTEPI Operating Company Sdn Bhd',
      'MD-Foxtrot',
      'MO/SPT/KL/20/001',
      'Active',
    ),
    CustomerModel('Petronas Carigali Sdn Bhd', 'Kuala Lumpur', 'PCSB/2023/002', 'Active'),
    CustomerModel(
      'MP Offsore Pte Ltd',
      'MP PROSPER, KSB, Kemaman',
      'MPO/PROSPER/2023/001',
      'Active',
    ),
    CustomerModel('Schlumberger (M) Sdn Bhd', 'Malaysia', 'SPK00028', 'Active'),
    CustomerModel('Travailler Energy Sdn Bhd', 'Bintulu', 'QUO/SPT/KLM/2023/VII', 'Active'),
    CustomerModel('Altus Oil & Gas Malaysia', 'Kemaman, Terenganu', 'MO/SPT/ALT', 'Active'),
    CustomerModel('Petrofac (Malaysia) Ltd', 'Kuala Lumpur', 'PF/2023/001', 'Active'),
    CustomerModel(
      'Carigali-PTTEPI Operating Company Sdn Bhd',
      'MD-Foxtrot',
      'MO/SPT/KL/20/001',
      'Active',
    ),
    CustomerModel('Petronas Carigali Sdn Bhd', 'Kuala Lumpur', 'PCSB/2023/002', 'Active'),
    CustomerModel(
      'MP Offsore Pte Ltd',
      'MP PROSPER, KSB, Kemaman',
      'MPO/PROSPER/2023/001',
      'Active',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return context.isTablet
        ? LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: context.paddingAll,
              width: constraints.maxWidth,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: constraints.maxWidth, // This makes table fill the row
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Name',
                            style: context.topology.textTheme.titleMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            _customer.sort((a, b) => a.name.compareTo(b.name));
                          });
                        },
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Account Code',
                            style: context.topology.textTheme.titleMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            _customer.sort((a, b) => a.accountCode.compareTo(b.accountCode));
                          });
                        },
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Division',
                            style: context.topology.textTheme.titleMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            _customer.sort((a, b) => a.division.compareTo(b.division));
                          });
                        },
                      ),
                      DataColumn(
                        label: Expanded(
                          child: Text(
                            'Status',
                            style: context.topology.textTheme.titleMedium?.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ),
                        onSort: (columnIndex, _) {
                          setState(() {
                            sortColumnIndex = columnIndex;
                            _customer.sort((a, b) => a.status.compareTo(b.status));
                          });
                        },
                      ),
                    ],
                    rows: List.generate(_customer.length, (index) {
                      final data = _customer[index];
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
                              data.accountCode,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.division,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              data.status,
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
            );
          },
        )
        : Container(
          padding: context.paddingAll,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: sortColumnIndex,
              showCheckboxColumn: false,
              columns: [
                DataColumn(
                  label: Text(
                    'Name',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  onSort: (columnIndex, _) {
                    setState(() {
                      sortColumnIndex = columnIndex;
                      _customer.sort((a, b) => a.name.compareTo(b.name));
                    });
                  },
                ),
                DataColumn(
                  label: Text(
                    'Account Code',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  onSort: (columnIndex, _) {
                    setState(() {
                      sortColumnIndex = columnIndex;
                      _customer.sort((a, b) => a.accountCode.compareTo(b.accountCode));
                    });
                  },
                ),
                DataColumn(
                  label: Text(
                    'Division',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  onSort: (columnIndex, _) {
                    setState(() {
                      sortColumnIndex = columnIndex;
                      _customer.sort((a, b) => a.division.compareTo(b.division));
                    });
                  },
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  onSort: (columnIndex, _) {
                    setState(() {
                      sortColumnIndex = columnIndex;
                      _customer.sort((a, b) => a.status.compareTo(b.status));
                    });
                  },
                ),
              ],
              rows: List.generate(_customer.length, (index) {
                final data = _customer[index];
                final isEven = index % 2 == 0;

                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
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
                        data.division,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        data.accountCode,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        data.status,
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
}
