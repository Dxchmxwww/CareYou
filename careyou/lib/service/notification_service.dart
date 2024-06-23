// // import 'dart:async';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:timezone/data/latest.dart' as tz;
// // import 'package:timezone/timezone.dart' as tz;
// // import 'dart:convert';
// // import 'package:flutter/material.dart';

// // class NotificationService extends ChangeNotifier {
// //   final String token;
// //   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// //   Timer? timer;
// //   List<dynamic> currentReminders = [];
// //   Set<int> scheduledReminderIds = {};

// //   NotificationService({required this.token}) {
// //     initializeNotifications();
// //     fetchAndCheckReminders();
// //     timer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchAndCheckReminders());
// //   }

// //   void initializeNotifications() {
// //     tz.initializeTimeZones();

// //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// //     var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
// //     var initializationSettingsIOS = IOSInitializationSettings(
// //       requestAlertPermission: true,
// //       requestBadgePermission: true,
// //       requestSoundPermission: true,
// //     );
// //     var initializationSettings = InitializationSettings(
// //       android: initializationSettingsAndroid,
// //       iOS: initializationSettingsIOS,
// //     );

// //     flutterLocalNotificationsPlugin.initialize(initializationSettings);
// //   }

// //   Future<void> fetchAndCheckReminders() async {
// //     try {
// //       final response = await http.get(
// //         Uri.parse('http://localhost:8000/notifications/GetUpcomingPillReminders'),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //         },
// //       );
// //       print(response.body);

// //       if (response.statusCode == 200) {
// //         var jsonResponse = jsonDecode(response.body);
// //         if (jsonResponse is List) {
// //           List<dynamic> newReminders = jsonResponse;
// //           updateNotifications(newReminders);
// //         } else if (jsonResponse is Map && jsonResponse.containsKey('message')) {
// //           updateNotifications([]);
// //         } else {
// //           throw Exception('Unexpected response format');
// //         }
// //       } else {
// //         throw Exception('Failed to fetch reminders');
// //       }
// //     } catch (e) {
// //       print('Error fetching reminders: $e');
// //       // Handle error: Show a snackbar or dialog to inform the user
// //     }
// //   }

// //   void updateNotifications(List<dynamic> newReminders) {
// //     for (var reminder in currentReminders) {
// //       if (!newReminders.contains(reminder)) {
// //         cancelNotification(reminder);
// //       }
// //     }

// //     for (var reminder in newReminders) {
// //       if (!currentReminders.contains(reminder)) {
// //         scheduleNotification(reminder);
// //       }
// //     }

// //     currentReminders = newReminders;
// //   }

// //   Future<void> scheduleNotification(dynamic reminder) async {
// //     String pillName = reminder['Pill_name'];
// //     String pillType = reminder['Pill_type'];
// //     int NumberofPills = reminder['NumberofPills'];
// //     String PillTime = reminder['Pill_Time'];
// //     String reminderDate = reminder['reminderDates'];
// //     String reminderTime = reminder['reminder_times'];
// //     int timeId = reminder['time_id'];

// //     DateTime scheduledDateTime = DateTime.parse('$reminderDate $reminderTime');
// //     tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

// //     if (scheduledReminderIds.contains(timeId)) {
// //       return;
// //     }

// //     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
// //       'reminders_channel',
// //       'Reminders',
// //       'Receive reminders for medication and appointments',
// //       importance: Importance.max,
// //       priority: Priority.high,
// //     );

// //     var iOSPlatformChannelSpecifics = IOSNotificationDetails(
// //       sound: 'assets/sounds/iphone_alarm.wav',
// //       presentAlert: true,
// //       presentBadge: true,
// //       presentSound: true,
// //     );

// //     var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

// //     String notificationMessage = 'Take $NumberofPills $pillName ($pillType) now. Take it at $PillTime';

// //     if (scheduledTZDateTime.isAfter(tz.TZDateTime.now(tz.local))) {
// //       await flutterLocalNotificationsPlugin.zonedSchedule(
// //         timeId,
// //         '$reminderTime Pill Reminder',
// //         notificationMessage,
// //         scheduledTZDateTime,
// //         platformChannelSpecifics,
// //         androidAllowWhileIdle: true,
// //         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
// //         payload: 'Reminder',
// //       );

// //       scheduledReminderIds.add(timeId);
// //     }
// //   }

// //   void cancelNotification(dynamic reminder) {
// //     int timeId = reminder['time_id'];
// //     flutterLocalNotificationsPlugin.cancel(timeId);
// //     scheduledReminderIds.remove(timeId);
// //   }

// //   @override
// //   void dispose() {
// //     timer?.cancel();
// //     super.dispose();
// //   }
// // }

// import 'dart:async';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'dart:convert';
// import 'package:flutter/material.dart';

// class NotificationService extends ChangeNotifier {
//   final String token;
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   Timer? timer;
//   List<dynamic> currentReminders = [];
//   Set<int> scheduledReminderIds = {};

//   NotificationService({required this.token}) {
//     assert(token.isNotEmpty, 'Token must be provided');
//     initializeNotifications();
//     fetchAndCheckReminders();
//     timer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchAndCheckReminders());
//   }

//   void initializeNotifications() {
//     tz.initializeTimeZones();

//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//     var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettingsIOS = IOSInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> fetchAndCheckReminders() async {
//     try {
//       print('Token: $token'); // Debug print the token

//       final response = await http.get(
//         Uri.parse('http://localhost:8000/notifications/GetUpcomingPillReminders'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       print('Response: ${response.body}'); // Debug print the response body

//       if (response.statusCode == 200) {
//         var jsonResponse = jsonDecode(response.body);
//         if (jsonResponse is List) {
//           List<dynamic> newReminders = jsonResponse;
//           updateNotifications(newReminders);
//         } else if (jsonResponse is Map && jsonResponse.containsKey('message')) {
//           updateNotifications([]);
//         } else {
//           throw Exception('Unexpected response format');
//         }
//       } else {
//         throw Exception('Failed to fetch reminders');
//       }
//     } catch (e) {
//       print('Error fetching reminders: $e');
//       // Handle error: Show a snackbar or dialog to inform the user
//     }
//   }

//   void updateNotifications(List<dynamic> newReminders) {
//     for (var reminder in currentReminders) {
//       if (!newReminders.contains(reminder)) {
//         cancelNotification(reminder);
//       }
//     }

//     for (var reminder in newReminders) {
//       if (!currentReminders.contains(reminder)) {
//         scheduleNotification(reminder);
//       }
//     }

//     currentReminders = newReminders;
//   }

//   Future<void> scheduleNotification(dynamic reminder) async {
//     String pillName = reminder['Pill_name'];
//     String pillType = reminder['Pill_type'];
//     int NumberofPills = reminder['NumberofPills'];
//     String PillTime = reminder['Pill_Time'];
//     String reminderDate = reminder['reminderDates'];
//     String reminderTime = reminder['reminder_times'];
//     int timeId = reminder['time_id'];

//     DateTime scheduledDateTime = DateTime.parse('$reminderDate $reminderTime');
//     tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

//     if (scheduledReminderIds.contains(timeId)) {
//       return;
//     }

//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'reminders_channel',
//       'Reminders',
//       'Receive reminders for medication and appointments',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     var iOSPlatformChannelSpecifics = IOSNotificationDetails(
//       sound: 'assets/sounds/iphone_alarm.wav',
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

//     String notificationMessage = 'Take $NumberofPills $pillName ($pillType) now. Take it at $PillTime';

//     if (scheduledTZDateTime.isAfter(tz.TZDateTime.now(tz.local))) {
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//         timeId,
//         '$reminderTime Pill Reminder',
//         notificationMessage,
//         scheduledTZDateTime,
//         platformChannelSpecifics,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//         payload: 'Reminder',
//       );

//       scheduledReminderIds.add(timeId);
//     }
//   }

//   void cancelNotification(dynamic reminder) {
//     int timeId = reminder['time_id'];
//     flutterLocalNotificationsPlugin.cancel(timeId);
//     scheduledReminderIds.remove(timeId);
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }
// }
