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
  List<Map<String, dynamic>> appointments = []; // List to store appointments

  Future<void> fetchAppointmentData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/appointments/ShowTodayAppointmentRemailderListForElderly'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          appointments = List<Map<String, dynamic>>.from(data);
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

  @override
  Widget build(BuildContext context) {
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
          child: appointments.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Appointments",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: appointments.map((appointment) {
                        String startTime =
                            _formatTime(appointment['StartTime']);
                        String endTime = _formatTime(appointment['EndTime']);
                        String location = appointment['Location'];
                        String appointmentName =
                            appointment['Appointment_name'];

                        return Center(
                          child: Container(
                            width: screenWidth * 0.9,
                            height: 100,
                            margin: const EdgeInsets.symmetric(vertical: 10),
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
                                    Text("$startTime - $endTime",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400)),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 55.0),
                                      child: Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF42A0A9),
                                        size: 19.0,
                                      ), // Location icon
                                    ),
                                    const SizedBox(width: 10),
                                    Text(location,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400)),
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
                                    Text(appointmentName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              : const Center(
                  child: Text(
                    "You don't have any appointments",
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

  String _formatTime(String time) {
    try {
      if (time.length >= 16) {
        return time.substring(
            11, 16); // Extracts "HH:mm" from "YYYY-MM-DDTHH:mm:ss"
      } else if (time.length >= 5) {
        return time.substring(0, 5); // Extracts "HH:mm" from "HH:mm:ss"
      } else {
        return time; // Return the time string as is if it's already in "HH:mm" format or another unexpected format
      }
    } catch (e) {
      print('Error formatting time: $e');
      return time; // Return the original time string if an error occurs
    }
  }
}
