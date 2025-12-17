import 'package:INSPECT/core/extension/theme_extension.dart';
import 'package:INSPECT/model/inspection_plan_model.dart';
import 'package:INSPECT/providers/planner_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Initialize with current local date
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlannerProvider>().fetchInspectionPlans();
    });
  }

  void _pickMonthYear() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _focusedDay = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: context.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            context.vS,
            _buildCalendar(context),
            context.vM,
            Expanded(child: _buildPlansList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _pickMonthYear,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 16, color: context.colors.primary),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Consumer<PlannerProvider>(
          builder: (context, provider, _) {
            return Row(
              children: [
                if (provider.pendingSyncCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sync_problem, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.pendingSyncCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  icon:
                      provider.isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colors.primary,
                            ),
                          )
                          : Icon(Icons.refresh, color: context.colors.primary),
                  onPressed: provider.isLoading ? null : () => provider.fetchInspectionPlans(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              daysOfWeekHeight: 40.0,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerVisible: false,
              availableGestures: AvailableGestures.horizontalSwipe,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                weekendStyle: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final hasPlans = _hasPlansOnDay(day, provider.plans);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: hasPlans ? context.colors.primary.withOpacity(0.05) : null,
                      border: Border.all(
                        color:
                            hasPlans
                                ? context.colors.primary.withOpacity(0.3)
                                : Colors.grey.shade200,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: hasPlans ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (hasPlans)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final hasPlans = _hasPlansOnDay(day, provider.plans);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      border: Border.all(color: context.colors.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.colors.primary,
                          ),
                        ),
                        if (hasPlans)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final hasPlans = _hasPlansOnDay(day, provider.plans);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (hasPlans)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                cellMargin: EdgeInsets.all(2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlansList(BuildContext context) {
    return Consumer<PlannerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: context.colors.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading plans...',
                  style: context.topology.textTheme.bodyMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage ?? 'An error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchInspectionPlans(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        final plansForDay = _getPlansForDay(_selectedDay ?? _focusedDay, provider.plans);

        if (plansForDay.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No plans for ${DateFormat('MMM dd, yyyy').format(_selectedDay ?? _focusedDay)}',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.event_note, size: 20, color: context.colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Plans for ${DateFormat('MMM dd, yyyy').format(_selectedDay ?? _focusedDay)}',
                    style: context.topology.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${plansForDay.length}',
                      style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: plansForDay.length,
                padding: const EdgeInsets.only(bottom: 16),
                itemBuilder: (context, index) {
                  final plan = plansForDay[index];
                  return _buildPlanCard(context, plan);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, InspectionPlanModel plan) {
    // Convert to local time for display
    final startTime =
        plan.plannedStartDate != null
            ? DateFormat('HH:mm').format(plan.plannedStartDate!.toLocal())
            : '--:--';
    final endTime =
        plan.plannedEndDate != null
            ? DateFormat('HH:mm').format(plan.plannedEndDate!.toLocal())
            : '--:--';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPlanDetails(context, plan),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: _getColorByStatus(plan.status), width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.planTitle,
                        style: context.topology.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    _buildStatusChip(plan.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '$startTime - $endTime',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${plan.estimatedDuration ?? 0} min',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                if (plan.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    plan.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.flag_outlined,
                      plan.priority,
                      _getColorByPriority(plan.priority),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.category_outlined, plan.eventType, context.colors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getColorByStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  bool _hasPlansOnDay(DateTime day, List<InspectionPlanModel> plans) {
    return plans.any((plan) {
      if (plan.plannedStartDate == null) return false;

      // Convert UTC to local timezone for comparison
      final startDate = DateTime(
        plan.plannedStartDate!.toLocal().year,
        plan.plannedStartDate!.toLocal().month,
        plan.plannedStartDate!.toLocal().day,
      );
      final checkDay = DateTime(day.year, day.month, day.day);
      return isSameDay(startDate, checkDay);
    });
  }

  List<InspectionPlanModel> _getPlansForDay(DateTime date, List<InspectionPlanModel> plans) {
    return plans.where((plan) {
        if (plan.plannedStartDate == null) return false;

        // Convert UTC to local timezone for comparison
        final startDate = DateTime(
          plan.plannedStartDate!.toLocal().year,
          plan.plannedStartDate!.toLocal().month,
          plan.plannedStartDate!.toLocal().day,
        );
        final checkDate = DateTime(date.year, date.month, date.day);
        return isSameDay(startDate, checkDate);
      }).toList()
      ..sort((a, b) {
        if (a.plannedStartDate == null || b.plannedStartDate == null) return 0;
        return a.plannedStartDate!.compareTo(b.plannedStartDate!);
      });
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getColorByPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showPlanDetails(BuildContext context, InspectionPlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      plan.planTitle,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _buildStatusChip(plan.status),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildDetailSection('Schedule', Icons.schedule, [
                                if (plan.plannedStartDate != null)
                                  _buildDetailRow(
                                    Icons.event_available,
                                    'Start Date',
                                    DateFormat(
                                      'MMM dd, yyyy HH:mm',
                                    ).format(plan.plannedStartDate!.toLocal()),
                                  ),
                                if (plan.plannedEndDate != null)
                                  _buildDetailRow(
                                    Icons.event_busy,
                                    'End Date',
                                    DateFormat(
                                      'MMM dd, yyyy HH:mm',
                                    ).format(plan.plannedEndDate!.toLocal()),
                                  ),
                                _buildDetailRow(
                                  Icons.timer,
                                  'Estimated Duration',
                                  '${plan.estimatedDuration ?? 0} minutes',
                                ),
                              ]),
                              const SizedBox(height: 20),
                              _buildDetailSection('Details', Icons.info_outline, [
                                _buildDetailRow(Icons.category, 'Event Type', plan.eventType),
                                _buildDetailRow(Icons.flag, 'Priority', plan.priority),
                                if (plan.description.isNotEmpty)
                                  _buildDetailRow(
                                    Icons.description,
                                    'Description',
                                    plan.description,
                                  ),
                              ]),
                              if (plan.checklistItems != null &&
                                  plan.checklistItems!.tasks.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                _buildChecklistSection(plan.checklistItems!.tasks),
                              ],
                              if (plan.notes != null &&
                                  plan.notes!.isNotEmpty &&
                                  plan.notes != '-') ...[
                                const SizedBox(height: 20),
                                _buildDetailSection('Notes', Icons.note_alt, [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      plan.notes!,
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                    ),
                                  ),
                                ]),
                              ],
                              const SizedBox(height: 20),
                              _buildDetailSection('Metadata', Icons.admin_panel_settings_outlined, [
                                if (plan.createdBy != null)
                                  _buildDetailRow(
                                    Icons.person_outline,
                                    'Created By',
                                    plan.createdBy!,
                                  ),
                                if (plan.createdAt != null)
                                  _buildDetailRow(
                                    Icons.access_time,
                                    'Created At',
                                    DateFormat(
                                      'MMM dd, yyyy HH:mm',
                                    ).format(plan.createdAt!.toLocal()),
                                  ),
                                if (plan.completedBy != null)
                                  _buildDetailRow(
                                    Icons.check_circle_outline,
                                    'Completed By',
                                    plan.completedBy!,
                                  ),
                                if (plan.completedAt != null)
                                  _buildDetailRow(
                                    Icons.done_all,
                                    'Completed At',
                                    DateFormat(
                                      'MMM dd, yyyy HH:mm',
                                    ).format(plan.completedAt!.toLocal()),
                                  ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: context.colors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.primary.withOpacity(0.1)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _buildChecklistSection(List<String> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.checklist, size: 20, color: context.colors.primary),
            const SizedBox(width: 8),
            Text(
              'Checklist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.primary.withOpacity(0.1)),
          ),
          child: Column(
            children:
                tasks.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 20, color: context.colors.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
