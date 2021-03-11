import 'dart:collection';

import 'package:backend_api/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class OverviewPage extends StatefulWidget {
  final DefaultApi client;
  final List<Subscription> subscriptions;
  final HashMap<int, Category> categories;

  OverviewPage({this.client, this.subscriptions, this.categories});

  @override
  _OverviewPageState createState() => _OverviewPageState(
      client: this.client,
      subscriptions: this.subscriptions,
      categories: this.categories);
}

class _OverviewPageState extends State<OverviewPage> {
  final DefaultApi client;
  List<Subscription> subscriptions;
  final HashMap<int, Category> categories;
  List<CategoryMonthlyPctAccumulator> _categorySpendingThisMonth =
      <CategoryMonthlyPctAccumulator>[];
  List<MonthlySpendingAccumulator> _monthlySpending = [];
  Map<Category, List<MonthlySpendingAccumulator>> _categoryMonthlySpending =
      new HashMap<Category, List<MonthlySpendingAccumulator>>();
  final List<charts.Color> _colors = [
    charts.Color(a: 0xFF, b: 0xA6, g: 0x5D, r: 0x90),
    charts.Color(a: 0xFF, b: 0x7A, g: 0x5D, r: 0xA6),
    charts.Color(a: 0xFF, b: 0x5D, g: 0x9E, r: 0xA6),
    charts.Color(a: 0xFF, b: 0x67, g: 0xA6, r: 0x5D),
    charts.Color(a: 0xFF, b: 0xA6, g: 0x8A, r: 0x5D),
    charts.Color(a: 0xFF, b: 0xA6, g: 0x5D, r: 0x90),
  ];
  double _totalAdjustedMonthlySpending = 0;

  _OverviewPageState({this.client, this.subscriptions, this.categories}) {
    _init();
  }

  List<DateTime> _recurrencesThisMonth(Subscription sub, DateTime month) {
    if (month.isBefore(sub.startsAt)) return [];
    var monthJiffy = Jiffy(month);
    var startsAtJiffy = Jiffy(sub.startsAt);
    DateTime renewalDate;
    List<DateTime> result = [];
    if (sub.recurrence == 'monthly') {
      var monthsBetween = monthJiffy.diff(startsAtJiffy, Units.MONTH);
      renewalDate = startsAtJiffy.add(months: monthsBetween);
      result.add(renewalDate);
    } else if (sub.recurrence == 'weekly') {
      var dayOfWeek = startsAtJiffy.day;
      renewalDate = Jiffy(monthJiffy.startOf(Units.WEEK)).add(days: dayOfWeek);
      var nextMonth = monthJiffy.add(months: 1);
      for (int i = 0; i < 4; i++) {
        if (renewalDate.isAfter(nextMonth)) break;
        result.add(renewalDate);
        renewalDate = Jiffy(renewalDate).add(weeks: 1);
      }
    } else if (sub.recurrence == 'yearly') {
      var renewalMonthNumber = sub.startsAt.month;
      if (month.month == renewalMonthNumber) {
        result.add(new DateTime(month.year, month.month, sub.startsAt.day));
      }
    }
    // debugPrint("MONTH: ${month}");
    // debugPrint("${sub.id} - ${sub.title}:");
    // debugPrint(result.toString());
    return result;
  }

  _init() async {
    // An old, dilapidated sign with faded writing stands in your path:
    // ABANDON ALL HOPE
    // YE WHO ENTER HERE
    // ... eh. Must be nothing.
    HashMap<int, int> tempSpending = HashMap<int, int>();
    int totalSpending = 0;
    subscriptions = await client.subscriptionsGet();
    (await client.categoriesGet()).forEach((e) => {categories[e.id] = e});
    subscriptions.forEach((element) {
      var recurrenceCost = element.cost;
      if (element.recurrence == "weekly")
        recurrenceCost *= 4;
      else if (element.recurrence == "yearly") recurrenceCost ~/= 12;
      tempSpending[element.category] =
          (tempSpending[element.category] ?? 0) + recurrenceCost;
      totalSpending += recurrenceCost;
    });
    tempSpending.forEach((category, amount) {
      _categorySpendingThisMonth.add(CategoryMonthlyPctAccumulator(
          categoryName: categories[category].name,
          amount: amount.toDouble() / totalSpending * 100));
    });
    var now = new DateTime.now();
    HashMap<DateTime, int> spendingPerMonth = new HashMap<DateTime, int>();
    HashMap<Category, HashMap<DateTime, int>> spendingPerCategoryPerMonth =
        new HashMap<Category, HashMap<DateTime, int>>();
    var subsStartedPriorToNow =
        subscriptions.where((element) => element.startsAt.isBefore(now));
    subsStartedPriorToNow.forEach((sub) {
      for (int i = -6; i < 7; i++) {
        var startOfMonth =
            Jiffy(Jiffy(DateTime.now()).add(months: i)).startOf(Units.MONTH);
        var recurrencesThisMonth = _recurrencesThisMonth(sub, startOfMonth);
        var recurrenceCost = recurrencesThisMonth.length * sub.cost;
        spendingPerMonth[startOfMonth] ??= 0;
        spendingPerMonth[startOfMonth] += recurrenceCost;
        spendingPerCategoryPerMonth[categories[sub.category]] ??=
            new HashMap<DateTime, int>();
        spendingPerCategoryPerMonth[categories[sub.category]][startOfMonth] ??=
            0;
        spendingPerCategoryPerMonth[categories[sub.category]][startOfMonth] +=
            recurrenceCost;
      }
    });
    spendingPerMonth.forEach((month, amount) {
      _monthlySpending.add(
          MonthlySpendingAccumulator(month: month, amount: amount / 100.0));
    });
    _categoryMonthlySpending = spendingPerCategoryPerMonth.map((category, map) {
      List<MonthlySpendingAccumulator> monthlySpendingForCategory = [];
      map.forEach((month, amount) {
        monthlySpendingForCategory.add(
            MonthlySpendingAccumulator(month: month, amount: amount / 100.0));
      });
      return MapEntry(category, monthlySpendingForCategory);
    });
    _categorySpendingThisMonth.forEach((value) {
      _totalAdjustedMonthlySpending += value.amount;
    });
    setState(() {});
  }

  int _findSpendingForThisMonth() {
    int totalCost = 0;
    subscriptions.forEach((sub) {
      var recurrencesThisMonth = _recurrencesThisMonth(sub, DateTime.now());
      totalCost += recurrencesThisMonth.length * sub.cost;
    });

    return totalCost;
  }

  @override
  Widget build(BuildContext context) {
    final simpleCurrencyFormatter =
        new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            new NumberFormat.compactSimpleCurrency());
    return StaggeredGridView.count(
      crossAxisCount: 4,
      staggeredTiles: [
        const StaggeredTile.count(1, 1),
        const StaggeredTile.count(1, 1),
        const StaggeredTile.count(1, 1),
        const StaggeredTile.count(2, 1),
      ],
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Text(
                "Actual Spending for this Month",
                style: TextStyle(fontSize: 18),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.simpleCurrency()
                        .format(_findSpendingForThisMonth() / 100),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Text(
                "Adjusted Monthly Spending",
                style: TextStyle(fontSize: 18),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    NumberFormat.simpleCurrency()
                        .format(_totalAdjustedMonthlySpending),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        CategorySpendingPieChart(
            categorySpendingThisMonth: _categorySpendingThisMonth,
            colors: _colors),
        Container(
          padding: EdgeInsets.all(16),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Text(
                "Total Spending by Month",
                style: TextStyle(fontSize: 18),
              ),
              Flexible(
                child: _categoryMonthlySpending.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : charts.TimeSeriesChart(
                        <charts.Series<MonthlySpendingAccumulator, DateTime>>[
                          ..._categoryMonthlySpending
                              .map(
                                (category, monthlySpendingAcc) => MapEntry(
                                  category,
                                  charts.Series<MonthlySpendingAccumulator,
                                      DateTime>(
                                    id: category.name,
                                    data: monthlySpendingAcc,
                                    domainFn: (data, _) => data.month,
                                    measureFn: (data, _) => data.amount,
                                    colorFn: (_, i) => _colors[category.id],
                                  ),
                                ),
                              )
                              .values
                        ],
                        primaryMeasureAxis: charts.NumericAxisSpec(
                          tickFormatterSpec: simpleCurrencyFormatter,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategorySpendingPieChart extends StatefulWidget {
  final List<CategoryMonthlyPctAccumulator> categorySpendingThisMonth;
  final List<charts.Color> colors;

  CategorySpendingPieChart({
    @required this.categorySpendingThisMonth,
    @required this.colors,
  });

  @override
  _CategorySpendingPieChartState createState() =>
      _CategorySpendingPieChartState(
        categorySpendingThisMonth: this.categorySpendingThisMonth,
        colors: this.colors,
      );
}

class _CategorySpendingPieChartState extends State<CategorySpendingPieChart> {
  final List<CategoryMonthlyPctAccumulator> categorySpendingThisMonth;
  final List<charts.Color> colors;

  _CategorySpendingPieChartState({
    @required this.categorySpendingThisMonth,
    @required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Text(
            "Adjusted Monthly Spending by Category",
            style: TextStyle(fontSize: 18),
          ),
          Flexible(
            child: charts.PieChart(
              [
                charts.Series<CategoryMonthlyPctAccumulator, String>(
                  id: 'Adjusted Monthly Spending',
                  data: categorySpendingThisMonth,
                  domainFn: (data, _) => data.categoryName,
                  measureFn: (data, _) => data.amount,
                  labelAccessorFn: (data, _) =>
                      "${data.categoryName}\n${data.amount.toStringAsFixed(1)}%",
                  colorFn: (_, index) => colors[index],
                )
              ],
              defaultRenderer: new charts.ArcRendererConfig(
                arcRendererDecorators: [new charts.ArcLabelDecorator()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryMonthlyPctAccumulator {
  final String categoryName;
  final double amount;

  CategoryMonthlyPctAccumulator({this.categoryName, this.amount});
}

class MonthlySpendingAccumulator {
  final double amount;
  final DateTime month;

  MonthlySpendingAccumulator({this.month, this.amount});
}
