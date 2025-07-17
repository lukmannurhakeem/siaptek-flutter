import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/model/job.dart';
import 'package:flutter/material.dart';

class OpenJobsScreen extends StatefulWidget {
  const OpenJobsScreen({super.key});

  @override
  State<OpenJobsScreen> createState() => _OpenJobsScreenState();
}

class _OpenJobsScreenState extends State<OpenJobsScreen> {
  int sortColumnIndex = 0;

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
    return ListView(children: [
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
                    style: context.topology.textTheme.titleMedium?.copyWith(
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
                    style: context.topology.textTheme.titleMedium?.copyWith(
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
                    style: context.topology.textTheme.titleMedium?.copyWith(
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
              rows: jobs.map((job) {
                return DataRow(cells: [
                  DataCell(
                    Text(
                      job.name,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      job.site,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      job.id,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      )
    ]);
  }
}
