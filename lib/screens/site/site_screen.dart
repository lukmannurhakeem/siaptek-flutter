import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/providers/site_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../model/get_site_model.dart'; // Adjust if your model is in another folder

class SiteScreen extends StatefulWidget {
  const SiteScreen({super.key});

  @override
  State<SiteScreen> createState() => _SiteScreenState();
}

class _SiteScreenState extends State<SiteScreen> {
  int sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SiteProvider>(context, listen: false).fetchSite(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SiteProvider>(context);
    final sites = provider.sites;

    if (sites.isEmpty) {
      return Stack(
        children: [
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/no-file.svg',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              height: context.screenHeight * 0.3,
            ),
          ),
          Container(
            width: double.infinity,
            height: context.screenHeight - kToolbarHeight * 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                context.vXxl,
                Text(
                  'You do not have list right now',
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                NavigationService().navigateTo(AppRoutes.createSite); // Ensure this route exists
              },
              tooltip: 'Add New',
              child: const Icon(Icons.add),
              backgroundColor: context.colors.primary,
            ),
          ),
        ],
      );
    }

    return context.isTablet
        ? _buildTabletLayout(context, sites)
        : _buildMobileLayout(context, sites);
  }

  Widget _buildTabletLayout(BuildContext context, List<Site> sites) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: context.paddingAll,
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    NavigationService().navigateTo(AppRoutes.createSite);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                  style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      showCheckboxColumn: false,
                      columns: _buildColumns(context),
                      rows: List.generate(sites.length, (index) {
                        final data = sites[index];
                        final isEven = index % 2 == 0;
                        return _buildRow(context, data, isEven);
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<Site> sites) {
    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - (kToolbarHeight * 1.25),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              padding: context.paddingAll,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: sortColumnIndex,
                  showCheckboxColumn: false,
                  columns: _buildColumns(context),
                  rows: List.generate(sites.length, (index) {
                    final data = sites[index];
                    final isEven = index % 2 == 0;
                    return _buildRow(context, data, isEven);
                  }),
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

  List<DataColumn> _buildColumns(BuildContext context) {
    return [
      DataColumn(
        label: Expanded(
          child: Text(
            'Site Name',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Site Code',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Division',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
      DataColumn(
        label: Expanded(
          child: Text(
            'Status',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ),
    ];
  }

  DataRow _buildRow(BuildContext context, Site data, bool isEven) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      cells: [
        DataCell(
          Text(
            data.siteName ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.siteCode ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.division ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.archived == true ? 'Archived' : 'Active',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
