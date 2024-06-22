import 'dart:async';
import 'package:careyou/components/appointmentCard.dart';
import 'package:careyou/components/logOutButton.dart';
import 'package:careyou/components/pillsCardElder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/cupertino.dart';

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
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer? timer;
  List<dynamic> currentReminders = [];
  Set<int> scheduledReminderIds = {};

  @override
  void initState() {
    super.initState();
    fetchElderlyData();
    initializeNotifications();
    fetchAndCheckReminders();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchAndCheckReminders());
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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

  void initializeNotifications() {
    tz.initializeTimeZones();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
          print(newReminders[0]);
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
    int timeId = reminder['time_id'];

    // Combine reminderDate and reminderTime and parse them to create a DateTime object
    DateTime scheduledDateTime = DateTime.parse('$reminderDate $reminderTime');

    // Convert DateTime to TZDateTime using the local time zone
    tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    // Check if the reminder has already been scheduled
    if (scheduledReminderIds.contains(timeId)) {
      return; // Skip scheduling if already scheduled
    }

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

    String notificationMessage = 'Take $NumberofPills $pillName ($pillType) now. Take it at $PillTime';

    // Schedule the notification if it's in the future
    if (scheduledTZDateTime.isAfter(tz.TZDateTime.now(tz.local))) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        timeId, // Use timeId as the unique identifier
        '$reminderTime Pill Reminder',
        notificationMessage,
        scheduledTZDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'Reminder',
      );

      // Add the reminder to the set of scheduled reminders
      scheduledReminderIds.add(timeId);
    }
  }

  void cancelNotification(dynamic reminder) {
    // Cancel notification using the unique identifier
    int timeId = reminder['time_id'];
    flutterLocalNotificationsPlugin.cancel(timeId);
    scheduledReminderIds.remove(timeId);
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
                  builder: (context) => HomePageElder(token: widget.token), // Replace with your second screen
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
            child: LogoutButton(),
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
