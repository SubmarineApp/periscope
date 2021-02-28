import 'dart:collection';

import 'package:backend_api/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:jiffy/jiffy.dart';

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
  List<CategoryMonthlyPctAccumulator> categorySpendingThisMonth =
      <CategoryMonthlyPctAccumulator>[];
  List<MonthlySpendingAccumulator> monthlySpending = [];
  HashMap<Category, List<MonthlySpendingAccumulator>> categoryMonthlySpending =
      new HashMap<Category, List<MonthlySpendingAccumulator>>();

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
      categorySpendingThisMonth.add(CategoryMonthlyPctAccumulator(
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
      monthlySpending.add(
          MonthlySpendingAccumulator(month: month, amount: amount / 100.0));
    });
    categoryMonthlySpending = spendingPerCategoryPerMonth.map((category, map) {
      List<MonthlySpendingAccumulator> monthlySpendingForCategory = [];
      map.forEach((month, amount) {
        monthlySpendingForCategory.add(
            MonthlySpendingAccumulator(month: month, amount: amount / 100.0));
      });
      return MapEntry(category, monthlySpendingForCategory);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            child: GridView.count(
      crossAxisCount: 2,
      children: [
        SfCircularChart(
            title: ChartTitle(text: "Monthly Spending by Category"),
            series: <CircularSeries>[
              PieSeries<CategoryMonthlyPctAccumulator, String>(
                  dataSource: categorySpendingThisMonth,
                  xValueMapper: (data, _) => data.categoryName,
                  yValueMapper: (data, _) => data.amount,
                  dataLabelMapper: (data, _) =>
                      "${data.categoryName}\n${data.amount.toStringAsFixed(1)}%",
                  dataLabelSettings: DataLabelSettings(isVisible: true)
                  // pointColorMapper: (data, _) => Color.fromRGBO(255, 0, 0, 1))
                  )
            ]),
        SfCartesianChart(
          primaryXAxis: DateTimeAxis(),
          primaryYAxis:
              NumericAxis(numberFormat: NumberFormat.simpleCurrency()),
          title: ChartTitle(text: "Total Spending by Month"),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <ChartSeries>[
            LineSeries<MonthlySpendingAccumulator, DateTime>(
                name: 'Total Spending',
                dataSource: monthlySpending,
                xValueMapper: (data, _) => data.month,
                yValueMapper: (data, _) => data.amount),
            ...categoryMonthlySpending
                .map((category, monthlySpendingAcc) => MapEntry(
                    category,
                    LineSeries<MonthlySpendingAccumulator, DateTime>(
                        name: category.name,
                        dataSource: monthlySpendingAcc,
                        xValueMapper: (data, _) => data.month,
                        yValueMapper: (data, _) => data.amount)))
                .values
          ],
        )
      ],
    )));
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
