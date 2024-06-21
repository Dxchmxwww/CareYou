import 'dart:async';
import 'package:careyou/pages/elder_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/cupertino.dart';

class RemindersScreen extends StatefulWidget {
  final String token;

  RemindersScreen({required this.token});

  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer? timer;
  List<dynamic> currentReminders = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();

    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification, // Callback for when a notification is received
    );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: onSelectNotification,
      );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
   

    // Fetch and check reminders initially
    fetchAndCheckReminders();

    // Set up periodic timer to fetch and check reminders every minute
    timer = Timer.periodic(Duration(days: 1), (Timer t) => fetchAndCheckReminders());
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle notification tap
    print('Notification tapped');
  }

  Future<void> fetchAndCheckReminders() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/notifications/GetUpcomingPillReminders'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          List<dynamic> newReminders = jsonResponse;
          updateNotifications(newReminders);
        } else if (jsonResponse is Map && jsonResponse.containsKey('message')) {
          print(jsonResponse['message']);
          // Handle case when there are no reminders
          updateNotifications([]);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch reminders');
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      // Handle error: Show a snackbar or dialog to inform the user
    }
  }

  void updateNotifications(List<dynamic> newReminders) {
    // Cancel notifications that are no longer needed
    for (var reminder in currentReminders) {
      if (!newReminders.contains(reminder)) {
        cancelNotification(reminder);
      }
    }

    // Schedule new notifications
    for (var reminder in newReminders) {
      if (!currentReminders.contains(reminder)) {
        scheduleNotification(reminder);
      }
    }

    // Update currentReminders with the latest data
    currentReminders = newReminders;
  }

  Future<void> scheduleNotification(dynamic reminder) async {
    String pillName = reminder['Pill_name'];
    String pillType = reminder['Pill_type'];
    int NumberofPills = reminder['NumberofPills'];
    String PillTime = reminder['Pill_Time'];
    String reminderDate = reminder['reminderDates'];
    String reminderTime = reminder['reminder_times'];

    // Combine reminderDate and reminderTime and parse them to create a DateTime object
    DateTime scheduledDateTime = DateTime.parse('$reminderDate $reminderTime');

    // Convert DateTime to TZDateTime using the local time zone
    tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'reminders_channel', // channel_id
      'Reminders', // channel_name
      'Receive reminders for medication and appointments', // channel_description
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: 'assets/sounds/iphone_alarm.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  // String formattedReminderTime = DateFormat.Hm().format(DateTime.parse(reminderTime));

    String notificationMessage = 'Take {$NumberofPills} {$pillName} ({$pillType}) now.'
    'Take it {$PillTime}';
    // Schedule the notification if it's in the future
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '{$reminderTime} Pill Reminder',
      notificationMessage,
      scheduledTZDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'Reminder',
    );
  }

  void cancelNotification(dynamic reminder) {
    // Implement cancellation logic if needed
    // This can involve cancelling notifications based on some identifier or criteria
  }

  Future<void> onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    // Display a dialog with the notification details, tap Ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title ?? ''),
        content: Text(body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              // Navigate to another screen when tapping Ok
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => elder_profile_page(token: toString(),), // Replace with your second screen
                ),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}







// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class RemindersScreen extends StatefulWidget {
//   final String token;

//   RemindersScreen({required this.token});

//   @override
//   _RemindersScreenState createState() => _RemindersScreenState();
// }

// class _RemindersScreenState extends State<RemindersScreen> {
//   // final String token;
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   Timer? timer;


//   @override
//   void initState() {
//     super.initState();
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     initializeNotifications();

//     // Fetch and check reminders initially
//     fetchAndCheckReminders();

//     // Set up periodic timer to fetch and check reminders every minute
//     timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
//       fetchAndCheckReminders();
//     });
//   }

//   @override
//   void dispose() {
//     timer?.cancel(); // Cancel the timer when the widget is disposed
//     super.dispose();
//   }

//   Future<void> initializeNotifications() async {
//     tz.initializeTimeZones();

//     var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettingsIOS = IOSInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       onDidReceiveLocalNotification: onDidReceiveLocalNotification,
//     );
//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: onSelectNotification,
//     );
//   }

//   Future<void> fetchAndCheckReminders() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:8000/notifications/GetUpcomingPillReminders'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       if (response.statusCode == 200) {
//         var jsonResponse = jsonDecode(response.body);
//         if (jsonResponse is List) {
//           List<dynamic> newReminders = jsonResponse;
//           updateNotifications(newReminders);
//         } else if (jsonResponse is Map && jsonResponse.containsKey('message')) {
//           // Handle case when there are no reminders
//           updateNotifications([]);
//         } else {
//           throw Exception('Unexpected response format');
//         }
//       } else {
//         throw Exception('Failed to fetch reminders');
//       }
//     } catch (e) {
//       // Handle error
//       print('Error fetching reminders: $e');
//     }
//   }

//   List<dynamic> currentReminders = [];

//   void updateNotifications(List<dynamic> newReminders) {
//     // Cancel notifications that are no longer needed
//     for (var reminder in currentReminders) {
//       if (!newReminders.contains(reminder)) {
//         cancelNotification(reminder);
//       }
//     }

//     // Schedule new notifications
//     for (var reminder in newReminders) {
//       if (!currentReminders.contains(reminder)) {
//         scheduleNotification(reminder);
//       }
//     }

//     // Update currentReminders with the latest data
//     currentReminders = newReminders;
//   }

//   Future<void> scheduleNotification(dynamic reminder) async {
//     String pillName = reminder['Pill_name'];
//     String pillType = reminder['Pill_type'];
//     int NumberofPills = reminder['NumberofPills'];
//     String PillTime = reminder['Pill_Time'];
//     String reminderDate = reminder['reminderDates'];
//     String reminderTime = reminder['reminder_times'];

//     DateTime scheduledDateTime = DateTime.parse('$reminderDate $reminderTime');
//     tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'reminders_channel',
//       'Reminders',
//       'Receive reminders for medication and appointments',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     var iOSPlatformChannelSpecifics = IOSNotificationDetails(
//       // sound: 'assets/sounds/iphone_alarm.wav',
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );

//     String notificationMessage = 'Take $NumberofPills $pillName ($pillType) now. Take it $PillTime';

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       '$reminderTime Pill Reminder',
//       notificationMessage,
//       scheduledTZDateTime,
//       platformChannelSpecifics,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//       payload: 'Reminder',
//     );
//   }

//   void cancelNotification(dynamic reminder) {
//     // Implement cancellation logic if needed
//   }

//   Future<void> onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
//     // Handle notification received while the app is in foreground
//     print('Received notification while the app is in foreground');
//   }

//   Future<void> onSelectNotification(String? payload) async {
//     // Handle notification tap
//     print('Notification tapped');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pill Reminders'),
//       ),
//       body: Center(
//         child: Text(
//           'Monitoring for reminders...',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class RemindersManager {
//   static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   static String? authToken;

//   static Future<void> initializeNotifications() async {
//     tz.initializeTimeZones();
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//     var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//     var initializationSettingsIOS = IOSInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       onDidReceiveLocalNotification: onDidReceiveLocalNotification,
//     );
//     var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: onSelectNotification,
//     );
//   }

//   static Future<void> fetchAndCheckReminders() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:8000/notifications/GetUpcomingPillReminders'),
//         headers: {
//           'Authorization': 'Bearer $authToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         var jsonResponse = jsonDecode(response.body);
//         if (jsonResponse is List) {
//           List<dynamic> newReminders = jsonResponse;
//           updateNotifications(newReminders);
//         } else if (jsonResponse is Map && jsonResponse.containsKey('message')) {
//           // Handle case when there are no reminders
//           updateNotifications([]);
//         } else {
//           throw Exception('Unexpected response format');
//         }
//       } else {
//         throw Exception('Failed to fetch reminders');
//       }
//     } catch (e) {
//       // Handle error
//       print('Error fetching reminders: $e');
//     }
//   }

//   static List<dynamic> currentReminders = [];

//   static void updateNotifications(List<dynamic> newReminders) {
//     // Cancel notifications that are no longer needed
//     for (var reminder in currentReminders) {
//       if (!newReminders.contains(reminder)) {
//         cancelNotification(reminder);
//       }
//     }

//     // Schedule new notifications
//     for (var reminder in newReminders) {
//       if (!currentReminders.contains(reminder)) {
//         scheduleNotification(reminder);
//       }
//     }

//     // Update currentReminders with the latest data
//     currentReminders = newReminders;
//   }

//   static Future<void> scheduleNotification(dynamic reminder) async {
//     String pillName = reminder['Pill_name'];
//     String pillType = reminder['Pill_type'];
//     int NumberofPills = reminder['NumberofPills'];
//     String PillTime = reminder['Pill_Time'];
//     String reminderDate = reminder['reminderDates'];
//     String reminderTime = reminder['reminder_times'];

//     DateTime scheduledDateTime = DateTime.parse('$reminderDate $reminderTime');
//     tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

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

//     var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );

//     String notificationMessage = 'Take $NumberofPills $pillName ($pillType) now. Take it $PillTime';

//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       '$reminderTime Pill Reminder',
//       notificationMessage,
//       scheduledTZDateTime,
//       platformChannelSpecifics,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//       payload: 'Reminder',
//     );
//   }

//   static void cancelNotification(dynamic reminder) {
//     // Implement cancellation logic if needed
//   }

//   static Future<void> onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
//     // Handle notification received while the app is in foreground
//     print('Received notification while the app is in foreground');
//   }

//   static Future<void> onSelectNotification(String? payload) async {
//     // Handle notification tap
//     print('Notification tapped');
//   }
// }
