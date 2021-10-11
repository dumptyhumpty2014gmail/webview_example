import 'package:flutter/material.dart';
import 'package:webview_example/widgets/luchshij_obzor/luchshij_obzor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Демонстрация webview',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.indigo),
      ),
      home: const LuchshijObzorPage(),
    );
  }
}
