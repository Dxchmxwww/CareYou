// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:careyou/service/notification_service.dart';

// class ReminderMonitor extends StatefulWidget {
//   @override
//   _ReminderMonitorState createState() => _ReminderMonitorState();
// }

// class _ReminderMonitorState extends State<ReminderMonitor> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance?.addPostFrameCallback((_) {
//       final notificationService = Provider.of<NotificationService>(context, listen: false);
//       notificationService.fetchAndCheckReminders();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(); // This widget doesn't need to display anything
//   }
// }
