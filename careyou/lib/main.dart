import 'package:careyou/pages/user_onboard_page.dart';
import 'package:careyou/pages/log_in_page.dart';
import 'package:careyou/pages/sign_up_page.dart';
import 'package:careyou/pages/elder_profile.dart';
import 'package:careyou/pages/caregiver_profile.dart';
import 'package:careyou/pages/test_home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UserBoarding',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const user_onboard_page(),
        '/login': (context) => const log_in_page(selectedRole: ''),
        '/signup': (context) => const SignUpPage(selectedRole: ''),
        '/home': (context) => const test_home(),
      },
    );
  }
}
