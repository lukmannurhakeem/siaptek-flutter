import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/personnel_team_model.dart';
import 'package:INSPECT/providers/personnel_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonnelTeamScreen extends StatefulWidget {
  const PersonnelTeamScreen({super.key});

  @override
  State<PersonnelTeamScreen> createState() => _PersonnelTeamScreenState();
}

class _PersonnelTeamScreenState extends State<PersonnelTeamScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PersonnelTeamModel> _filteredTeams = [];
  int sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();

    // Fetch personnel team data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonnelProvider>().fetchTeamPersonnel();
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
      _filteredTeams = provider.searchTeams(_searchController.text);
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

        // Get team list (filtered or full list)
        final teamList =
            _searchController.text.isEmpty ? personnelProvider.teamPersonnelList : _filteredTeams;

        // Show empty state
        if (teamList.isEmpty) {
          return _buildEmptyState(context);
        }

        // Show team data
        return context.isTablet
            ? _buildTabletLayout(context, teamList)
            : _buildMobileLayout(context, teamList);
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
            onPressed: () => personnelProvider.refreshTeamPersonnel(),
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
          bottom: 0,
          left: -10,
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'assets/images/bg_3.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomLeft,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
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
                    ? 'No teams found'
                    : 'No results for "${_searchController.text}"',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              if (_searchController.text.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Add your first team',
                  textAlign: TextAlign.center,
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vL,
                ElevatedButton.icon(
                  onPressed: () {
                    NavigationService().navigateTo(AppRoutes.createTeamPersonnel);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Team'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, List<PersonnelTeamModel> teamList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: context.paddingAll,
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Create New button at the top
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    NavigationService().navigateTo(AppRoutes.createTeamPersonnel, arguments: null);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New'),
                  style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Search Field
              CommonTextField(
                controller: _searchController,
                hintText: 'Search by team name, type, or description...',
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: context.colors.primary),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    Icon(Icons.search, color: context.colors.primary),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              context.vM,

              // Team count
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${teamList.length} team${teamList.length != 1 ? 's' : ''} found',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),

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
                      rows: List.generate(teamList.length, (index) {
                        final data = teamList[index];
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

  Widget _buildMobileLayout(BuildContext context, List<PersonnelTeamModel> teamList) {
    final screenHeight = context.screenHeight - (kToolbarHeight * 1.25);
    final screenWidth = context.screenWidth;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Padding(
        padding: context.paddingAll,
        child: Column(
          children: [
            // Create New button at the top
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.createTeamPersonnel, arguments: null);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New'),
                style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
              ),
            ),
            const SizedBox(height: 16),

            // Search Field
            CommonTextField(
              controller: _searchController,
              hintText: 'Search by team name, type, or description...',
              style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: context.colors.primary),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  Icon(Icons.search, color: context.colors.primary),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            context.vM,

            // Team count
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${teamList.length} team${teamList.length != 1 ? 's' : ''} found',
                  style: context.topology.textTheme.bodySmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),

            // Data Table in horizontal scroll
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: sortColumnIndex,
                  showCheckboxColumn: false,
                  columns: _buildColumns(context),
                  rows: List.generate(teamList.length, (index) {
                    final data = teamList[index];
                    final isEven = index % 2 == 0;
                    return _buildRow(context, data, isEven);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context) {
    return [
      DataColumn(
        label: Expanded(
          child: Text(
            'Team Name',
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
            'Type',
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
            'Description',
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
            'Created At',
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

  DataRow _buildRow(BuildContext context, PersonnelTeamModel data, bool isEven) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      onSelectChanged: (_) {
        NavigationService().navigateTo(
          AppRoutes.createTeamPersonnel,
          arguments: data.teamPersonnelId,
        );
      },
      cells: [
        DataCell(
          Text(
            data.name ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.type ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.description ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            data.createdAt != null
                ? '${data.createdAt!.day}/${data.createdAt!.month}/${data.createdAt!.year}'
                : '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }
}
