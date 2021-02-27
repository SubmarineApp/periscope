import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Calendar',
        home: Scaffold(
            body: Center(
          child: Text('HELLO I AM NOT A CALENDAR'),
        )));
  }
}
