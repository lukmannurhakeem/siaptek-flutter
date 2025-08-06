import 'package:base_app/core/extension/date_time_extension.dart';
import 'package:base_app/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _focusedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ); // Default: July
  DateTime? _selectedDay;

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
    return Padding(
      padding: context.paddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickMonthYear,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _focusedDay.formatShortDate,
                  style: context.topology.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ),
          context.vS,
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            daysOfWeekHeight: 40.0,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            // ✅ Start week on Monday
            headerVisible: false,
            availableGestures: AvailableGestures.none,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.deepPurple, // Weekdays
                fontWeight: FontWeight.bold,
              ),
              weekendStyle: TextStyle(
                color: Colors.redAccent, // Saturday/Sunday
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300), // ✅ Border color
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text('${day.day}', style: TextStyle(color: Colors.black87)),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.primary),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    border: Border.all(color: Colors.deepPurple.shade700),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(outsideDaysVisible: false),
          ),
          context.vM,
          SfCalendar(
            view: CalendarView.day,
            headerHeight: 0,
            viewHeaderHeight: 0,
            initialDisplayDate: _selectedDay,
            cellBorderColor: context.colors.secondary,
            allowedViews: const <CalendarView>[CalendarView.day],
            // or .week, .month, .schedule
            dataSource: MeetingDataSource(_getDataSource(_selectedDay ?? _focusedDay)),
          ),
        ],
      ),
    );
  }

  List<Appointment> _getDataSource(DateTime date) {
    return <Appointment>[
      Appointment(
        startTime: DateTime(date.year, date.month, date.day, 9),
        endTime: DateTime(date.year, date.month, date.day, 10),
        subject: 'Team Meeting',
        color: Colors.red,
      ),
    ];
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
