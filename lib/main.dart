import 'package:flutter/material.dart';
import 'package:flutter_calendar/calendar_page.dart';
import 'package:flutter_calendar/calendar_page_viewModel.dart';
import 'package:flutter_color_plugin/flutter_color_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日历',
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CalendarPage(),
      ),
      // 去掉debug logo
    );
  }
}


