// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../widgets/app_card_forcargiver.dart';
// import 'package:careyou/components/navbar.dart';

// class AppManage extends StatefulWidget {
//   final String token;
//   final String selectedRole;

//   const AppManage({required this.token, required this.selectedRole});

//   @override
//   _AppManageState createState() => _AppManageState();
// }

// class _AppManageState extends State<AppManage> {
//   bool showEditButton = true;
//   List<Map<String, dynamic>> appointments = [];

// late Timer _timer;

// @override
// void initState() {
//   super.initState();
//   _fetchAppointments();

//   // Set up a periodic timer to refresh every 2 seconds
//   _timer = Timer.periodic(Duration(seconds: 2), (timer) {
//     _fetchAppointments();
//   });
// }

// @override
// void dispose() {
//   _timer.cancel(); // Cancel the timer when the widget is disposed
//   super.dispose();
// }

// Future<void> _fetchAppointments() async {
//   final url = Uri.parse(
//       'http://localhost:8000/appointments/ShowAppointmentReminderListforCaregiver');

//   try {
//     final response = await http.get(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${widget.token}',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       setState(() {
//         appointments =
//             List<Map<String, dynamic>>.from(data.map((appointment) {
//           final originalDate = DateTime.parse(appointment['Date']);
//           final formattedDate =
//               '${originalDate.day.toString().padLeft(2, '0')}/${originalDate.month.toString().padLeft(2, '0')}/${originalDate.year}';
//           final formattedStartTime =
//               appointment['StartTime'].substring(0, 5); // HH:MM
//           final formattedEndTime =
//               appointment['EndTime'].substring(0, 5); // HH:MM
//           return {
//             'Appointment_id': appointment['Appointment_id'],
//             'Appointment_name': appointment['Appointment_name'],
//             'Date': formattedDate,
//             'StartTime': formattedStartTime,
//             'EndTime': formattedEndTime,
//             'Location': appointment['Location'],
//           };
//         }));
//       });
//     } else {
//       print('Failed to fetch appointments: ${response.body}');
//     }
//   } catch (e) {
//     print('Error fetching appointments: $e');
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(70),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Color(0xFF00916E),
//           title: Padding(
//             padding: const EdgeInsets.only(top: 10),
//             child: Text(
//               'Appointment Management',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 22,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           centerTitle: true,
//         ),
//       ),
//       body: GestureDetector(
//         onTap: () {
//           setState(() {
//             showEditButton = true;
//           });
//         },
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return Stack(
//               children: [
//                 Column(
//                   children: [
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           if (showEditButton)
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   showEditButton = false;
//                                 });
//                               },
//                               child: Container(
//                                 width: 65,
//                                 height: 25,
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFF54900),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     'Edit',
//                                     style: TextStyle(
//                                       fontFamily: 'Poppins',
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           if (!showEditButton)
//                             GestureDetector(
//                               onTap: () {
//                                 // Navigate to AddApp screen
//                                 // Navigator.push(
//                                 //   context,
//                                 //   MaterialPageRoute(builder: (context) => const AddApp()),
//                                 // );
//                               },
//                               child: Container(
//                                 width: 65,
//                                 height: 25,
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFF54900),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     '+Add',
//                                     style: TextStyle(
//                                       fontFamily: 'Poppins',
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: appointments.length,
//                         itemBuilder: (context, index) {
//                           final appointment = appointments[index];
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 showEditButton = true;
//                               });
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10),
//                               child: AppCardForCargiver(
//                                 showButtons: !showEditButton,
//                                 appointmentId:
//                                     appointment['Appointment_id'] ?? '',
//                                 appointmentName:
//                                     appointment['Appointment_name'] ?? '',
//                                 date: appointment['Date'] ?? '',
//                                 startTime: appointment['StartTime'] ?? '',
//                                 endTime: appointment['EndTime'] ?? '',
//                                 location: appointment['Location'] ?? '',
//                                 token: widget.token,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//       backgroundColor: const Color(0xFFFFFFFF), // Set background color here
//       bottomNavigationBar: NavBar(
//         token: widget.token,
//         initialIndex: 1, // Adjust initial index as needed
//         selectedRole: widget.selectedRole,
//       ), // Add bottom navigation bar here
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:careyou/pages/appointmentCreatePage.dart';
import 'package:careyou/pages/pillsManageCreatePage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../widgets/app_card_forcargiver.dart';
import 'package:careyou/components/navbar.dart';

class AppManage extends StatefulWidget {
  final String token;
  final String selectedRole;

  const AppManage({
    required this.token,
    required this.selectedRole,
  });

  @override
  State<AppManage> createState() => _AppManageState();
}

class _AppManageState extends State<AppManage> {
  bool showEditButton = false;
  List<Map<String, dynamic>> appointments = [];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();

    // Set up a periodic timer to refresh every 2 seconds
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchAppointments();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    final url = Uri.parse(
        'http://localhost:8000/appointments/ShowAppointmentReminderListforCaregiver');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          appointments =
              List<Map<String, dynamic>>.from(data.map((appointment) {
            final originalDate = DateTime.parse(appointment['Date']);
            final formattedDate =
                '${originalDate.day.toString().padLeft(2, '0')}/${originalDate.month.toString().padLeft(2, '0')}/${originalDate.year}';
            final formattedStartTime =
                appointment['StartTime'].substring(0, 5); // HH:MM
            final formattedEndTime =
                appointment['EndTime'].substring(0, 5); // HH:MM
            return {
              'Appointment_id': appointment['Appointment_id'],
              'Appointment_name': appointment['Appointment_name'],
              'Date': formattedDate,
              'StartTime': formattedStartTime,
              'EndTime': formattedEndTime,
              'Location': appointment['Location'],
            };
          }));
        });
      } else {
        print('Failed to fetch appointments: ${response.body}');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF00916E),
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Appointment management',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            showEditButton = false;
          });
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (showEditButton) {
                              // Navigate to add appointment screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AppointmentCreatePage(
                                    token: widget.token,
                                  ),
                                ),
                              );
                            }
                            showEditButton = !showEditButton;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF54900),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              showEditButton ? Icons.add : Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              showEditButton ? 'Add' : 'Edit',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        showEditButton = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: AppCardForCargiver(
                        showButtons: showEditButton,
                        appointmentId: appointment['Appointment_id'] ?? '',
                        appointmentName: appointment['Appointment_name'] ?? '',
                        date: appointment['Date'] ?? '',
                        startTime: appointment['StartTime'] ?? '',
                        endTime: appointment['EndTime'] ?? '',
                        location: appointment['Location'] ?? '',
                        token: widget.token,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: NavBar(
        token: widget.token,
        initialIndex: 3, // Adjust initial index as needed
        selectedRole: widget.selectedRole,
      ),
    );
  }
}
