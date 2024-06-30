import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppCardForCargiver extends StatelessWidget {
  final bool showButtons;
  final int appointmentId;
  final String appointmentName;
  final String date;
  final String startTime;
  final String endTime;
  final String location;
  final String token;

  const AppCardForCargiver({
    Key? key,
    required this.showButtons,
    required this.appointmentId,
    required this.appointmentName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appointmentName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF54900),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Color(0xFF00916E)),
                        const SizedBox(width: 4),
                        Text(
                          '$date   $startTime - $endTime',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(Icons.place_outlined,
                            color: Color(0xFF00916E)),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showButtons)
            Positioned(
              top:
                  10, // Adjust the top position to move the delete button higher
              right: 14,
              child: Row(
                children: [
                  const SizedBox(width: 7),
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, appointmentId);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor:
                          const Color(0xFFFF0000), // Red button color
                      minimumSize: const Size(60, 18), // Adjust button size
                      fixedSize: const Size(
                          60, 18), // Set fixed size using width and height
                    ),
                    child: Container(
                      width: 60,
                      height: 18,
                      alignment: Alignment.center,
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10, // Adjust font size
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            surfaceTintColor:
                const Color(0xFFFFFFFF), // Set background color to white
            title: Text(
              "Delete Appointment",
              textAlign: TextAlign.center, // Center the title text
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: const Color(0xFF000000),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the column contents
              children: <Widget>[
                Text(
                  "Are you sure you want to delete this appointment?",
                  textAlign: TextAlign.center, // Center the text content
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: const Color(0xFF727070),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the buttons
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDADADA),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                    const SizedBox(width: 8), // Add spacing between buttons
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                      ),
                      child: Text(
                        "Yes, Delete",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _deleteAppointment(context, appointmentId);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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


  Future<void> _deleteAppointment(
      BuildContext context, int appointmentId) async {
    final url = Uri.parse(
        '${getServerUrl()}/appointments/DeleteAppointmentReminder/$appointmentId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Appointment deleted successfully');
        Navigator.of(context).pop(); // Close the confirmation dialog
        // Optionally, you can add a callback to refresh the list of appointments or show a success message
      } else {
        print('Failed to delete appointment: ${response.body}');
        Navigator.of(context).pop(); // Close the confirmation dialog
        // Optionally, show an error message
      }
    } catch (e) {
      print('Error deleting appointment: $e');
      Navigator.of(context).pop(); // Close the confirmation dialog
      // Optionally, show an error message
    }
  }
}
