import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  final DefaultApi client;
  final List<Subscription> subscriptions;
  final HashMap<int, Category> categories;

  CalendarPage({
    this.client,
    this.subscriptions,
    this.categories,
  });

  @override
  _CalendarPageState createState() => _CalendarPageState(
        client: this.client,
        subscriptions: this.subscriptions,
        categories: this.categories,
      );
}

class _CalendarPageState extends State<CalendarPage> {
  final DefaultApi client;
  List<Subscription> subscriptions = <Subscription>[];
  HashMap<int, Category> categories = HashMap<int, Category>();
  Map<int, Color> _colors = {
    0: Colors.black,
    1: Colors.amber,
    2: Colors.green,
    3: Colors.orange,
    4: Colors.purple,
  };

  _CalendarPageState({
    this.client,
    this.subscriptions,
    this.categories,
  }) {
    _init();
  }

  _init() async {
    subscriptions = await client.subscriptionsGet(); //fils in list
    (await client.categoriesGet()).forEach((e) => {categories[e.id] = e});
    setState(() {});
  }

  List<Appointment> _getDataSource() {
    List<Appointment> events = <Appointment>[];
    subscriptions.forEach((e) {
      final DateTime startTime = e.startsAt;
      final DateTime endTime = startTime.add(const Duration(hours: 2));
      RecurrenceProperties rprop = RecurrenceProperties();
      switch (e.recurrence) {
        case 'weekly':
          rprop.recurrenceType = RecurrenceType.weekly;
          rprop.dayOfWeek = e.startsAt.weekday;
          break;
        case 'monthly':
          rprop.recurrenceType = RecurrenceType.monthly;
          rprop.dayOfMonth = e.startsAt.day;
          break;
        case 'yearly':
          rprop.recurrenceType = RecurrenceType.yearly;
          rprop.month = e.startsAt.month;
          rprop.dayOfMonth = e.startsAt.day;
          break;
      }
      events.add(Appointment(
        subject: e.title,
        startTime: startTime,
        endTime: endTime,
        color: _colors[e.category % _colors.length],
        isAllDay: true,
        notes: NumberFormat.simpleCurrency().format(e.cost / 100.0),
        recurrenceRule: SfCalendar.generateRRule(rprop, startTime, endTime),
      ));
    });
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: SfCalendar(
      view: CalendarView.month,
      todayHighlightColor: Colors.redAccent.shade100,
      showNavigationArrow: true,
      monthViewSettings: MonthViewSettings(
          monthCellStyle: MonthCellStyle(
            leadingDatesTextStyle: TextStyle(color: Colors.grey[400]),
            trailingDatesTextStyle: TextStyle(color: Colors.grey[400]),
          ),
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
          agendaStyle: AgendaStyle(
            backgroundColor: Colors.grey.shade50,
            appointmentTextStyle: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.normal,
                color: Colors.grey.shade200),
            dateTextStyle: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade900),
            dayTextStyle: TextStyle(
                fontStyle: FontStyle.normal,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900),
          )),
      dataSource: EventDataSource(_getDataSource()),
    )));
  }
}

//EventDataSource sets the appointment collection data source to calendar
class EventDataSource extends CalendarDataSource {
  //Create an event data source, used to set the appointment collection to the
  //calendar
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }

  @override
  String getNotes(int index) {
    return appointments[index].notes;
  }

  @override
  String getRecurrenceRule(int index) {
    return appointments[index].recurrenceRule;
  }
}
