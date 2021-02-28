import 'dart:collection';

import 'package:backend_api/api.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OverviewPage extends StatefulWidget {
  final DefaultApi client;

  OverviewPage({this.client});

  @override
  _OverviewPageState createState() => _OverviewPageState(client: this.client);
}

class _OverviewPageState extends State<OverviewPage> {
  final DefaultApi client;
  List<Subscription> items = <Subscription>[];
  HashMap<int, Category> categories = HashMap<int, Category>();
  List<CategoryAccumulator> categorySpending = <CategoryAccumulator>[];

  _OverviewPageState({this.client}) {
    _init();
  }

  _init() async {
    HashMap<int, int> tempSpending = HashMap<int, int>();
    int totalSpending = 0;
    items = await client.subscriptionsGet();
    (await client.categoriesGet()).forEach((e) => {categories[e.id] = e});
    items.forEach((element) {
      tempSpending[element.category] =
          (tempSpending[element.category] ?? 0) + element.cost;
      totalSpending += element.cost;
    });
    tempSpending.forEach((category, amount) {
      categorySpending.add(CategoryAccumulator(
          categoryName: categories[category].name,
          amount: amount.toDouble() / totalSpending * 100));
    });
    debugPrint(categorySpending.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          child: SfCircularChart(
              title: ChartTitle(text: "Monthly Spending by Category"),
              series: <CircularSeries>[
            PieSeries<CategoryAccumulator, String>(
                dataSource: categorySpending,
                xValueMapper: (data, _) => data.categoryName,
                yValueMapper: (data, _) => data.amount,
                dataLabelMapper: (data, _) =>
                    "${data.categoryName}\n${data.amount.toStringAsFixed(2)}",
                dataLabelSettings: DataLabelSettings(isVisible: true)
                // pointColorMapper: (data, _) => Color.fromRGBO(255, 0, 0, 1))
                )
          ])),
    );
  }
}

class CategoryAccumulator {
  final String categoryName;
  final double amount;

  CategoryAccumulator({this.categoryName, this.amount}) {}
}
