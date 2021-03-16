import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum FormType { ADD, MODIFY }

class ModifySubscriptionForm extends StatefulWidget {
  final DefaultApi client;
  final GlobalKey<FormState> formKey;
  final HashMap<int, Category> categories;
  final Subscription subscription;
  final FormType formType;

  ModifySubscriptionForm({
    @required this.formKey,
    this.client,
    @required this.categories,
    this.subscription,
    @required this.formType,
  });

  @override
  _ModifySubscriptionFormState createState() => _ModifySubscriptionFormState(
        formKey: this.formKey,
        client: this.client,
        categories: this.categories,
        subscription: this.subscription,
        formType: this.formType,
      );
}

class _ModifySubscriptionFormState extends State<ModifySubscriptionForm> {
  final DefaultApi client;
  final GlobalKey<FormState> formKey;
  final HashMap<int, Category> categories;
  final _titleController = TextEditingController();
  final _regCostController = TextEditingController();
  final _trialCostController = TextEditingController();
  final FormType formType;
  Map<String, int> _categoryReverseMap;
  String _recurrence;
  String _selectedCategoryTitle;
  DateTime _startDate;
  CurrencyInputFormatter _regCostCurrencyFormatter = CurrencyInputFormatter();
  bool _isTrialSubscription = false;
  DateTime _trialEndDate;
  CurrencyInputFormatter _trialCostCurrencyFormatter = CurrencyInputFormatter();
  Subscription subscription;

  _ModifySubscriptionFormState({
    @required this.formKey,
    @required this.client,
    @required this.categories,
    this.subscription,
    @required this.formType,
  }) {
    _categoryReverseMap = categories.map<String, int>(
        (key, value) => MapEntry<String, int>(value.name, key));
    NumberFormat f =
        NumberFormat.simpleCurrency(locale: "en_US", decimalDigits: 2);
    if (subscription != null) {
      _titleController.text = subscription.title;
      _regCostController.text = f.format(subscription.cost / 100);
      _recurrence = subscription.recurrence;
      _selectedCategoryTitle = categories[subscription.category].name;
      _startDate = subscription.startsAt;
      _trialCostController.text = f.format(subscription.trialCost ?? 0 / 100);
      _trialEndDate = subscription.trialEndsAt ?? DateTime.now();
    } else {
      _titleController.text = "";
      _regCostController.text = f.format(0);
      _recurrence = 'weekly';
      _selectedCategoryTitle = categories[categories.keys.first].name;
      _startDate = DateTime.now();
      _trialCostController.text = f.format(0);
      _trialEndDate = DateTime.now();
    }
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
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Form(
            key: formKey,
            child: ListView(
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
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Text(
                    "Start Date",
                    style: TextStyle(fontSize: 27),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          "${DateFormat.yMMMMd('en_US').format(_startDate)}",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
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
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(top: 20),
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Trial Period?",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Checkbox(
                            value: _isTrialSubscription,
                            onChanged: (value) {
                              setState(() {
                                _isTrialSubscription = value;
                              });
                            },
                          ),
                        ),
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
                          style: TextStyle(fontSize: 27),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                "${DateFormat.yMMMMd('en_US').format(_trialEndDate)}",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              child: ElevatedButton(
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
                            ),
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
                        switch (formType) {
                          case FormType.ADD:
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
                            break;
                          case FormType.MODIFY:
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Modifying Subscription...')));

                            try {
                              await client.subscriptionsIdPatch(
                                  subscription.id,
                                  Subscription(
                                    title: _titleController.text,
                                    category: _categoryReverseMap[
                                        _selectedCategoryTitle],
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
                            break;
                          default:
                        }
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