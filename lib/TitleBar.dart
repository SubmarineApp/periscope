import 'package:backend_api/api.dart';
import 'package:flutter/material.dart';
import 'package:submarine/CalendarPage.dart';
import 'package:submarine/OverviewPage.dart';
import 'package:submarine/SubscriptionsPage.dart';

class TitleBar extends StatefulWidget {
  final DefaultApi client;

  TitleBar({this.client});

  @override
  _TitleBarState createState() => _TitleBarState(client: this.client);
}

class _TitleBarState extends State<TitleBar> {
  final DefaultApi client;

  _TitleBarState({this.client});

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
            CalendarPage(),
            SubscriptionsPage(
              client: this.client,
            ),
          ],
        ),
      ),
    );
  }
}
