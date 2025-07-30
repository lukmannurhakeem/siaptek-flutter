import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/site_model.dart';
import 'package:base_app/route/route.dart';
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
      'Ship Food Supply and Services Warehouse',
      'SFSS Yard',
      '-',
      'Ship Food Supply & Services Sdn Bhd',
      'SFSSSB',
      'active',
      'No 3, Lot 294, Jalan Bintulu-Tatau, Sibiyu Industrial Estate, 97000, Bintulu, Sarawak, Malaysia.',
      'Siaptek Sdn. Bhd.',
    ),
    SiteModel(
      'AMARIT-A',
      'AMA',
      'Offshore Malaysia',
      'Carigali-PTTEPI Operating Company Sdn Bhd',
      'COPC',
      'active',
      'Platform AMA-1, Offshore Block PM3 CAA, South China Sea, Malaysia.',
      'Carigali-PTTEPI Operating Company Sdn Bhd',
    ),
    SiteModel(
      'Petronas Kerteh Integrated Petroleum Complex',
      'KIPC',
      'Terengganu',
      'Petroliam Nasional Berhad',
      'PETRONAS',
      'active',
      'PLO 15, Kawasan Perindustrian Kerteh, 24300 Kerteh, Terengganu, Malaysia.',
      'Petronas Chemicals Group Berhad',
    ),
    SiteModel(
      'Shell Bintulu Gas Terminal',
      'SBGT',
      'Sarawak',
      'Shell Gas Malaysia Sdn Bhd',
      'SGMSB',
      'active',
      'Tanjung Kidurong, 97000 Bintulu, Sarawak, Malaysia.',
      'Shell Malaysia Trading Sdn Bhd',
    ),
    SiteModel(
      'MISC Maritime Training Centre',
      'MMTC',
      'Alam Shah',
      'MISC Maritime Training Sdn Bhd',
      'MMTSB',
      'active',
      'Lot 906, Jalan Alam Shah 13/AH, Seksyen 13, 40100 Shah Alam, Selangor, Malaysia.',
      'MISC Berhad',
    ),
    SiteModel(
      'Labuan Deepwater Terminal',
      'LDT',
      'Federal Territory of Labuan',
      'Malaysia Marine and Heavy Engineering Sdn Bhd',
      'MMHE',
      'active',
      'Rancha-Rancha Industrial Site, 87000 Labuan F.T., Malaysia.',
      'Malaysia Marine and Heavy Engineering Holdings Berhad',
    ),
    SiteModel(
      'Pengerang Integrated Complex',
      'PIC',
      'Johor',
      'Pengerang Integrated Petroleum Complex Sdn Bhd',
      'PIPCSB',
      'active',
      'Pengerang Industrial Complex, Pengerang, 81600 Pengerang, Johor, Malaysia.',
      'Petronas Refinery and Petrochemical Corporation Sdn Bhd',
    ),
    SiteModel(
      'Sabah Gas Terminal',
      'SGT',
      'Kimanis, Sabah',
      'Petronas Gas Berhad',
      'PGB',
      'active',
      'Kimanis Gas Terminal, 89700 Kimanis, Sabah, Malaysia.',
      'Petronas Gas Berhad',
    ),
    SiteModel(
      'Tanjung Langsat Port Complex',
      'TLPC',
      'Johor',
      'Johor Port Berhad',
      'JPB',
      'active',
      'Tanjung Langsat Port, 81700 Pasir Gudang, Johor, Malaysia.',
      'Johor Port Berhad',
    ),
    SiteModel(
      'PCHEM Kerteh Olefins Plant',
      'PKOP',
      'Terengganu',
      'Petroliam Nasional Berhad',
      'PETRONAS',
      'active',
      'PLO 18, Kawasan Perindustrian Kerteh, 24300 Kerteh, Terengganu, Malaysia.',
      'Petronas Chemicals Olefins Sdn Bhd',
    ),
    SiteModel(
      'Sungai Udang Power Plant',
      'SUPP',
      'Melaka',
      'Tenaga Nasional Berhad',
      'TNB',
      'active',
      'Jalan Sungai Udang, 76300 Sungai Udang, Melaka, Malaysia.',
      'TNB Power Generation Sdn Bhd',
    ),
    SiteModel(
      'Port Dickson Refinery',
      'PDR',
      'Negeri Sembilan',
      'Hengyuan Refining Company Berhad',
      'HRCB',
      'active',
      'Jalan Pantai, 71050 Port Dickson, Negeri Sembilan, Malaysia.',
      'Hengyuan Refining Company Berhad',
    ),
    SiteModel(
      'Gebeng Industrial Estate',
      'GIE',
      'Pahang',
      'East Coast Economic Region Development Council',
      'ECERDC',
      'active',
      'Kawasan Perindustrian Gebeng, 26080 Kuantan, Pahang, Malaysia.',
      'ECER Development Council',
    ),
    SiteModel(
      'Kuantan Port Authority',
      'KPA',
      'Pahang',
      'Kuantan Port Consortium Sdn Bhd',
      'KPCSB',
      'active',
      'Pelabuhan Kuantan, Jalan Pelabuhan, 25720 Kuantan, Pahang, Malaysia.',
      'Kuantan Port Consortium Sdn Bhd',
    ),
    SiteModel(
      'Bintulu LNG Complex',
      'BLNG',
      'Sarawak',
      'Malaysia LNG Sdn Bhd',
      'MLNG',
      'active',
      'Tanjung Kidurong, 97000 Bintulu, Sarawak, Malaysia.',
      'Malaysia LNG Sdn Bhd',
    ),
    SiteModel(
      'Westports Container Terminal',
      'WCT',
      'Selangor',
      'Westports Holdings Berhad',
      'WHB',
      'active',
      'Westports, Pulau Indah, 42920 Port Klang, Selangor, Malaysia.',
      'Westports Malaysia Sdn Bhd',
    ),
    SiteModel(
      'RAPID Phase 1 Refinery',
      'RP1R',
      'Johor',
      'Pengerang Refining Company Sdn Bhd',
      'PRCSB',
      'active',
      'RAPID Pengerang, Pengerang Industrial Complex, 81600 Pengerang, Johor, Malaysia.',
      'Pengerang Refining Company Sdn Bhd',
    ),
    SiteModel(
      'Malacca Gateway Terminal',
      'MGT',
      'Melaka',
      'MMC Port Holdings Sdn Bhd',
      'MMCPH',
      'active',
      'Pulau Melaka, 75450 Melaka, Malaysia.',
      'MMC Port Holdings Sdn Bhd',
    ),
    SiteModel(
      'Pasir Gudang Chemical Hub',
      'PGCH',
      'Johor',
      'Johor Corporation',
      'JCorp',
      'active',
      'Kawasan Perindustrian Pasir Gudang, 81700 Pasir Gudang, Johor, Malaysia.',
      'Johor Corporation',
    ),
    SiteModel(
      'Kemaman Supply Base',
      'KSB',
      'Terengganu',
      'Kemaman Supply Base Sdn Bhd',
      'KSBSB',
      'active',
      'Pelabuhan Kemaman, 24007 Kemaman, Terengganu, Malaysia.',
      'Kemaman Supply Base Sdn Bhd',
    ),
    SiteModel(
      'Sandakan Palm Oil Terminal',
      'SPOT',
      'Sabah',
      'Felda Global Ventures Holdings Berhad',
      'FGVH',
      'active',
      'Mile 7, Jalan Labuk, 90000 Sandakan, Sabah, Malaysia.',
      'FGV Palm Industries Sdn Bhd',
    ),
    SiteModel(
      'Carey Island Refinery',
      'CIR',
      'Selangor',
      'Shell Refining Company Berhad',
      'SRCB',
      'active',
      'Pulau Carey, 42960 Port Klang, Selangor, Malaysia.',
      'Shell Refining Company (Federation of Malaya) Berhad',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;
    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.spacing.l),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortColumnIndex: sortColumnIndex,
                    showCheckboxColumn: false,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Site Name',
                          style: context.topology.textTheme.titleSmall?.copyWith(
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
                          'Site Code',
                          style: context.topology.textTheme.titleSmall?.copyWith(
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
                          'Area',
                          style: context.topology.textTheme.titleSmall?.copyWith(
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
                          'Customer Name',
                          style: context.topology.textTheme.titleSmall?.copyWith(
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
                          'Customer Code',
                          style: context.topology.textTheme.titleSmall?.copyWith(
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
                          'Archived',
                          style: context.topology.textTheme.titleSmall?.copyWith(
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
                    rows: List.generate(siteModel.length, (index) {
                      final site = siteModel[index];
                      final isEven = index % 2 == 0;

                      return DataRow(
                        onSelectChanged: (selected) {
                          if (selected == true) {
                            NavigationService().navigateTo(
                              AppRoutes.siteDetails,
                              arguments: {'siteModel': siteModel[index]},
                            );
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
                              site.siteName,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              site.siteCode,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              site.area,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              site.customerName,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              site.customerCode,
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              site.status,
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
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                NavigationService().navigateTo(AppRoutes.createSite);
              },
              tooltip: 'Add New',
              child: const Icon(Icons.add),
              backgroundColor: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
