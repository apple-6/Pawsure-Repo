import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CupertinoSlidingSegmentedControl<int>(
            children: const {0: Text('Month'), 1: Text('Week')},
            groupValue: 0, // always Month for placeholder
            onValueChanged: (_) {},
          ),
          const SizedBox(height: 24),
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2032, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            headerVisible: true,
            onDaySelected: (_, __) {},
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No events scheduled for this day',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22c55e),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
