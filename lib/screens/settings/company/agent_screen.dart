import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/core/service/navigation_service.dart';
import 'package:INSPECT/model/get_agent_model.dart';
import 'package:INSPECT/providers/agent_provider.dart';
import 'package:INSPECT/route/route.dart';
import 'package:INSPECT/widget/common_button.dart';
import 'package:INSPECT/widget/common_dialog.dart';
import 'package:INSPECT/widget/common_dropdown.dart';
import 'package:INSPECT/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AgentSearchColumn { name, code, status }

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  int sortColumnIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Search filters
  AgentSearchColumn? selectedColumn;
  dynamic selectedValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AgentProvider>(context, listen: false).fetchAgents(context);
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<dynamic> _getColumnValues(List<Agent> agents, AgentSearchColumn column) {
    if (agents.isEmpty) return [];

    switch (column) {
      case AgentSearchColumn.name:
        return agents
            .map((e) => e.agentname ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case AgentSearchColumn.code:
        return agents
            .map((e) => e.accountcode ?? '')
            .where((code) => code.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      case AgentSearchColumn.status:
        return ['active', 'inactive'];
    }
  }

  List<Agent> _getFilteredAgents(List<Agent> agents) {
    if (agents.isEmpty) return [];

    var filteredList = agents;

    // Apply text search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filteredList = filteredList.where((agent) {
        final name = (agent.agentname ?? '').toLowerCase();
        final code = (agent.accountcode ?? '').toLowerCase();
        final address = (agent.address ?? '').toLowerCase();

        return name.contains(searchText) ||
            code.contains(searchText) ||
            address.contains(searchText);
      }).toList();
    }

    // Apply column filter
    if (selectedColumn != null && selectedValue != null) {
      switch (selectedColumn!) {
        case AgentSearchColumn.name:
          filteredList = filteredList.where((agent) => agent.agentname == selectedValue).toList();
          break;
        case AgentSearchColumn.code:
          filteredList = filteredList.where((agent) => agent.accountcode == selectedValue).toList();
          break;
        case AgentSearchColumn.status:
          filteredList = filteredList.where((agent) => agent.status == selectedValue).toList();
          break;
      }
    }

    return filteredList;
  }

  String _getColumnLabel(AgentSearchColumn column) {
    switch (column) {
      case AgentSearchColumn.name:
        return 'Name';
      case AgentSearchColumn.code:
        return 'Account Code';
      case AgentSearchColumn.status:
        return 'Status';
    }
  }

  String _getValueLabel(AgentSearchColumn column, dynamic value) {
    return value.toString();
  }

  void _showFilterDialog(BuildContext context, List<Agent> agents) {
    AgentSearchColumn? tempColumn = selectedColumn;
    dynamic tempValue = selectedValue;

    CommonDialog.show(
      context,
      widget: StatefulBuilder(
        builder: (context, setDialogState) {
          final columnValues = tempColumn != null ? _getColumnValues(agents, tempColumn!) : <dynamic>[];

          return SizedBox(
            height: context.screenHeight / 3.5,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Filter By',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CommonDropdown<AgentSearchColumn>(
                        value: tempColumn,
                        items: [
                          DropdownMenuItem<AgentSearchColumn>(
                            value: null,
                            child: Text(
                              'Select Column',
                              style: context.topology.textTheme.bodySmall?.copyWith(
                                color: context.colors.primary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          ...AgentSearchColumn.values.map((column) {
                            return DropdownMenuItem<AgentSearchColumn>(
                              value: column,
                              child: Text(
                                _getColumnLabel(column),
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            tempColumn = value;
                            tempValue = null;
                          });
                        },
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
                        'Value',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: tempColumn == null
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: context.colors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.colors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Select a column first',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary.withOpacity(0.5),
                                ),
                              ),
                            )
                          : CommonDropdown<dynamic>(
                              value: tempValue,
                              items: [
                                DropdownMenuItem<dynamic>(
                                  value: null,
                                  child: Text(
                                    'All',
                                    style: context.topology.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                ...columnValues.map((value) {
                                  return DropdownMenuItem<dynamic>(
                                    value: value,
                                    child: Text(
                                      _getValueLabel(tempColumn!, value),
                                      style: context.topology.textTheme.bodySmall?.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setDialogState(() {
                                  tempValue = value;
                                });
                              },
                            ),
                    ),
                  ],
                ),
                context.vL,
                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: 'Clear',
                        onPressed: () {
                          setState(() {
                            selectedColumn = null;
                            selectedValue = null;
                          });
                          NavigationService().goBack();
                        },
                      ),
                    ),
                    context.hS,
                    Expanded(
                      child: CommonButton(
                        text: 'Apply',
                        onPressed: () {
                          setState(() {
                            selectedColumn = tempColumn;
                            selectedValue = tempValue;
                          });
                          NavigationService().goBack();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentProvider>(
      builder: (context, provider, child) {
        final agents = provider.agents;
        final filteredAgents = _getFilteredAgents(agents);

        if (agents.isEmpty) {
          return _buildEmptyState(context);
        }

        return context.isTablet
            ? _buildTabletLayout(context, filteredAgents, agents)
            : _buildMobileLayout(context, filteredAgents, agents);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/bg_2.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: context.screenHeight - kToolbarHeight * 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              context.vXxl,
              Text(
                'You do not have agents right now',
                style: context.topology.textTheme.titleMedium?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              Text(
                'Add your first agent',
                textAlign: TextAlign.center,
                style: context.topology.textTheme.bodySmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
              context.vL,
              ElevatedButton.icon(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.agentCreateScreen);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Agent'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    List<Agent> filteredAgents,
    List<Agent> allAgents,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: context.screenHeight - (kToolbarHeight * 1.25),
          child: Padding(
            padding: context.paddingHorizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.agentCreateScreen);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by name, code, or address...',
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
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: (selectedColumn != null && selectedValue != null)
                              ? context.colors.primary
                              : context.colors.primary.withOpacity(0.5),
                        ),
                        onPressed: () => _showFilterDialog(context, allAgents),
                      ),
                    ],
                  ),
                ),
                context.vM,
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredAgents.length} agent${filteredAgents.length != 1 ? 's' : ''} found',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      if (selectedColumn != null && selectedValue != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColumn = null;
                              selectedValue = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Filter: ${_getColumnLabel(selectedColumn!)}: ${_getValueLabel(selectedColumn!, selectedValue)}',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.close, size: 14, color: context.colors.primary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredAgents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: context.colors.primary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No agents found',
                                style: context.topology.textTheme.titleMedium?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await Provider.of<AgentProvider>(
                              context,
                              listen: false,
                            ).fetchAgents(context);
                          },
                          child: ListView(
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
                                    columns: _buildColumns(context),
                                    rows: List.generate(filteredAgents.length, (index) {
                                      final data = filteredAgents[index];
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<Agent> filteredAgents,
    List<Agent> allAgents,
  ) {
    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - (kToolbarHeight * 1.25),
      child: Stack(
        children: [
          Padding(
            padding: context.paddingHorizontal,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      NavigationService().navigateTo(AppRoutes.agentCreateScreen);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New'),
                    style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _searchController,
                  hintText: 'Search by name, code, or address...',
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
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: (selectedColumn != null && selectedValue != null)
                              ? context.colors.primary
                              : context.colors.primary.withOpacity(0.5),
                        ),
                        onPressed: () => _showFilterDialog(context, allAgents),
                      ),
                    ],
                  ),
                ),
                context.vM,
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredAgents.length} agent${filteredAgents.length != 1 ? 's' : ''} found',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      if (selectedColumn != null && selectedValue != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColumn = null;
                              selectedValue = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Filter: ${_getColumnLabel(selectedColumn!)}: ${_getValueLabel(selectedColumn!, selectedValue)}',
                                  style: context.topology.textTheme.bodySmall?.copyWith(
                                    color: context.colors.primary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.close, size: 14, color: context.colors.primary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredAgents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: context.colors.primary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No agents found',
                                style: context.topology.textTheme.titleMedium?.copyWith(
                                  color: context.colors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter',
                                style: context.topology.textTheme.bodySmall?.copyWith(
                                  color: context.colors.primary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => Provider.of<AgentProvider>(
                            context,
                            listen: false,
                          ).fetchAgents(context),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              sortColumnIndex: sortColumnIndex,
                              showCheckboxColumn: false,
                              columnSpacing: 20,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 56,
                              columns: _buildColumns(context),
                              rows: List.generate(filteredAgents.length, (index) {
                                final data = filteredAgents[index];
                                final isEven = index % 2 == 0;
                                return _buildRow(context, data, isEven);
                              }),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (filteredAgents.isNotEmpty)
            Positioned(
              bottom: 50,
              right: 30,
              child: FloatingActionButton(
                onPressed: () {
                  NavigationService().navigateTo(AppRoutes.agentCreateScreen);
                },
                tooltip: 'Add New',
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
            'Account Code',
            style: context.topology.textTheme.titleSmall?.copyWith(color: context.colors.primary),
          ),
        ),
        onSort: (columnIndex, _) {
          setState(() {
            sortColumnIndex = columnIndex;
          });
        },
      ), DataColumn(
        label: Expanded(
          child: Text(
            'Agent Id',
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
            'Address',
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

  DataRow _buildRow(BuildContext context, Agent data, bool isEven) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
        (_) => isEven ? context.colors.primary.withOpacity(0.05) : null,
      ),
      cells: [
        DataCell(
          Text(
            data.agentname ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.accountcode ?? '',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
            DataCell(
          Text(
            data.agentid ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        DataCell(
          Text(
            data.address ?? '-',
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
        
      ],
    );
  }
}