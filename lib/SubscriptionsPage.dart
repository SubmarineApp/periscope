import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();

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
                    'Are you sure you want to Cancel ${selected.length} Subscriptions?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Yes'),
                onPressed: () {
                  selected.forEach((element) {
                    try {
                      element.endsAt = DateTime.now();
                      client.subscriptionsIdPatch(element.id, element);
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

  // TODO: Implement sorting
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
                  // TODO
                  child: Text('Modify'),
                  onPressed: () {/** */},
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    this._confirmCancelation();
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
