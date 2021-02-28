import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';
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
  List<Subscription> items = <Subscription>[];
  HashMap<int, Category> categories = HashMap<int, Category>();

  //

  _CalendarPageState({
    this.client,
    this.subscriptions,
    this.categories,
  }) {
    _init();
  }

  _init() async {
    items = await client.subscriptionsGet(); //fils in list
    (await client.categoriesGet()).forEach((e) => {categories[e.id] = e});
    setState(() {});
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
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
          agendaStyle: AgendaStyle(
            backgroundColor: Colors.grey.shade50,
            appointmentTextStyle: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.normal,
                color: Colors.grey.shade900),
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

List<Event> _getDataSource() {
  List<Event> events = <Event>[];
  items.foreach((e) {
    final DateTime today = DateTime.now();
    final DateTime startTime = e.startTime;
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    final double cost = e.cost;
    events.add(Event(
        eventName: e.title,
        from: startTime,
        to: endTime,
        background: const Color(0xFF0F8644),
        isAllDay: true,
        cost: cost));
  });
  return events;
}

//EventDataSource sets the appointment collection data source to calendar
class EventDataSource extends CalendarDataSource {
  //Create an event data source, used to set the appointment collection to the
  //calendar
  EventDataSource(List<Event> source) {
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
    return appointments[index].cost;
  }
}

//Event class containing properties to hold information about the event data
class Event {
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  double cost;

  //Create an event with required details
  Event(
      {this.eventName,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      this.cost});
}
