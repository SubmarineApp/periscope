import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SfCalendar(
  //       view: CalendarView.month,
  //       dataSource: EventDataSource(_getDataSource()),
  //       monthViewSettings: MonthViewSettings(
  //           appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCalendar(
      view: CalendarView.month,
    ));
  }

//   List<Event> _getDataSource() {
//     events = <Event>[];
//     final DateTime today = DateTime.now();
//     final DateTime StartTime =
//         DateTime(today.year, today.month, today.day, 9, 0, 0);
//     final DateTime endTime = StartTime.add(const Duration(hours: 2));
//     events.add(
//         Event('Event', startTime, endTime, const Color(0xFF0F8644), false));
//     return events;
//   }
// }

// class EventDataSource {
// }
}
