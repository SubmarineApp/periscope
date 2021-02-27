import 'package:flutter/material.dart';
import 'OverviewPage.dart';
import 'CalendarPage.dart';
import 'SubscriptionsPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submarine"),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return OverviewPage();
              }));
            }, // Handle your callback
            child: Ink(
              height: 100,
              width: 100,
              color: _selectedTab == 0 ? Color(0xFF21B2F3) : Colors.blue,
              child: Center(
                child: Text(
                  "Overview",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return CalendarPage();
              }));
            }, // Handle your callback
            child: Ink(
              height: 100,
              width: 100,
              color: _selectedTab == 1 ? Color(0xFF21B2F3) : Colors.blue,
              child: Center(
                child: Text(
                  "Calendar",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return SubscriptionsPage();
              }));
            }, // Handle your callback
            child: Ink(
              height: 100,
              width: 100,
              color: _selectedTab == 2 ? Color(0xFF21B2F3) : Colors.blue,
              child: Center(
                child: Text(
                  "Subscriptions",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
