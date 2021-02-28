import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
  final List<Subscription> subscriptions;
  final HashMap<int, Category> categories;
  Set<Subscription> _selected = Set<Subscription>();
  final _formKey = GlobalKey<FormState>();
  _SubscriptionDataSource _subscriptionDataSource;

  _SubscriptionsPageState({this.client, this.subscriptions, this.categories}) {
    this._subscriptionDataSource = _SubscriptionDataSource(
        categories: categories, subscriptions: subscriptions);
  }

  // Future _updateSubscriptions() async {
  //   subscriptions = await client.subscriptionsGet();
  //   _subscriptionDataSource.updateDataSource();
  //   setState(() {});
  // }

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
                Text(
                    'Are you sure you want to Cancel ${_selected.length} Subscriptions?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Yes'),
                onPressed: () {
                  _selected.forEach((element) {
                    try {
                      element.endsAt = DateTime.now();
                      client.subscriptionsIdPatch(element.id, element);
                    } catch (e) {
                      debugPrint(e);
                    }
                  });
                  Navigator.of(context).pop();
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

  // TODO: Implement sorting
  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        subscriptions.sort((a, b) => a.title.compareTo(b.title));
      } else {
        subscriptions.sort((a, b) => b.title.compareTo(a.title));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              TextButton(
                child: Text('Add'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return AddSubscriptionForm(
                          formKey: _formKey,
                          client: client,
                          categories: categories,
                        );
                      },
                    ),
                  );
                  setState(() {});
                },
              ),
              TextButton(
                child: Text('Modify'),
                onPressed: () {
                  if (_selected.first != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return ModifySubscriptionForm(
                            formKey: _formKey,
                            client: client,
                            categories: categories,
                            subscription: _selected.first,
                          );
                        },
                      ),
                    );
                    setState(() {});
                  }
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  this._confirmCancelation();
                },
              ),
            ],
          ),
          Container(
            height: constraints.maxHeight - 44,
            child: SfDataGrid(
              source: _subscriptionDataSource,
              columnWidthMode: ColumnWidthMode.fill,
              allowSorting: true,
              allowMultiColumnSorting: true,
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
                  headerText: 'Monthly Cost',
                  mappingName: 'cost',
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

class ModifySubscriptionForm extends StatefulWidget {
  final DefaultApi client;
  final GlobalKey<FormState> formKey;
  final HashMap<int, Category> categories;
  final Subscription subscription;

  ModifySubscriptionForm(
      {this.formKey, this.client, this.categories, this.subscription});

  @override
  _ModifySubscriptionFormState createState() => _ModifySubscriptionFormState(
        formKey: this.formKey,
        client: this.client,
        categories: this.categories,
        subscription: this.subscription,
      );
}

class _ModifySubscriptionFormState extends State<ModifySubscriptionForm> {
  final DefaultApi client;
  final GlobalKey<FormState> formKey;
  final HashMap<int, Category> categories;
  final _titleController = TextEditingController();
  final _regCostController = TextEditingController();
  final _trialCostController = TextEditingController();
  Map<String, int> _categoryReverseMap;
  String _recurrence;
  String _selectedCategoryTitle;
  DateTime _startDate;
  CurrencyInputFormatter _regCostCurrencyFormatter = CurrencyInputFormatter();
  bool _isTrialSubscription = false;
  DateTime _trialEndDate;
  CurrencyInputFormatter _trialCostCurrencyFormatter = CurrencyInputFormatter();
  Subscription subscription;

  _ModifySubscriptionFormState(
      {this.formKey, this.client, this.categories, this.subscription}) {
    _categoryReverseMap = categories.map<String, int>(
        (key, value) => MapEntry<String, int>(value.name, key));
    _recurrence = subscription.recurrence;
    _titleController.text = subscription.title;
    _startDate = subscription.startsAt;
    _trialEndDate = subscription.trialEndsAt;
    _selectedCategoryTitle = categories[subscription.category].name;
    NumberFormat f = NumberFormat("00", "en_US");
    _regCostController.text =
        "\$${subscription.cost / 100}.${f.format(subscription.cost % 100)}";
    _trialCostController.text =
        "\$${subscription.trialCost ?? 0 / 100}.${f.format(subscription.trialCost ?? 0 % 100)}";
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _titleController.dispose();
    _regCostController.dispose();
    _trialCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Fix formatting to look nice
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: "Title",
              ),
            ),
            TextFormField(
              controller: _regCostController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                _regCostCurrencyFormatter,
              ],
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a cost';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: "Cost",
              ),
            ),
            DropdownButton<String>(
              value: _recurrence,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.blue,
              ),
              onChanged: (String newValue) {
                setState(() {
                  _recurrence = newValue;
                });
              },
              items: <String>[
                'weekly',
                'monthly',
                'yearly',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _selectedCategoryTitle,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.blue,
              ),
              onChanged: (String newValue) {
                setState(() {
                  _selectedCategoryTitle = newValue;
                });
              },
              items: categories.values
                  .map<DropdownMenuItem<String>>(
                      (v) => DropdownMenuItem<String>(
                            value: v.name,
                            child: Text(v.name),
                          ))
                  .toList(),
            ),
            Text("Start Date"),
            Row(
              children: <Widget>[
                Text("${DateFormat.yMMMMd('en_US').format(_startDate)}"),
                ElevatedButton(
                  onPressed: () async {
                    _startDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                    );
                    setState(() {});
                  },
                  child: Icon(Icons.calendar_today),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Trial Period?"),
                Checkbox(
                  value: _isTrialSubscription,
                  onChanged: (value) {
                    setState(() {
                      _isTrialSubscription = value;
                    });
                  },
                ),
              ],
            ),
            Visibility(
              visible: _isTrialSubscription,
              child: Column(
                children: <Widget>[
                  Text("Trial End Date"),
                  Row(
                    children: <Widget>[
                      Text("${DateFormat.yMMMMd('en_US').format(_startDate)}"),
                      ElevatedButton(
                        onPressed: () async {
                          _trialEndDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2025),
                          );
                          setState(() {});
                        },
                        child: Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _trialCostController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      _trialCostCurrencyFormatter,
                    ],
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a cost';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Trial Cost",
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, otherwise false.
                if (formKey.currentState.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Creating Subscription...')));

                  try {
                    await client.subscriptionsIdPatch(
                        subscription.id,
                        Subscription(
                          title: _titleController.text,
                          category: _categoryReverseMap[_selectedCategoryTitle],
                          recurrence: _recurrence,
                          startsAt: _startDate,
                          cost: _regCostCurrencyFormatter
                              .getUnformattedInputAsInt(),
                          trialEndsAt: _trialEndDate,
                          trialCost: _trialCostCurrencyFormatter
                              .getUnformattedInputAsInt(),
                        ));
                  } catch (e) {
                    debugPrint(e);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}

class AddSubscriptionForm extends StatefulWidget {
  final DefaultApi client;
  final GlobalKey<FormState> formKey;
  final HashMap<int, Category> categories;

  AddSubscriptionForm({this.formKey, this.client, this.categories});

  @override
  _AddSubscriptionFormState createState() => _AddSubscriptionFormState(
      formKey: this.formKey, client: this.client, categories: this.categories);
}

class _AddSubscriptionFormState extends State<AddSubscriptionForm> {
  final DefaultApi client;
  final GlobalKey<FormState> formKey;
  final HashMap<int, Category> categories;
  final _titleController = TextEditingController();
  final _regCostController = TextEditingController(text: "\$0.00");
  final _trialCostController = TextEditingController(text: "\$0.00");
  Map<String, int> _categoryReverseMap;
  String _recurrence = 'weekly';
  String _selectedCategoryTitle;
  DateTime _startDate = DateTime.now();
  CurrencyInputFormatter _regCostCurrencyFormatter = CurrencyInputFormatter();
  bool _isTrialSubscription = false;
  DateTime _trialEndDate = DateTime.now();
  CurrencyInputFormatter _trialCostCurrencyFormatter = CurrencyInputFormatter();

  _AddSubscriptionFormState({this.formKey, this.client, this.categories}) {
    _categoryReverseMap = categories.map<String, int>(
        (key, value) => MapEntry<String, int>(value.name, key));
    _selectedCategoryTitle = categories[categories.keys.first].name;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _titleController.dispose();
    _regCostController.dispose();
    _trialCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Fix formatting to look nice
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: "Title",
              ),
            ),
            TextFormField(
              controller: _regCostController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                _regCostCurrencyFormatter,
              ],
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a cost';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: "Cost",
              ),
            ),
            DropdownButton<String>(
              value: _recurrence,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.blue,
              ),
              onChanged: (String newValue) {
                setState(() {
                  _recurrence = newValue;
                });
              },
              items: <String>[
                'weekly',
                'monthly',
                'yearly',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _selectedCategoryTitle,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.blue,
              ),
              onChanged: (String newValue) {
                setState(() {
                  _selectedCategoryTitle = newValue;
                });
              },
              items: categories.values
                  .map<DropdownMenuItem<String>>(
                      (v) => DropdownMenuItem<String>(
                            value: v.name,
                            child: Text(v.name),
                          ))
                  .toList(),
            ),
            Text("Start Date"),
            Row(
              children: <Widget>[
                Text("${DateFormat.yMMMMd('en_US').format(_startDate)}"),
                ElevatedButton(
                  onPressed: () async {
                    _startDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                    );
                    setState(() {});
                  },
                  child: Icon(Icons.calendar_today),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text("Trial Period?"),
                Checkbox(
                  value: _isTrialSubscription,
                  onChanged: (value) {
                    setState(() {
                      _isTrialSubscription = value;
                    });
                  },
                ),
              ],
            ),
            Visibility(
              visible: _isTrialSubscription,
              child: Column(
                children: <Widget>[
                  Text("Trial End Date"),
                  Row(
                    children: <Widget>[
                      Text("${DateFormat.yMMMMd('en_US').format(_startDate)}"),
                      ElevatedButton(
                        onPressed: () async {
                          _trialEndDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2025),
                          );
                          setState(() {});
                        },
                        child: Icon(Icons.calendar_today),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _trialCostController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      _trialCostCurrencyFormatter,
                    ],
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a cost';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Trial Cost",
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, otherwise false.
                if (formKey.currentState.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Creating Subscription...')));

                  try {
                    await client.subscriptionsPost(
                        subscription: Subscription(
                      title: _titleController.text,
                      category: _categoryReverseMap[_selectedCategoryTitle],
                      recurrence: _recurrence,
                      startsAt: _startDate,
                      cost:
                          _regCostCurrencyFormatter.getUnformattedInputAsInt(),
                      trialEndsAt: _trialEndDate,
                      trialCost: _trialCostCurrencyFormatter
                          .getUnformattedInputAsInt(),
                    ));
                  } catch (e) {
                    debugPrint(e);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  double _value = 0.0;
  int getUnformattedInputAsInt() {
    return _value.round();
  }

  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      print(true);
      return newValue;
    }

    _value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: "en_US");

    String newText = formatter.format(_value / 100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
