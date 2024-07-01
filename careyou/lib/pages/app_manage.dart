import 'dart:async';
import 'dart:io';
import 'package:careyou/pages/Cargiver_createappoinment.dart';
import 'package:flutter/material.dart';
import 'package:careyou/components/navbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_card_forcargiver.dart';

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

    String getServerUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000'; // iOS simulator
    } else{
      return 'http://localhost:8000';
    }
  }



  Future<void> _fetchAppointments() async {
    final url = Uri.parse(
        '${getServerUrl()}/appointments/ShowAppointmentReminderListforCaregiver');

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
                                  builder: (context) =>
                                      CreateAppointmentReminder(
                                    token: widget.token, selectedRole: widget.selectedRole
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
              // ListView.builder(
              //   shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              //   itemCount: appointments.length,
              //   itemBuilder: (context, index) {
              //     final appointment = appointments[index];
              //     return GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           showEditButton = false;
              //         });
              //       },
              //       child: Padding(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 20, vertical: 10),
              //         child: AppCardForCargiver(
              //           showButtons: showEditButton,
              //           appointmentId: appointment['Appointment_id'] ?? '',
              //           appointmentName: appointment['Appointment_name'] ?? '',
              //           date: appointment['Date'] ?? '',
              //           startTime: appointment['StartTime'] ?? '',
              //           endTime: appointment['EndTime'] ?? '',
              //           location: appointment['Location'] ?? '',
              //           token: widget.token,
              //         ),
              //       ),
              //     );
              //   },
              // ),

              appointments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Your elder doesn't have any appointment",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
