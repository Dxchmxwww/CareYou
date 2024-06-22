import 'package:careyou/service/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:careyou/pages/notification.dart';
import 'package:careyou/pages/user_onboard_page.dart';
import 'package:careyou/pages/log_in_page.dart';
import 'package:careyou/pages/sign_up_page.dart';
import 'package:careyou/pages/elder_profile.dart';
import 'package:careyou/pages/caregiver_profile.dart';
import 'package:careyou/pages/test_home.dart';
import 'package:careyou/pages/homePageElder.dart';
import 'package:careyou/pages/homePageCareGiver.dart';
import 'package:careyou/service/notification_service.dart';
import 'package:careyou/service/reminder_service.dart';
void main() {
  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => NotificationService(token: '')), // Replace with actual token
//       ],
//       child: MaterialApp(
//         title: 'CareYou',
//         theme: ThemeData(
//           primarySwatch: Colors.green,
//         ),
//         initialRoute: '/',
//         routes: {
//         '/': (context) => const user_onboard_page(),
//         '/login': (context) => const log_in_page(selectedRole: ''),
//         '/signup': (context) => const SignUpPage(selectedRole: ''),
//         '/home': (context) => const test_home(token: ''),
//         '/profileElderly': (context) => const HomePageElder(token: ''),
//         '/profileCaregiver': (context) => const HomePageCareGiver(token: ''),
//         '/notifications': (context) => RemindersScreen(token: ''),
//         },
//         builder: (context, child) {
//           return Stack(
//             children: [
//               child!,
//               ReminderMonitor(), // Ensures ReminderMonitor is always present
//             ],
//           );
//         },
//       ),
//     );
//   }
// }


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Careyou',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const user_onboard_page(),
        '/login': (context) => const log_in_page(selectedRole: ''),
        '/signup': (context) => const SignUpPage(selectedRole: ''),
        '/home': (context) => const test_home(token: ''),
        '/profileElderly': (context) => const HomePageElder(token: ''),
        '/profileCaregiver': (context) => const HomePageCareGiver(token: ''),
        // '/notifications': (context) => RemindersScreen(token: ''),
      },
    );
  }
}