import 'package:flutter/material.dart';
import 'package:careyou/pages/pill_box.dart';
import 'package:careyou/pages/doctor_app.dart';
import 'package:careyou/pages/doctor_app.dart';
import 'pages/app_manage.dart';
import 'pages/add_app.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AddApp(),
    );
  }
}

