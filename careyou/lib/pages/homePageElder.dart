// import 'package:careyou/components/appointmentCard.dart';
// import 'package:careyou/components/logOutButton.dart';
// import 'package:careyou/components/pillsCardElder.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class HomePageElder extends StatefulWidget {
//   final String token;

//   const HomePageElder({required this.token});

//   @override
//   State<HomePageElder> createState() => _HomePageElderState();
// }

// class _HomePageElderState extends State<HomePageElder> {
//   TextEditingController usernameController = TextEditingController();
  

//   String username = '';
//   String currentDate = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchElderlyData();
//   }

//   Future<void> fetchElderlyData() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:8000/profiles/Showusername'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           username = data['username'];
//           currentDate = data['currentDate'];
//           usernameController.text = username;
//         });
//       } else {
//         // Handle error
//         print('Failed to load data: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Handle exceptions
//       print('Exception: $e');
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Error'),
//             content: Text('Failed to fetch data. Please try again later.'),
//             actions: [
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background color
//           Container(
//             height: MediaQuery.of(context).size.height,
//             decoration: BoxDecoration(
//               color: const Color(0xFF00916E),
//             ),
//           ),

//           // Log out button
//           Positioned(
//             top: 60,
//             right: 20,
//             child: LogoutButton(),
//           ),

//           // Hello user and Date section
//           Padding(
//             padding: EdgeInsets.only(top: 100.0, left: 50.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Hello user
//                 Text(
//                   'Hello, ${username.length > 8 ? username.substring(0, 8) : username}',
//                   style: TextStyle(
//                     fontFamily: 'poppins',
//                     fontSize: 35,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 // Date
//                 Padding(
//                   padding: EdgeInsets.only(top: 8.0),
//                   child: Text(
//                     'Today is $currentDate',
//                     style: TextStyle(
//                       fontFamily: 'poppins',
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // White box with scrollable content
//           Positioned.fill(
//             top: 205.0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30.0),
//                   topRight: Radius.circular(30.0),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Today Appointment Card
//                     Padding(
//                       padding: EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0),
//                       child: AppointmentCard(token: widget.token),
//                     ),

//                     // Line between AppointmentCard and PillsCard
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                           vertical: 10.0, horizontal: 20.0),
//                       child: Divider(
//                         color: Color(0xFF00916E),
//                         thickness: 1,
//                       ),
//                     ),

//                     // Pills Card
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 10.0),
//                       child: PillsCardElder(token: widget.token),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:careyou/components/appointmentCard.dart';
import 'package:careyou/components/pillsCardElder.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// reminder.dart (or a suitable file name)
class Reminder {
  final String pillName;
  final String pillType;
  final int numberOfPills;
  final String pillTime;
  final String reminderDate;
  final String reminderTime;

  Reminder({
    required this.pillName,
    required this.pillType,
    required this.numberOfPills,
    required this.pillTime,
    required this.reminderDate,
    required this.reminderTime,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      pillName: json['Pill_name'],
      pillType: json['Pill_type'],
      numberOfPills: json['NumberofPills'],
      pillTime: json['Pill_Time'],
      reminderDate: json['reminderDates'],
      reminderTime: json['reminder_times'],
    );
  }
}

class HomePageElder extends StatefulWidget {
  final String token;

  const HomePageElder({required this.token});

  @override
  State<HomePageElder> createState() => _HomePageElderState();
}

class _HomePageElderState extends State<HomePageElder> {
  TextEditingController usernameController = TextEditingController();
  String username = '';
  String currentDate = '';
  List<Reminder> currentReminders = []; // Track reminders
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    fetchElderlyData();
    initializeNotifications();
  }

  void initializeNotifications() {
    tz.initializeTimeZones();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle notification tap
    print('Notification tapped');
  }

  Future<void> fetchElderlyData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/profiles/Showusername'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'];
          currentDate = data['currentDate'];
          usernameController.text = username;
        });
      } else {
        // Handle error
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch data. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchAndScheduleNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/notifications/GetUpcomingPillReminders'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Reminder> reminders = jsonResponse.map((json) => Reminder.fromJson(json)).toList();

        setState(() {
          currentReminders = reminders;
        });

        // Schedule notifications for fetched reminders
        for (var reminder in currentReminders) {
          await scheduleNotification(reminder);
        }
      } else {
        // Handle error
        print('Failed to fetch reminders: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
  }

  Future<void> scheduleNotification(Reminder reminder) async {
    // Extract reminder details
    String pillName = reminder.pillName;
    String pillType = reminder.pillType;
    int numberOfPills = reminder.numberOfPills;
    String pillTime = reminder.pillTime;
    String reminderDate = reminder.reminderDate;
    String reminderTime = reminder.reminderTime;

    // Combine reminderDate and reminderTime and parse them to create a DateTime object
    DateTime scheduledDateTime = DateTime.parse('$reminderDate $reminderTime');

    // Convert DateTime to TZDateTime using the local time zone
    tz.TZDateTime scheduledTZDateTime =
        tz.TZDateTime.from(scheduledDateTime, tz.local);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'reminders_channel', // channel_id
      'Reminders', // channel_name
      'Receive reminders for medication and appointments', // channel_description
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    String notificationMessage = 'Take $numberOfPills $pillName ($pillType) now at $pillTime';

    // Schedule the notification if it's in the future
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '$reminderTime Pill Reminder',
      notificationMessage,
      scheduledTZDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'Reminder',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: const Color(0xFF00916E),
            ),
          ),

          // Log out button
          Positioned(
            top: 60,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                // Implement log out logic
              },
              child: Text('Log Out'),
            ),
          ),

          // Hello user and Date section
          Padding(
            padding: EdgeInsets.only(top: 100.0, left: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hello user
                Text(
                  'Hello, ${username.length > 8 ? username.substring(0, 8) : username}',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Date
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Today is $currentDate',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // White box with scrollable content
          Positioned.fill(
            top: 205.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today Appointment Card
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0),
                      child: AppointmentCard(token: widget.token),
                    ),

                    // Line between AppointmentCard and PillsCard
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Divider(
                        color: Color(0xFF00916E),
                        thickness: 1,
                      ),
                    ),

                    // Pills Card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: PillsCardElder(token: widget.token),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
