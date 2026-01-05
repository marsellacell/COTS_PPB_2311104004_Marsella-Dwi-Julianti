import 'package:cots/presetation/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COTS PPB',
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
    );
  }
}
