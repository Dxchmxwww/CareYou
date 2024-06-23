import 'package:careyou/pages/pillBox.dart';
import 'package:careyou/pages/user_onboard_page.dart';
import 'package:careyou/pages/elder_profile.dart';
import 'package:flutter/material.dart';
import 'package:careyou/pages/homePageElder.dart';
import 'package:careyou/pages/elder_appointment.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String token = ''; // Initialize your token here
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Careyou',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/user_onboard', // Set initial route
      routes: {
        '/user_onboard': (context) =>
            user_onboard_page(), // Display user_onboard_page
        '/home': (context) => HomePageElder(token: token, selectedRole: ''),
        '/pill': (context) => PillBox(token: token, selectedRole: ''),
        'appointment': (context) => AppointmentForElder(token: token),
        '/profile': (context) =>
            elder_profile_page(token: token, selectedRole: ''),

        // Add more routes as necessary
      },
      onGenerateRoute: (settings) {
        // Handle unknown routes here if needed
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(
              child: Text('Error: Unknown Route'),
            ),
          ),
        );
      },
    );
  }
}
