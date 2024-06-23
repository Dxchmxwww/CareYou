// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:careyou/widgets/navbar.dart';
// import 'package:careyou/widgets/app_card.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../widgets/app_card_forcargiver.dart';

// class AppManage extends StatefulWidget {
//   final String token;

//   // const AppManage({required this.token, this.selectedRole = 'Caregiver'});
//   const AppManage({required this.token});

//   @override
//   _AppManageState createState() => _AppManageState();
// }

// class _AppManageState extends State<AppManage> {
//   bool showEditButton = true; // Initially show "Edit" button
//   List<Map<String, dynamic>> appointments = []; // Store today's date for display
//   late Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAppointments();

//     // Set up a periodic timer to refresh every 2 seconds
//     _timer = Timer.periodic(Duration(seconds: 2), (timer) {
//       _fetchAppointments();
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel(); // Cancel the timer when the widget is disposed
//     super.dispose();
//   }

//   Future<void> _fetchAppointments() async {
//     final url = Uri.parse('http://localhost:8000/appointments/ShowAppointmentReminderListforCaregiver');

//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           appointments = List<Map<String, dynamic>>.from(data.map((appointment) {
//             final originalDate = DateTime.parse(appointment['Date']);
//             final formattedDate = '${originalDate.day.toString().padLeft(2, '0')}/${originalDate.month.toString().padLeft(2, '0')}/${originalDate.year}';
//             final formattedStartTime = appointment['StartTime'].substring(0, 5); // Extract HH:MM from backend time string
//             final formattedEndTime = appointment['EndTime'].substring(0, 5); // Extract HH:MM from backend time string
//               return {
//                 'Appointment_id': appointment['Appointment_id'],
//                 'Appointment_name': appointment['Appointment_name'],
//                 'Date': formattedDate,
//                 'StartTime': formattedStartTime,
//                 'EndTime': formattedEndTime,
//                 'Location': appointment['Location'],
//             };
//           }));
//         });
//       } else {
//         print('Failed to fetch appointments: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching appointments: $e');
//     }
//   }

//   @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: PreferredSize(
//       preferredSize: const Size.fromHeight(50),
//       child: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: const Color(0xFF00916E),
//         flexibleSpace: Padding(
//           padding: const EdgeInsets.only(top: 30.0),
//           child: Stack(
//             children: [
//               Center(
//                 child: Text(
//                   'Appointment Management',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 20,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               Positioned(
//                 left: 16,
//                 top: 0,
//                 bottom: 0,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   color: Colors.white,
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Navigate back
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//     body: GestureDetector(
//       onTap: () {
//         setState(() {
//           showEditButton = true; // Toggle to show edit button on tap anywhere on the page
//         });
//       },
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           return Stack(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Spacer(), // Pushes the buttons to the far right
//                         Row(
//                           children: [
//                             if (showEditButton)
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     showEditButton = false; // Toggle the state to show/hide edit button
//                                   });
//                                 },
//                                 child: Container(
//                                   width: 70,
//                                   height: 30,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF54900),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       'Edit',
//                                       style: TextStyle(
//                                         fontFamily: 'Poppins',
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             if (!showEditButton)
//                               GestureDetector(
//                                 onTap: () {
//                                   // Navigate to AddApp screen
//                                   // Navigator.push(
//                                   //   context,
//                                   //   MaterialPageRoute(builder: (context) => const AddApp()),
//                                   // );
//                                 },
//                                 child: Container(
//                                   width: 60,
//                                   height: 21,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF54900),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       '+Add',
//                                       style: TextStyle(
//                                         fontFamily: 'Poppins',
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
//                       child: ListView.builder(
//                         itemCount: appointments.length,
//                         itemBuilder: (context, index) {
//                           final appointment = appointments[index];
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 10.0),
//                             child: AppCardForCargiver(
//                               showButtons: !showEditButton,
//                               appointmentId: appointment['Appointment_id'],
//                               appointmentName: appointment['Appointment_name'],
//                               date: appointment['Date'],
//                               startTime: appointment['StartTime'],
//                               endTime: appointment['EndTime'],
//                               location: appointment['Location'],
//                               token: widget.token,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: NavBar(), // Renders the navigation bar at the bottom
//               ),
//             ],
//           );
//         },
//       ),
//     ),
//     backgroundColor: const Color(0xFFFFFFFF),
//   );
// }

// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:careyou/widgets/navbar.dart';
import 'package:careyou/widgets/app_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/app_card_forcargiver.dart';

class AppManage extends StatefulWidget {
  final String token;

  // const AppManage({required this.token, this.selectedRole = 'Caregiver'});
  const AppManage({required this.token});

  @override
  _AppManageState createState() => _AppManageState();
}

class _AppManageState extends State<AppManage> {
  bool showEditButton = true; // Initially show "Edit" button
  List<Map<String, dynamic>> appointments = []; // Store today's date for display
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
    final url = Uri.parse('http://localhost:8000/appointments/ShowAppointmentReminderListforCaregiver');

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
          appointments = List<Map<String, dynamic>>.from(data.map((appointment) {
            final originalDate = DateTime.parse(appointment['Date']);
            final formattedDate = '${originalDate.day.toString().padLeft(2, '0')}/${originalDate.month.toString().padLeft(2, '0')}/${originalDate.year}';
            final formattedStartTime = appointment['StartTime'].substring(0, 5); // Extract HH:MM from backend time string
            final formattedEndTime = appointment['EndTime'].substring(0, 5); // Extract HH:MM from backend time string
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
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF00916E),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'Appointment Management',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop(); // Navigate back
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            showEditButton = true; // Toggle to show edit button on tap anywhere on the page
          });
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(), // Pushes the buttons to the far right
                          Row(
                            children: [
                              if (showEditButton)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showEditButton = false; // Toggle the state to show/hide edit button
                                    });
                                  },
                                  child: Container(
                                    width: 65,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF54900),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (!showEditButton)
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to AddApp screen
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => const AddApp()),
                                    // );
                                  },
                                  child: Container(
                                    width: 65,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF54900),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+Add',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                        child: ListView.builder(
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = appointments[index];
                            return GestureDetector(
                              onTap: () {
                                // Handle tap on appointment card to set showEditButton to true
                                setState(() {
                                  showEditButton = true;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: AppCardForCargiver(
                                  showButtons: !showEditButton,
                                  appointmentId: appointment['Appointment_id'],
                                  appointmentName: appointment['Appointment_name'],
                                  date: appointment['Date'],
                                  startTime: appointment['StartTime'],
                                  endTime: appointment['EndTime'],
                                  location: appointment['Location'],
                                  token: widget.token,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: NavBar(), // Renders the navigation bar at the bottom
                ),
              ],
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }
}
