// ignore: file_names
import 'package:flutter/material.dart';
import 'dart:convert'; // For jsonDecode
import 'package:http/http.dart' as http; // For making HTTP requests

class AppointmentCard extends StatefulWidget {
  final String token;
  const AppointmentCard({required this.token});

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  String appointmentName = "";
  String startTime = "";
  String endTime = "";
  String location = "";
  bool hasAppointment = false;

  Future<void> fetchAppointmentData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/appointments/ShowTodayAppointmentRemailderListForElderly'),
        headers: {
          'Authorization':
              'Bearer ${widget.token}', // Replace with your actual token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data'); // Print the JSON data for debugging
        setState(() {
          if (data.isNotEmpty) {
            appointmentName = data[0]['Appointment_name'];
            startTime = _formatTime(data[0]['StartTime']);
            endTime = _formatTime(data[0]['EndTime']);
            location = data[0]['Location'];
            hasAppointment = true; // Appointment found
          } else {
            hasAppointment = false; // No appointment found
          }
        });
      } else {
        throw Exception('Failed to load appointment data');
      }
    } catch (e) {
      print('Failed to load appointment data: $e');
      throw Exception('Failed to load appointment data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppointmentData(); // Fetch data when the widget is initialized
  }

  String _formatTime(String time) {
    // Assuming time format is "HH:mm:ss"
    return time.substring(11, 16); // Extracts "HH:mm"
  }

  @override
  Widget build(BuildContext context) {
    // Calculate device screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      child: Card(
        color: const Color(0xFF42A990),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: hasAppointment
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Today's Appointment",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: screenWidth * 0.9,
                        height: 73,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Icon(
                                    Icons.access_time,
                                    color: Color(0xFF42A0A9),
                                    size: 19.0,
                                  ), // Clock icon
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "$startTime - $endTime",
                                  style: const TextStyle(
                                      fontSize: 14, fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400)
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 55.0),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFF42A0A9),
                                    size: 19.0,
                                  ), // Location icon
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  location,
                                  style: const TextStyle(
                                     fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400)
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFF42A0A9),
                                    size: 19.0,
                                  ), // Info icon
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  appointmentName,
                                  style: const TextStyle(
                                      fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    "You don't have any appointments today",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
