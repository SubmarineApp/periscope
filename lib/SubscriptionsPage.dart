import 'package:flutter/material.dart';
import 'package:backend_api/api.dart';

class SubscriptionsPage extends StatefulWidget {
  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  static const int numItems = 10;
  List<Subscription> items;
  List<bool> selected = List<bool>.generate(numItems, (index) => false);
  bool sort = false;

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
    return Column(
      children: <Widget>[
        ButtonBar(
          alignment: MainAxisAlignment.start,
          children: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () {/** */},
            ),
            TextButton(
              child: Text('Modify'),
              onPressed: () {/** */},
            ),
            TextButton(
              child: Text('Remove'),
              onPressed: () {/** */},
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: DataTable(
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
            rows: items.map(
                (item) => DataRow(selected: selected.contains(item), cells: [
                      DataCell(Text(item.title)),
                      DataCell(Text("item.category")),
                      DataCell(Text("item.cost")),
                      DataCell(Text(item.recurrence))
                    ])),
          ),
        ),
      ],
    );
  }
}
