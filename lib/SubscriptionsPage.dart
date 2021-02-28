import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';
import 'package:intl/intl.dart';

class SubscriptionsPage extends StatefulWidget {
  final DefaultApi client;

  SubscriptionsPage({this.client});

  @override
  _SubscriptionsPageState createState() =>
      _SubscriptionsPageState(client: this.client);
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final DefaultApi client;
  List<Subscription> items = <Subscription>[];
  HashMap<int, Category> categories = HashMap<int, Category>();
  Set<Subscription> selected = Set<Subscription>();
  bool sort = false;
  final formatCurrency = new NumberFormat.simpleCurrency();

  _SubscriptionsPageState({this.client}) {
    _init();
  }

  _init() async {
    items = await client.subscriptionsGet();
    (await client.categoriesGet()).forEach((e) => {categories[e.id] = e});
    setState(() {});
  }

  _updateSubscriptions() async {
    items = await client.subscriptionsGet();
    setState(() {});
  }

  Future<void> _confirmRemoval() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to remove ${selected.length} Subscriptions?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Yes'),
                onPressed: () {
                  selected.forEach((element) {
                    try {
                      client.subscriptionsIdDelete(element.id);
                    } catch (e) {
                      debugPrint(e);
                    }
                  });
                  Navigator.of(context).pop();
                  _updateSubscriptions();
                }),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        items.sort((a, b) => a.title.compareTo(b.title));
      } else {
        items.sort((a, b) => b.title.compareTo(a.title));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: <Widget>[
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: <Widget>[
                // TODO: Create form for adding a new subscription
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    try {
                      client.subscriptionsPost(
                          subscription: Subscription(
                        title: "Test",
                        category: 2,
                        recurrence: "weekly",
                        startsAt: DateTime(2020, 1, 1),
                        cost: 1000,
                      ));
                    } catch (e) {
                      debugPrint(e);
                    }
                  },
                ),
                TextButton(
                  child: Text('Modify'),
                  onPressed: () {/** */},
                ),
                TextButton(
                  child: Text('Remove'),
                  onPressed: () {
                    this._confirmRemoval();
                  },
                ),
              ],
            ),
            DataTable(
              columns: <DataColumn>[
                DataColumn(
                    label: Text('Title'),
                    numeric: false,
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        sort = !sort;
                      });
                      onSortColum(columnIndex, ascending);
                    }),
                DataColumn(
                  label: Text('Description'),
                  numeric: false,
                ),
                DataColumn(
                  label: Text('Cost'),
                  numeric: true,
                ),
                DataColumn(
                  label: Text('Recurrence'),
                  numeric: false,
                ),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                        selected: selected.contains(item),
                        cells: [
                          DataCell(Text(item.title)),
                          DataCell(Text(categories[item.category].name)),
                          DataCell(
                              Text(formatCurrency.format(item.cost / 100.0))),
                          DataCell(Text(item.recurrence))
                        ],
                        onSelectChanged: (bool value) {
                          setState(() {
                            if (value) {
                              selected.add(item);
                            } else {
                              selected.remove(item);
                            }
                          });
                        }),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
