import 'package:flutter/material.dart';

import 'calendar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Record',
      debugShowCheckedModeBanner: false, // 우상단 DEBUG 리본 숨김
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: const CalendarPage(),
    );
  }
}
