import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';
import 'package:submarine/SubscriptionsPage.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  final DefaultApi client;

  CalendarPage({this.client});

  @override
  _CalendarPageState createState() => _CalendarPageState(client: this.client);
}

class _CalendarPageState extends State<CalendarPage> {
  final DefaultApi client;
  List<Subscription> items = <Subscription>[];
  HashMap<int, Category> categories = HashMap<int, Category>();

  //

  _CalendarPageState({this.client}) {
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
      body: SfCalendar(
        view: CalendarView.month,
        todayHighlightColor: Colors.redAccent.shade100,
        showNavigationArrow: true,
        dataSource: EventDataSource(_getDataSource()),
        monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
    );
  }
}

List<Event> _getDataSource() {
  //PARAMETERS
  List<Event> events = <Event>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
      //get start date of subscription
      DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));
  events.add(
      Event('Conference', startTime, endTime, const Color(0xFF0F8644), false));
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
}

//Event class containing properties to hold information about the event data
class Event {
  //Create an event with required details
  Event(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
