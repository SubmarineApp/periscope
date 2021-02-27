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
  //       dataSource: MeetingDataSource(_getDataSource()),
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
}
