import 'package:backend_api/api.dart';
import 'package:openapi_dart_common/openapi.dart';
import 'package:flutter/material.dart';
import 'TitleBar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final client = DefaultApi(ApiClient(
    basePath: "https://www.nesbitt.rocks/submarine",
  ));
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Periscope',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TitleBar(
        client: this.client,
      ),
    );
  }
}
