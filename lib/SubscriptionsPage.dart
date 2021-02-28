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
          Container(
            height: constraints.maxHeight - 44,
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
        "\$${subscription.cost ~/ 100}.${f.format(subscription.cost % 100)}";
    _trialCostController.text =
        "\$${subscription.trialCost ?? 0 ~/ 100}.${f.format(subscription.trialCost ?? 0 % 100)}";
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 24),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: _regCostController,
                    style: TextStyle(fontSize: 24),
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
                      labelStyle: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: DropdownButton<String>(
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
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: DropdownButton<String>(
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
                                  child: Text(
                                    v.name,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ))
                        .toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Text(
                    "Start Date",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        "${DateFormat.yMMMMd('en_US').format(_startDate)}",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
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
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Trial Period?",
                        style: TextStyle(fontSize: 20),
                      ),
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
                ),
                Visibility(
                  visible: _isTrialSubscription,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Text(
                          "Trial End Date",
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              "${DateFormat.yMMMMd('en_US').format(_startDate)}",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
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
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _trialCostController,
                          style: TextStyle(fontSize: 24),
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
                            labelStyle: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(fontSize: 26)),
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(130, 80))),
                    onPressed: () async {
                      // Validate returns true if the form is valid, otherwise false.
                      if (formKey.currentState.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Modifying Subscription...')));

                        try {
                          await client.subscriptionsIdPatch(
                              subscription.id,
                              Subscription(
                                title: _titleController.text,
                                category:
                                    _categoryReverseMap[_selectedCategoryTitle],
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
                  ),
                ),
              ],
            ),
          );
        },
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 24),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: _regCostController,
                    style: TextStyle(fontSize: 24),
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
                      labelStyle: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: DropdownButton<String>(
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
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: DropdownButton<String>(
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
                                  child: Text(
                                    v.name,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ))
                        .toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Text(
                    "Start Date",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "${DateFormat.yMMMMd('en_US').format(_startDate)}",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: ElevatedButton(
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
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Trial Period?",
                        style: TextStyle(fontSize: 20),
                      ),
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
                ),
                Visibility(
                  visible: _isTrialSubscription,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Text(
                          "Trial End Date",
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text(
                              "${DateFormat.yMMMMd('en_US').format(_startDate)}",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
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
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _trialCostController,
                          style: TextStyle(fontSize: 24),
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
                            labelStyle: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(fontSize: 26)),
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(130, 80))),
                    onPressed: () async {
                      // Validate returns true if the form is valid, otherwise false.
                      if (formKey.currentState.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Creating Subscription...')));

                        try {
                          await client.subscriptionsPost(
                              subscription: Subscription(
                            title: _titleController.text,
                            category:
                                _categoryReverseMap[_selectedCategoryTitle],
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
                  ),
                ),
              ],
            ),
          );
        },
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
