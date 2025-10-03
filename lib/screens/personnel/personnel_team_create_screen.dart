import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/core/service/navigation_service.dart';
import 'package:base_app/model/personnel_team_model.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/widget/add_member_dialog_widget.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PersonnelCreateTeamScreen extends StatefulWidget {
  const PersonnelCreateTeamScreen({super.key});

  @override
  State<PersonnelCreateTeamScreen> createState() => _PersonnelCreateTeamScreenState();
}

class _PersonnelCreateTeamScreenState extends State<PersonnelCreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isEditMode = false;
  final TextEditingController _searchController = TextEditingController();
  List<PersonnelTeamModel> _filteredTeams = [];
  int sortColumnIndex = 0;
  String? _selectedTeamId;

  // Store temporary members before saving the team
  List<Map<String, dynamic>> _pendingMembers = [];

  @override
  void initState() {
    super.initState();

    // Fetch personnel and team data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PersonnelProvider>();
      provider.fetchTeamPersonnel();
      provider.fetchPersonnel(); // Fetch personnel list for the dropdown
    });

    // Listen to search text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AddMemberDialog(
            onMemberSelected: (personnelId, isTeamLeader, isPrimaryLeader) {
              // Add to pending members if creating new team
              if (_selectedTeamId == null) {
                setState(() {
                  _pendingMembers.add({
                    'personnel_id': personnelId,
                    'is_team_leader': isTeamLeader,
                    'is_primary_leader': isPrimaryLeader,
                  });
                });
              }
            },
          ),
    ).then((result) {
      if (result == true && _selectedTeamId != null) {
        // Member was added successfully for existing team, refresh the list
        context.read<PersonnelProvider>().fetchTeamMembers(_selectedTeamId!);
      }
    });
  }

  void _onSearchChanged() {
    final personnelProvider = context.read<PersonnelProvider>();
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredTeams = [];
      });
      return;
    }

    // Filter teams based on search query
    final allTeams = personnelProvider.teamPersonnelList;
    setState(() {
      _filteredTeams =
          allTeams.where((team) {
            return (team.name?.toLowerCase().contains(query) ?? false) ||
                (team.type?.toLowerCase().contains(query) ?? false) ||
                (team.description?.toLowerCase().contains(query) ?? false);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Team Personal' : 'Create Team Personal',
          style: context.topology.textTheme.titleMedium?.copyWith(color: context.colors.primary),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        leading: IconButton(
          onPressed: () {
            NavigationService().goBack();
          },
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body: Consumer<PersonnelProvider>(
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
          if (teamList.isEmpty && !_isEditMode) {
            return _buildEmptyState(context);
          }

          // Show team data
          return context.isTablet
              ? _buildTabletLayout(context, teamList)
              : _buildMobileLayout(context, teamList);
        },
      ),
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
            onPressed: () => personnelProvider.fetchTeamPersonnel(),
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
        SizedBox(
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
              ],
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          right: 30,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isEditMode = true;
                _selectedTeamId = null;
                _clearForm();
              });
            },
            tooltip: 'Add New Team',
            backgroundColor: context.colors.primary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, List<PersonnelTeamModel> teamList) {
    return Consumer<PersonnelProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: context.paddingHorizontal,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                context.vM,

                // Team Info Section
                Text(
                  'Team Information',
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                context.vM,

                _widgetForm('Name', controller: _nameController, required: true),
                context.vS,
                _widgetForm('Type', controller: _typeController, required: true),
                context.vS,
                _widgetForm('Description', controller: _descriptionController, required: false),
                context.vM,
                context.divider,
                context.vM,

                // Members Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Team Members',
                      style: context.topology.textTheme.titleMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: CommonButton(
                        icon: Icons.add,
                        text: 'Add Member',
                        onPressed: () => _showAddMemberDialog(context),
                      ),
                    ),
                  ],
                ),
                context.vM,

                _buildMembersTable(context, provider),

                context.vL,

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isEditMode) ...[
                      SizedBox(
                        width: 150,
                        child: CommonButton(
                          icon: Icons.cancel,
                          text: 'Cancel',
                          onPressed: () {
                            setState(() {
                              _isEditMode = false;
                              _selectedTeamId = null;
                              _clearForm();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    SizedBox(
                      width: 200,
                      child: CommonButton(
                        icon: _selectedTeamId == null ? Icons.save : Icons.update,
                        text:
                            provider.isLoading
                                ? (_selectedTeamId == null ? 'Saving...' : 'Updating...')
                                : (_selectedTeamId == null ? 'Save Team' : 'Update Team'),
                        onPressed: provider.isLoading ? null : _submitForm,
                      ),
                    ),
                  ],
                ),
                context.vXxl,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembersTable(BuildContext context, PersonnelProvider provider) {
    // Use pending members for new teams, or fetched members for existing teams
    final displayMembers =
        _selectedTeamId == null
            ? _pendingMembers
            : provider.teamMembers
                .map(
                  (m) => {
                    'personnel_members_id': m.personnelMembersId,
                    'personnel_id': m.personnelId,
                    'is_team_leader': m.isTeamLeader,
                    'is_primary_leader': m.isPrimaryLeader,
                  },
                )
                .toList();

    if (displayMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.primary.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No members added yet. Click "Add Member" to add team members.',
            style: context.topology.textTheme.bodyMedium?.copyWith(
              color: context.colors.primary.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          columns: [
            DataColumn(
              label: Text(
                'Member',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Job Title',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Team Leader',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Primary Leader',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
          rows:
              displayMembers.map((member) {
                final personnelId = member['personnel_id'] as String;
                final personnel = provider.getPersonnelForMember(personnelId);
                final isTeamLeader = member['is_team_leader'] as bool;
                final isPrimaryLeader = member['is_primary_leader'] as bool;

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        personnel?.fullName ?? 'Unknown',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        personnel?.company.jobTitle ?? '-',
                        style: context.topology.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      Icon(
                        isTeamLeader ? Icons.check_circle : Icons.cancel,
                        color: isTeamLeader ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ),
                    DataCell(
                      Icon(
                        isPrimaryLeader ? Icons.check_circle : Icons.cancel,
                        color: isPrimaryLeader ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete, color: context.colors.error, size: 20),
                        onPressed: () {
                          if (_selectedTeamId == null) {
                            // Remove from pending members
                            setState(() {
                              _pendingMembers.removeWhere((m) => m['personnel_id'] == personnelId);
                            });
                          } else {
                            // Remove from existing team
                            _removeMember(
                              context,
                              member['personnel_members_id'] as String,
                              personnel?.fullName,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Future<void> _removeMember(BuildContext context, String memberId, String? memberName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Member'),
            content: Text(
              'Are you sure you want to remove ${memberName ?? "this member"} from the team?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true && _selectedTeamId != null && mounted) {
      final provider = context.read<PersonnelProvider>();
      final success = await provider.removeTeamMember(memberId, _selectedTeamId!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _widgetForm(String text, {TextEditingController? controller, bool required = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (required) const Text('* ', style: TextStyle(color: Colors.red)),
              Text(
                text,
                style: context.topology.textTheme.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: controller,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
            validator:
                required
                    ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '$text is required';
                      }
                      return null;
                    }
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<PersonnelTeamModel> teamList) {
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
                    hintText: 'Search by name, type, or description...',
                    style: context.topology.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                    suffixIcon: Icon(Icons.search, color: context.colors.primary),
                  ),
                  context.vM,

                  // Team count
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${teamList.length} teams found',
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
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                  _selectedTeamId = null;
                  _clearForm();
                });
              },
              tooltip: 'Add New Team',
              backgroundColor: context.colors.primary,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final personnelData = _buildPersonnelTeamData();
    final provider = context.read<PersonnelProvider>();

    if (_selectedTeamId == null) {
      // Create new team
      final success = await provider.createTeamPersonnel(personnelData);

      if (success && mounted) {
        // Get the newly created team ID from the response
        final createdTeam = provider.teamPersonnelList.firstWhere(
          (team) => team.name == _nameController.text.trim(),
          orElse: () => provider.teamPersonnelList.last,
        );

        final teamId = createdTeam.teamPersonnelId;

        // Add all pending members to the newly created team
        if (_pendingMembers.isNotEmpty) {
          for (var memberData in _pendingMembers) {
            memberData['team_personnel_id'] = teamId;
            await provider.addTeamMember(memberData);
          }
        }

        setState(() {
          _selectedTeamId = teamId;
          _pendingMembers.clear();
        });

        // Fetch the team members to display them
        await provider.fetchTeamMembers(teamId!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Team created successfully with members!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create team. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Update existing team
      final success = await provider.updateTeamPersonnel(_selectedTeamId!, personnelData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update team. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Map<String, dynamic> _buildPersonnelTeamData() {
    return {
      "name": _nameController.text.trim(),
      "parent_team": "none",
      "type": _typeController.text.trim(),
      "description": _descriptionController.text.trim(),
    };
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _descriptionController.clear();
    _pendingMembers.clear();
    context.read<PersonnelProvider>().clearData();
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
        setState(() {
          _isEditMode = true;
          _selectedTeamId = data.teamPersonnelId;
          _nameController.text = data.name ?? '';
          _typeController.text = data.type ?? '';
          _descriptionController.text = data.description ?? '';
          _pendingMembers.clear(); // Clear pending members when editing existing team
        });

        context.read<PersonnelProvider>().fetchTeamMembers(data.teamPersonnelId!);
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
