import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/model/site_model.dart';
import 'package:flutter/material.dart';

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  int sortColumnIndex = 0;

  List<SiteModel> siteModel = [
    SiteModel(
      'SHip Food Supply and Services Warehouse',
      'SFSS Yard',
      '',
      'Ship Food Supply & Services Sdn Bhd',
      'SFSSSB',
      'active',
    ),
    SiteModel(
      'AMARIT-A',
      'AMA',
      'Offshore Malaysia',
      'Carigali-PTTEPI Operating Company Sdn Bhd',
      'COPC',
      'active',
    ),
    SiteModel(
      'Petronas Kerteh Integrated Petroleum Complex',
      'KIPC',
      'Terengganu',
      'Petroliam Nasional Berhad',
      'PETRONAS',
      'active',
    ),
    SiteModel(
      'Shell Bintulu Gas Terminal',
      'SBGT',
      'Sarawak',
      'Shell Gas Malaysia Sdn Bhd',
      'SGMSB',
      'active',
    ),
    SiteModel(
      'MISC Maritime Training Centre',
      'MMTC',
      'Alam Shah',
      'MISC Maritime Training Sdn Bhd',
      'MMTSB',
      'active',
    ),
    SiteModel(
      'Labuan Deepwater Terminal',
      'LDT',
      'Federal Territory of Labuan',
      'Malaysia Marine and Heavy Engineering Sdn Bhd',
      'MMHE',
      'active',
    ),
    SiteModel(
      'Pengerang Integrated Complex',
      'PIC',
      'Johor',
      'Pengerang Integrated Petroleum Complex Sdn Bhd',
      'PIPCSB',
      'active',
    ),
    SiteModel(
      'Sabah Gas Terminal',
      'SGT',
      'Kimanis, Sabah',
      'Petronas Gas Berhad',
      'PGB',
      'active',
    ),
    SiteModel(
      'Tanjung Langsat Port Complex',
      'TLPC',
      'Johor',
      'Johor Port Berhad',
      'JPB',
      'active',
    ),
    SiteModel(
      'PCHEM Kerteh Olefins Plant',
      'PKOP',
      'Terengganu',
      'Petroliam Nasional Berhad',
      'PETRONAS',
      'active',
    ),
    SiteModel(
      'Sungai Udang Power Plant',
      'SUPP',
      'Melaka',
      'Tenaga Nasional Berhad',
      'TNB',
      'active',
    ),
    SiteModel(
      'Port Dickson Refinery',
      'PDR',
      'Negeri Sembilan',
      'Hengyuan Refining Company Berhad',
      'HRCB',
      'active',
    ),
    SiteModel(
      'Gebeng Industrial Estate',
      'GIE',
      'Pahang',
      'East Coast Economic Region Development Council',
      'ECERDC',
      'active',
    ),
    SiteModel(
      'Kuantan Port Authority',
      'KPA',
      'Pahang',
      'Kuantan Port Consortium Sdn Bhd',
      'KPCSB',
      'active',
    ),
    SiteModel('Bintulu LNG Complex', 'BLNG', 'Sarawak', 'Malaysia LNG Sdn Bhd', 'MLNG', 'active'),
    SiteModel(
      'Westports Container Terminal',
      'WCT',
      'Selangor',
      'Westports Holdings Berhad',
      'WHB',
      'active',
    ),
    SiteModel(
      'RAPID Phase 1 Refinery',
      'RP1R',
      'Johor',
      'Pengerang Refining Company Sdn Bhd',
      'PRCSB',
      'active',
    ),
    SiteModel(
      'Malacca Gateway Terminal',
      'MGT',
      'Melaka',
      'MMC Port Holdings Sdn Bhd',
      'MMCPH',
      'active',
    ),
    SiteModel('Pasir Gudang Chemical Hub', 'PGCH', 'Johor', 'Johor Corporation', 'JCorp', 'active'),
    SiteModel(
      'Kemaman Supply Base',
      'KSB',
      'Terengganu',
      'Kemaman Supply Base Sdn Bhd',
      'KSBSB',
      'active',
    ),
    SiteModel(
      'Sandakan Palm Oil Terminal',
      'SPOT',
      'Sabah',
      'Felda Global Ventures Holdings Berhad',
      'FGVH',
      'active',
    ),
    SiteModel(
      'Carey Island Refinery',
      'CIR',
      'Selangor',
      'Shell Refining Company Berhad',
      'SRCB',
      'active',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.paddingAll,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: sortColumnIndex,
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
                  siteModel.sort((a, b) => a.siteName.compareTo(b.siteName));
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
                  siteModel.sort((a, b) => a.siteCode.compareTo(b.siteCode));
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
                  siteModel.sort((a, b) => a.area.compareTo(b.area));
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
                  siteModel.sort((a, b) => a.customerName.compareTo(b.customerName));
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
                  siteModel.sort((a, b) => a.customerCode.compareTo(b.customerCode));
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
                  siteModel.sort((a, b) => a.status.compareTo(b.status));
                });
              },
            ),
          ],
          rows:
              siteModel.map((siteModel) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        siteModel.siteName,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        siteModel.siteCode,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        siteModel.area,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        siteModel.customerName,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        siteModel.customerCode,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        siteModel.status,
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
