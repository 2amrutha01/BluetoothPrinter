import 'package:flutter/material.dart';
import 'package:printing/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Bluetooth Printer",
        routes: {
          '/home': (context) => home(),
        },
        initialRoute: '/',
        home: home());
  }
}
