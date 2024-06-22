import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class Appointment {
  final int id;
  final String appointmentName;
  final String date;
  final String startTime;
  final String endTime;
  final String location;
  


  Appointment({
    required this.id,
    required this.appointmentName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['ID'] ?? 0, // Use a default value if 'ID' is null
      appointmentName: json['Appointment_name'] ?? '',
      date: json['Date'] ?? '',
      startTime: json['StartTime'] ?? '',
      endTime: json['EndTime'] ?? '',
      location: json['Location'] ?? '',
    );
  }
}

class AppCard extends StatefulWidget {
  final String token;
  final bool isEditMode;


  const AppCard({required this.token, required this.isEditMode,
  });

  @override
  _AppCardState createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool isLoading = false;
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/appointments/ShowAppointmentListForElderlyAppointmentBoxs'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Appointment> fetchedAppointments =
            data.map((json) => Appointment.fromJson(json)).toList();

        if (mounted) {
          setState(() {
            appointments = fetchedAppointments;
            isLoading = false;
          });
        }
      } else if (response.statusCode == 204) {
        if (mounted) {
          setState(() {
            appointments = [];
            isLoading = false;
          });
        }
        print('You have no appointments for today');
      } else {
        print(
            'Failed to load appointments - Server responded with status code ${response.statusCode}');
        throw Exception(
            'Failed to load appointments - Server responded with status code ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Failed to load appointments: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      throw Exception('Failed to load appointments: $e');
    }
  }

  void deleteAppointment(int appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://localhost:8000/appointments/DeleteAppointmentReminder/$appointmentId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

       print(
          'Delete appointment response: ${response.statusCode} ${response.body}');


      if (response.statusCode == 200) {
        // Remove the deleted appointment from the list
        setState(() {
          appointments
              .removeWhere((appointment) => appointment.id == appointmentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment reminder deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Appointment reminder not found for ID: $appointmentId'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unauthorized access'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to delete appointment - ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete appointments: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : appointments.isEmpty
            ? Center(child: Text('You don\'t have appointments today'))
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: AppCard2(
                      app: appointment,
                      isEditMode: widget.isEditMode,
                      onDelete: () => deleteAppointment(appointment.id),
                    ),
                  );
                },
              );
  }
}

class AppCard2 extends StatelessWidget {
  final Appointment app;
  final bool isEditMode;
  final VoidCallback onDelete;

  const AppCard2({
    required this.app,
    required this.isEditMode,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: isEditMode ? screenHeight * 0.12 : screenHeight * 0.10,
      child: Card(
        child: Container(
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 6.5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.04, // left
                      screenHeight * 0.015, // top padding value
                      screenWidth * 0.04, // right
                      0, // bottom
                    ),
                    child: Text(
                      '${app.appointmentName}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 105, 45),
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenWidth * 0.04, // left
                          0, // top padding value
                          screenWidth * 0.02, // right
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    color: const Color(0xFF00916E), size: 20),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  '${DateFormat('yy/MM/dd').format(DateTime.parse(app.date))} ${app.startTime.substring(0, 5)} - ${app.endTime.substring(0, 5)}',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.00),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: const Color(0xFF00916E), size: 20),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                '${app.location}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (isEditMode)
                Positioned(
                  bottom: 10,
                  right: 18,
                  child: Container(
                    height: 20,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  Colors.white, // Set background color to white
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize
                                    .min, // To minimize the size vertically
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                    size:
                                        40, // Adjust the size of the icon as needed
                                  ),
                                  SizedBox(
                                      height:
                                          8), // Optional spacing between icon and text
                                  Text(
                                    "Confirm Deletion",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors
                                          .black, // Optionally set text color
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          8), // Optional spacing between title and content
                                  Text(
                                    "Are you sure you want to delete this appointment?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Colors
                                          .black, // Optionally set text color
                                    ),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text("Cancel"),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: const Text("Delete"),
                                      onPressed: onDelete,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );



                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
