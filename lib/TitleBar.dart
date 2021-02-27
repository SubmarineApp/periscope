import 'package:flutter/material.dart';
import 'package:submarine/CalendarPage.dart';
import 'package:submarine/OverviewPage.dart';
import 'package:submarine/SubscriptionsPage.dart';

class TitleBar extends StatefulWidget {
  @override
  _TitleBarState createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Submarine"),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Text(
                  "Overview",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Tab(
                icon: Text(
                  "Calendar",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Tab(
                icon: Text(
                  "Subscriptions",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OverviewPage(),
            SubscriptionsPage(),
            CalendarPage(),
          ],
        ),
      ),
    );
  }
}
