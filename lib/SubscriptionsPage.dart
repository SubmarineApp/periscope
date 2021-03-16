import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'SubscriptionForm.dart';

class SubscriptionsPage extends StatefulWidget {
  final DefaultApi client;
  final List<Subscription> subscriptions;
  final HashMap<int, Category> categories;

  SubscriptionsPage({this.client, this.subscriptions, this.categories});

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState(
      client: this.client,
      subscriptions: this.subscriptions,
      categories: this.categories);
}

class _SubscriptionDataSource extends DataGridSource<Subscription> {
  final List<Subscription> subscriptions;
  final HashMap<int, Category> categories;

  @override
  List<Subscription> get dataSource => subscriptions;

  _SubscriptionDataSource({this.subscriptions, this.categories});

  @override
  getValue(Subscription subscription, String columnName) {
    switch (columnName) {
      case 'id':
        return subscription.id;
      case 'title':
        return subscription.title;
      case 'category':
        return categories[subscription.category].name;
      case 'monthly_cost':
        switch (subscription.recurrence) {
          case 'monthly':
            return subscription.cost / 100.0;
          case 'weekly':
            return (subscription.cost / 100.0) * 4.0;
          case 'yearly':
            return (subscription.cost / 100.0) / 12.0;
        }
        return ' ';
      case 'cost':
        return subscription.cost / 100.0;
      case 'starts_at':
        return subscription.startsAt;
      case 'recurrence':
        return subscription.recurrence;
      default:
        return ' ';
    }
  }

  void updateDataSource() {
    notifyListeners();
  }
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final DefaultApi client;
  List<Subscription> subscriptions;
  final HashMap<int, Category> categories;
  final _formKey = GlobalKey<FormState>();
  _SubscriptionDataSource _subscriptionDataSource;
  final DataGridController _dataGridController = DataGridController();

  _SubscriptionsPageState({this.client, this.subscriptions, this.categories}) {
    this._subscriptionDataSource = _SubscriptionDataSource(
        categories: categories, subscriptions: subscriptions);
  }

  Future<void> _confirmCancelation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to Cancel this Subscription?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Subscription sub = this._dataGridController.selectedRow;
                  try {
                    sub.endsAt = DateTime.now();
                    client.subscriptionsIdPatch(sub.id, sub);
                  } catch (e) {
                    debugPrint(e);
                  }
                  Navigator.of(context).pop();
                  // TODO: Update parent's list of subscriptions
                  // _updateSubscriptions();
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                child: Text('Add'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return ModifySubscriptionForm(
                          formKey: _formKey,
                          client: client,
                          categories: categories,
                          formType: FormType.ADD,
                        );
                      },
                    ),
                  );
                  setState(() {});
                },
              ),
              ElevatedButton(
                child: Text('Modify'),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.amber)),
                onPressed: () {
                  Subscription sub = this._dataGridController.selectedRow;
                  if (sub != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return ModifySubscriptionForm(
                            formKey: _formKey,
                            client: client,
                            categories: categories,
                            subscription: sub,
                            formType: FormType.MODIFY,
                          );
                        },
                      ),
                    );
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('A row must be selected first.')));
                  }
                },
              ),
              ElevatedButton(
                child: Text('Cancel'),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red)),
                onPressed: () {
                  if (this._dataGridController.selectedRow != null) {
                    this._confirmCancelation();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('A row must be selected first.')));
                  }
                },
              ),
            ],
          ),
          Expanded(
            child: SfDataGrid(
              source: _subscriptionDataSource,
              controller: this._dataGridController,
              columnWidthMode: ColumnWidthMode.fill,
              allowSorting: true,
              allowMultiColumnSorting: true,
              selectionMode: SelectionMode.single,
              columns: <GridColumn>[
                GridTextColumn(
                  headerText: 'Title',
                  mappingName: 'title',
                  allowSorting: true,
                ),
                GridTextColumn(
                  headerText: 'Category',
                  mappingName: 'category',
                  allowSorting: true,
                ),
                GridNumericColumn(
                  headerText: 'Cost',
                  mappingName: 'cost',
                  numberFormat: NumberFormat.simpleCurrency(),
                  allowSorting: true,
                ),
                GridNumericColumn(
                  headerText: 'Monthly Cost',
                  mappingName: 'monthly_cost',
                  numberFormat: NumberFormat.simpleCurrency(),
                  allowSorting: true,
                ),
                GridTextColumn(
                  headerText: 'Recurrence',
                  mappingName: 'recurrence',
                  allowSorting: true,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}


