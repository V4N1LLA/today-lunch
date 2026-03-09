import 'package:flutter/material.dart';

void main() {
  runApp(const TodayLunchApp());
}

class TodayLunchApp extends StatelessWidget {
  const TodayLunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'today-lunch',
      home: Scaffold(
        appBar: AppBar(title: const Text('today-lunch')),
        body: const Center(child: Text('MVP bootstrap')),
      ),
    );
  }
}
