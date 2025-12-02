import 'package:base_app/core/extension/theme_extension.dart';
import 'package:base_app/providers/job_provider.dart';
import 'package:base_app/providers/personnel_provider.dart';
import 'package:base_app/providers/planner_provider.dart';
import 'package:base_app/providers/system_provider.dart';
import 'package:base_app/widget/common_button.dart';
import 'package:base_app/widget/common_date_picker_input.dart';
import 'package:base_app/widget/common_dropdown.dart';
import 'package:base_app/widget/common_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TeamPlannerScreen extends StatefulWidget {
  const TeamPlannerScreen({super.key});

  @override
  State<TeamPlannerScreen> createState() => _TeamPlannerScreenState();
}

class _TeamPlannerScreenState extends State<TeamPlannerScreen> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _planTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _estimatedDurationController = TextEditingController();

  // dropdown selections
  String _selectedPriority = 'normal';
  String _selectedStatus = 'pending';
  String _selectedEventType = 'test';
  String _selectedAssignmentType = 'personnel';
  String? _selectedAssignedToId;
  String _selectedAssignedToName = 'Select Assignment';

  // Job selection
  String? _selectedJobId;
  String _selectedJobName = 'Select Job';

  // dates
  DateTime? _plannedStartDate;
  DateTime? _plannedEndDate;
  final _plannedStartController = TextEditingController();
  final _plannedEndController = TextEditingController();

  // checklist & tags
  final List<String> _checklistTasks = [];
  final List<String> _tags = [];
  final _taskController = TextEditingController();
  final _tagController = TextEditingController();

  // optional files (if you later allow attachments)
  PlatformFile? _attachmentFile;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Fetch all necessary data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonnelProvider>().fetchPersonnel();
      context.read<PersonnelProvider>().fetchTeamPersonnel();
      context.read<SystemProvider>().fetchDivision();
      context.read<JobProvider>().fetchJobModel(context);
    });
  }

  @override
  void dispose() {
    _planTitleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _estimatedDurationController.dispose();
    _taskController.dispose();
    _tagController.dispose();
    _plannedStartController.dispose();
    _plannedEndController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStart ? (_plannedStartDate ?? DateTime.now()) : (_plannedEndDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime == null) {
      final dt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      _applyPickedDate(dt, isStart);
      return;
    }

    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    _applyPickedDate(dateTime, isStart);
  }

  void _applyPickedDate(DateTime dt, bool isStart) {
    setState(() {
      if (isStart) {
        _plannedStartDate = dt;
        _plannedStartController.text = DateFormat('MMM dd, yyyy - HH:mm').format(dt);
      } else {
        _plannedEndDate = dt;
        _plannedEndController.text = DateFormat('MMM dd, yyyy - HH:mm').format(dt);
      }
    });
  }

  void _addTask() {
    final t = _taskController.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _checklistTasks.add(t);
      _taskController.clear();
    });
  }

  void _removeTask(int index) {
    setState(() {
      _checklistTasks.removeAt(index);
    });
  }

  void _addTag() {
    final t = _tagController.text.trim();
    if (t.isEmpty || _tags.contains(t)) return;
    setState(() {
      _tags.add(t);
      _tagController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showJobPicker() {
    final jobProvider = context.read<JobProvider>();
    final jobs = jobProvider.jobModel?.data ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (modalContext) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (sheetContext, scrollController) {
              List<Widget> items = [];

              if (jobs.isEmpty) {
                items = [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No jobs available',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              } else {
                items =
                    jobs.map((job) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colors.primary.withOpacity(0.1),
                          child: Icon(Icons.work, color: context.colors.primary),
                        ),
                        title: Text(job.jobId ?? 'Unknown Job'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.clientName ?? 'No Client'),
                            Text(
                              job.siteName ?? 'No Site',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          _selectedJobId == job.jobId ? Icons.check_circle : Icons.circle_outlined,
                          color: _selectedJobId == job.jobId ? Colors.green : Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedJobId = job.jobId;
                            _selectedJobName = '${job.jobId} - ${job.clientName}';
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList();
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.work, color: context.colors.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Select Job',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: ListView(controller: scrollController, children: items)),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _showAssignmentPicker() {
    final personnelProvider = context.read<PersonnelProvider>();
    final systemProvider = context.read<SystemProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (modalContext) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (sheetContext, scrollController) {
              List<Widget> items = [];

              // Build list based on assignment type
              if (_selectedAssignmentType == 'personnel') {
                final activePersonnel = personnelProvider.activePersonnel;
                if (activePersonnel.isEmpty) {
                  items = [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No personnel available',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                } else {
                  items =
                      activePersonnel.map((person) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: context.colors.primary.withOpacity(0.1),
                            child: Text(
                              person.displayName.isNotEmpty
                                  ? person.displayName[0].toUpperCase()
                                  : 'P',
                              style: TextStyle(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(person.displayName),
                          subtitle: Text(person.company.jobTitle),
                          trailing: Icon(
                            _selectedAssignedToId == person.personnel.personnelID
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                _selectedAssignedToId == person.personnel.personnelID
                                    ? Colors.green
                                    : Colors.grey,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedAssignedToId = person.personnel.personnelID;
                              _selectedAssignedToName = person.displayName;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList();
                }
              } else if (_selectedAssignmentType == 'team') {
                final teams = personnelProvider.teamPersonnelList;
                if (teams.isEmpty) {
                  items = [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No teams available',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                } else {
                  items =
                      teams.map((team) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: context.colors.primary.withOpacity(0.1),
                            child: Icon(Icons.group, color: context.colors.primary),
                          ),
                          title: Text(team.name ?? 'Unnamed Team'),
                          subtitle: Text(team.type ?? 'No Type'),
                          trailing: Icon(
                            _selectedAssignedToId == team.teamPersonnelId
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                _selectedAssignedToId == team.teamPersonnelId
                                    ? Colors.green
                                    : Colors.grey,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedAssignedToId = team.teamPersonnelId;
                              _selectedAssignedToName = team.name ?? 'Unnamed Team';
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList();
                }
              } else if (_selectedAssignmentType == 'department') {
                final divisions = systemProvider.divisions;
                if (divisions.isEmpty) {
                  items = [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No departments available',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                } else {
                  items =
                      divisions.map((division) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: context.colors.primary.withOpacity(0.1),
                            child: Icon(Icons.business, color: context.colors.primary),
                          ),
                          title: Text(division.divisionname ?? 'Unnamed Division'),
                          subtitle: Text(division.divisioncode ?? 'No Code'),
                          trailing: Icon(
                            _selectedAssignedToId == division.divisionid
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                _selectedAssignedToId == division.divisionid
                                    ? Colors.green
                                    : Colors.grey,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedAssignedToId = division.divisionid;
                              _selectedAssignedToName = division.divisionname ?? 'Unnamed Division';
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList();
                }
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _selectedAssignmentType == 'personnel'
                              ? Icons.person
                              : _selectedAssignmentType == 'team'
                              ? Icons.group
                              : Icons.business,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select ${_selectedAssignmentType == 'personnel'
                              ? 'Personnel'
                              : _selectedAssignmentType == 'team'
                              ? 'Team'
                              : 'Department'}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: ListView(controller: scrollController, children: items)),
                  ],
                ),
              );
            },
          ),
    );
  }

  Future<void> _submitForm() async {
    print('clicked');
    if (!_formKey.currentState!.validate()) return;

    // Validation
    if (_selectedJobId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a job')));
      return;
    }
    if (_plannedStartDate == null || _plannedEndDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select start and end date/time')));
      return;
    }
    if (_plannedEndDate!.isBefore(_plannedStartDate!)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('End date must be after start date')));
      return;
    }
    if (_selectedAssignedToId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an assignment')));
      return;
    }

    final plannerProvider = Provider.of<PlannerProvider>(context, listen: false);

    final startDateUtc = _plannedStartDate?.toUtc().toIso8601String();
    final endDateUtc = _plannedEndDate?.toUtc().toIso8601String();

    final planData = {
      "eventType": _selectedEventType,
      "jobId": _selectedJobId,
      "planTitle": _planTitleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "priority": _selectedPriority,
      "plannedStartDate": startDateUtc,
      "plannedEndDate": endDateUtc,
      "estimatedDuration": int.tryParse(_estimatedDurationController.text) ?? 0,
      "status": _selectedStatus,
      "assignedTo": _selectedAssignedToId,
      "assignmentType": _selectedAssignmentType,
      "checklistItems": {"tasks": _checklistTasks},
      "attendees": {},
      "notes": _notesController.text.trim(),
      "tags": {"categories": _tags},
    };

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: context.colors.primary),
                    const SizedBox(height: 16),
                    Text('Creating plan...', style: context.topology.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
    );

    setState(() => _isSubmitting = true);

    final success = await plannerProvider.createInspectionPlan(planData);

    if (mounted) Navigator.of(context).pop();

    setState(() => _isSubmitting = false);

    if (success) {
      // Reset form
      _formKey.currentState!.reset();
      _planTitleController.clear();
      _descriptionController.clear();
      _notesController.clear();
      _estimatedDurationController.clear();
      _taskController.clear();
      _tagController.clear();
      _plannedStartController.clear();
      _plannedEndController.clear();
      setState(() {
        _checklistTasks.clear();
        _tags.clear();
        _plannedStartDate = null;
        _plannedEndDate = null;
        _selectedPriority = 'normal';
        _selectedStatus = 'pending';
        _selectedEventType = 'test';
        _selectedAssignmentType = 'personnel';
        _selectedAssignedToId = null;
        _selectedAssignedToName = 'Select Assignment';
        _selectedJobId = null;
        _selectedJobName = 'Select Job';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  plannerProvider.pendingSyncCount > 0
                      ? 'Plan queued for sync (offline)'
                      : 'Plan created successfully!',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(plannerProvider.errorMessage ?? 'Failed to create plan')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _submitForm),
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: context.colors.primary, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: context.topology.textTheme.titleMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String title, {
    TextEditingController? controller,
    bool isRequired = false,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title + (isRequired ? ' *' : ''),
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: isRequired ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: CommonTextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: context.topology.textTheme.bodySmall?.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    IconData? icon,
    required bool isStart,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: () => _selectDate(context, isStart),
            child: AbsorbPointer(
              absorbing: true,
              child: CommonDatePickerInput(label: '', controller: controller),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String label,
    String value,
    List<String> items, {
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.colors.primary.withOpacity(0.7)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: CommonDropdown<String>(
            value: value,
            items:
                items
                    .map(
                      (it) => DropdownMenuItem<String>(
                        value: it,
                        child: Text(it.toUpperCase(), style: context.topology.textTheme.bodySmall),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
            borderColor: context.colors.primary,
            textStyle: context.topology.textTheme.bodySmall?.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobSelector(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Icon(Icons.work, size: 16, color: context.colors.primary.withOpacity(0.7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Select Job *',
                  style: context.topology.textTheme.titleSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        context.hS,
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: _showJobPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedJobId == null ? Colors.grey.shade300 : context.colors.primary,
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedJobName,
                      style: context.topology.textTheme.bodySmall?.copyWith(
                        color: _selectedJobId == null ? Colors.grey : context.colors.primary,
                        fontWeight: _selectedJobId != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: context.colors.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Checklist Tasks', Icons.checklist),
        context.vM,
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: _taskController,
                hintText: 'Enter task...',
                onTap: () => _addTask(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addTask,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (_checklistTasks.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._checklistTasks.asMap().entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              child: ListTile(
                dense: true,
                leading: Icon(Icons.task_alt, size: 20, color: context.colors.primary),
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _removeTask(entry.key),
                ),
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildTagsCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Tags', Icons.local_offer),
        context.vM,
        Row(
          children: [
            Expanded(
              child: CommonTextField(
                controller: _tagController,
                hintText: 'Enter tag...',
                onTap: () => _addTag(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _addTag,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeTag(tag),
                        backgroundColor: context.colors.primary.withOpacity(0.1),
                        labelStyle: TextStyle(color: context.colors.primary),
                      ),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPlannerInfoCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Planner Information', Icons.event_note),
        context.vM,
        _buildJobSelector(context),
        context.vS,
        _buildRow(
          context,
          'Plan Title',
          controller: _planTitleController,
          isRequired: true,
          icon: Icons.title,
        ),
        context.vS,
        _buildRow(
          context,
          'Description',
          controller: _descriptionController,
          icon: Icons.notes,
          maxLines: 3,
        ),
        context.vS,
        _buildDropdown(
          context,
          'Event Type',
          _selectedEventType,
          ['test', 'inspection', 'maintenance', 'audit'],
          onChanged: (v) => setState(() => _selectedEventType = v ?? 'test'),
          icon: Icons.category,
        ),
        context.vS,
        _buildDropdown(
          context,
          'Priority',
          _selectedPriority,
          ['low', 'normal', 'high', 'critical'],
          onChanged: (v) => setState(() => _selectedPriority = v ?? 'normal'),
          icon: Icons.flag,
        ),
        context.vS,
        _buildDropdown(
          context,
          'Status',
          _selectedStatus,
          ['pending', 'in_progress', 'completed', 'cancelled'],
          onChanged: (v) => setState(() => _selectedStatus = v ?? 'pending'),
          icon: Icons.info,
        ),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Duration & Schedule', Icons.schedule),
        context.vM,
        // _buildRow(
        //   context,
        //   'Estimated Duration (minutes)',
        //   controller: _estimatedDurationController,
        //   icon: Icons.timer,
        //   keyboardType: TextInputType.number,
        // ),
        // context.vS,
        _buildDateField(
          context,
          'Planned Start Date',
          _plannedStartController,
          icon: Icons.event,
          isStart: true,
        ),
        context.vS,
        _buildDateField(
          context,
          'Planned End Date',
          _plannedEndController,
          icon: Icons.event_available,
          isStart: false,
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Assignment', Icons.assignment_ind),
        context.vM,
        _buildDropdown(
          context,
          'Assignment Type',
          _selectedAssignmentType,
          ['personnel', 'team', 'department'],
          onChanged: (v) {
            setState(() {
              _selectedAssignmentType = v ?? 'personnel';
              _selectedAssignedToId = null;
              _selectedAssignedToName = 'Select Assignment';
            });
          },
          icon: Icons.group,
        ),
        context.vS,
        // Assignment Selector
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    _selectedAssignmentType == 'personnel'
                        ? Icons.person
                        : _selectedAssignmentType == 'team'
                        ? Icons.group
                        : Icons.business,
                    size: 16,
                    color: context.colors.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Assigned To *',
                      style: context.topology.textTheme.titleSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            context.hS,
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: _showAssignmentPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          _selectedAssignedToId == null
                              ? Colors.grey.shade300
                              : context.colors.primary,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedAssignedToName,
                          style: context.topology.textTheme.bodySmall?.copyWith(
                            color:
                                _selectedAssignedToId == null
                                    ? Colors.grey
                                    : context.colors.primary,
                            fontWeight:
                                _selectedAssignedToId != null ? FontWeight.w500 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: context.colors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Additional Notes', Icons.note_alt),
        context.vM,
        _buildRow(
          context,
          'Notes',
          controller: _notesController,
          icon: Icons.edit_note,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          Consumer<PlannerProvider>(
            builder: (context, plannerProvider, _) {
              return plannerProvider.pendingSyncCount > 0
                  ? Column(
                    children: [
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.sync_problem, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pending Sync: ${plannerProvider.pendingSyncCount} request(s)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                    Text(
                                      'Will sync when connection is restored',
                                      style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final success = await plannerProvider.syncPendingPlans();
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sync completed successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.sync, size: 18),
                                label: Text('Sync Now'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      context.vM,
                    ],
                  )
                  : const SizedBox.shrink();
            },
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlannerInfoCard(context),
                        context.vL,
                        _buildChecklistCard(context),
                        context.vL,
                        _buildTagsCard(context),
                      ],
                    ),
                  ),
                ),
                context.hXl,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScheduleCard(context),
                        context.vL,
                        _buildAssignmentCard(context),
                        context.vL,
                        _buildNotesCard(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          context.vL,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: CommonButton(
                  text: _isSubmitting ? 'Creating...' : 'Create Planner',
                  onPressed: _isSubmitting ? null : _submitForm,
                ),
              ),
            ],
          ),
          context.vM,
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: context.paddingHorizontal,
      child: Column(
        children: [
          context.vM,
          Consumer<PlannerProvider>(
            builder: (context, plannerProvider, _) {
              return plannerProvider.pendingSyncCount > 0
                  ? Column(
                    children: [
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.sync_problem, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pending Sync: ${plannerProvider.pendingSyncCount} request(s)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                    Text(
                                      'Will sync when connection is restored',
                                      style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final success = await plannerProvider.syncPendingPlans();
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Sync completed!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.sync, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      context.vM,
                    ],
                  )
                  : const SizedBox.shrink();
            },
          ),
          _buildPlannerInfoCard(context),
          context.vL,
          _buildScheduleCard(context),
          context.vL,
          _buildAssignmentCard(context),
          context.vL,
          _buildChecklistCard(context),
          context.vL,
          _buildTagsCard(context),
          context.vL,
          _buildNotesCard(context),
          context.vL,
          CommonButton(
            text: _isSubmitting ? 'Creating...' : 'Create Planner',
            onPressed: _isSubmitting ? null : _submitForm,
          ),
          context.vL,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available, color: context.colors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'New Planner',
              style: context.topology.textTheme.titleMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: context.colors.primary),
        backgroundColor: context.colors.onPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child:
            _isSubmitting
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: context.colors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Creating plan...',
                        style: context.topology.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                )
                : (context.isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context)),
      ),
    );
  }
}
