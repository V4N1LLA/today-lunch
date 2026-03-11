import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/features/home/presentation/home_page.dart';

void main() {
  runApp(const ProviderScope(child: TodayLunchApp()));
}

class TodayLunchApp extends StatelessWidget {
  const TodayLunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'today-lunch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
