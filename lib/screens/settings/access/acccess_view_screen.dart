import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/personnel_model.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/route/route.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AccessViewScreen extends StatefulWidget {
  const AccessViewScreen({super.key});

  @override
  State<AccessViewScreen> createState() => _AccessViewScreenState();
}

class _AccessViewScreenState extends State<AccessViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PersonnelData> _filteredPersonnel = [];
  int sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();

    // Fetch personnel data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonnelProvider>().fetchPersonnel();
    });

    // Listen to search text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = context.read<PersonnelProvider>();
    setState(() {
      _filteredPersonnel = provider.searchPersonnel(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonnelProvider>(
      builder: (context, personnelProvider, child) {
        // Show loading indicator
        if (personnelProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error message
        if (personnelProvider.errorMessage != null) {
          return _buildErrorState(context, personnelProvider);
        }

        // Get personnel list (filtered or full list, showing only active personnel)
        final personnelList =
            _searchController.text.isEmpty
                ? personnelProvider.activePersonnel
                : _filteredPersonnel.where((p) => !p.personnel.isArchived).toList();

        // Show empty state
        if (personnelList.isEmpty) {
          return _buildEmptyState(context);
        }

        // Show personnel data
        return context.isTablet
            ? _buildTabletLayout(context, personnelList)
            : _buildMobileLayout(context, personnelList);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, PersonnelProvider personnelProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: context.colors.error),
          const SizedBox(height: 16),
          Text(
            personnelProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: context.topology.textTheme.bodyMedium?.copyWith(color: context.colors.error),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => personnelProvider.refreshPersonnel(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                _searchController.text.isEmpty
                    ? 'No personnel found'
                    : 'No results for "${_searchController.text}"',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              if (_searchController.text.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Add your first personnel member',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          right: 30,
          child: FloatingActionButton(
            onPressed: () {
              NavigationService().navigateTo(AppRoutes.accessScreen, arguments: null);
            },
            tooltip: 'Add New Personnel',
            backgroundColor: context.colors.primary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, List<PersonnelData> personnelList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: context.paddingAll,
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Field
              CommonTextField(
                controller: _searchController,
                hintText: 'Search by name, job title, or employee number...',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
                suffixIcon: Icon(Icons.search, color: context.colors.primary),
              ),
              context.vM,

              // Personnel count and Create button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${personnelList.length} personnel found',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.accessScreen);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Data Table
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: DataTable(
                      sortColumnIndex: sortColumnIndex,
                      showCheckboxColumn: false,
                      columns: _buildColumns(context),
                      rows: List.generate(personnelList.length, (index) {
                        final data = personnelList[index];
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

  Widget _buildMobileLayout(BuildContext context, List<PersonnelData> personnelList) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: context.paddingAll,
              child: Column(
                children: [
                  // Search Field
                  CommonTextField(
                    controller: _searchController,
                    hintText: 'Search by name, job title, or employee number...',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                    suffixIcon: Icon(Icons.search, color: context.colors.primary),
                  ),
                  context.vM,

                  // Personnel count
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${personnelList.length} personnel found',
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Table in horizontal scroll
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: sortColumnIndex,
                        showCheckboxColumn: false,
                        columns: _buildColumns(context),
                        rows: List.generate(personnelList.length, (index) {
                          final data = personnelList[index];
                          final isEven = index % 2 == 0;
                          return _buildRow(context, data, isEven);
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                NavigationService().navigateTo(AppRoutes.accessScreen, arguments: null);
              },
              tooltip: 'Add New Personnel',
              backgroundColor: context.colors.primary,
              child: const Icon(Icons.add),
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
            'Name',
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
            'Job Title',
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
            'Employee Number',
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

  DataRow _buildRow(BuildContext context, PersonnelData data, bool isEven) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      onSelectChanged: (_) {
        NavigationService().navigateTo(
          AppRoutes.personnelDetails,
          arguments: {'personnelId': data.personnel.personnelID},
        );
      },
      cells: [
        DataCell(
          Text(
            data.displayName,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.company.jobTitle.isNotEmpty ? data.company.jobTitle : '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.company.employeeNumber.isNotEmpty ? data.company.employeeNumber : '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.personnel.isArchived ? 'Archived' : 'Active',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
