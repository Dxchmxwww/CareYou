import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:careyou/components/navbar.dart';

class AppointmentsList extends StatefulWidget {
  final String token;
  final String selectedRole;

  const AppointmentsList({required this.token, required this.selectedRole});

  @override
  _AppointmentsListState createState() => _AppointmentsListState();
}

class _AppointmentsListState extends State<AppointmentsList> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/ShowAppointmentListForElderlyAppointmentBoxs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add your authorization token if needed
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _appointments =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        print("Failed to fetch appointments: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Exception while fetching appointments: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmationDialog(int appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: Text(
            "Delete Appointment",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: const Color(0xFF000000),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Are you sure you want to delete this appointment?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: const Color(0xFF727070),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(width: 8),
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
                    _deleteAppointment(appointmentId);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAppointment(int appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://localhost:8000/DeleteAppointmentReminder/$appointmentId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add your authorization token if needed
          // 'Authorization': 'Bearer yourAccessTokenHere',
        },
      );

      if (response.statusCode == 200) {
        print("Appointment deleted successfully");
        // Remove the deleted appointment from the list
        setState(() {
          _appointments
              .removeWhere((appointment) => appointment['id'] == appointmentId);
        });
      } else {
        print("Failed to delete appointment: ${response.statusCode}");
        // Handle error, e.g., show an error message
      }
    } catch (e) {
      print("Exception while deleting appointment: $e");
      // Handle exception, e.g., show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments List'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? Center(child: Text('No appointments found'))
              : ListView.builder(
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
                    return AppCard(
                      appointment: appointment,
                      showButtons: true,
                    );
                  },
                ),
      bottomNavigationBar: NavBar(
          token: widget.token,
          initialIndex: 3,
          selectedRole: widget.selectedRole),
    );
  }
}

class AppCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool showButtons;

  const AppCard(
      {Key? key, required this.appointment, required this.showButtons})
      : super(key: key);

  void _showDeleteConfirmationDialog(BuildContext context, int appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: Text(
            "Delete Appointment",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: const Color(0xFF000000),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Are you sure you want to delete this appointment?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: const Color(0xFF727070),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(width: 8),
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
                    // Call delete function passed via constructor
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
                      appointment['Appointment_name'] ?? '',
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
                          '${appointment['Date']}   ${appointment['StartTime']} - ${appointment['EndTime']}',
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
                          appointment['Location'] ?? '',
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
              top: 15,
              right: 14,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle edit button action
                      print('Edit button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor:
                          const Color(0xFFFFB82D), // Yellow button color
                      minimumSize: const Size(60, 18), // Adjust button size
                      fixedSize: const Size(
                          60, 18), // Set fixed size using width and height
                    ),
                    child: Container(
                      width: 60,
                      height: 18,
                      alignment: Alignment.center,
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10, // Adjust font size
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  ElevatedButton(
                    onPressed: () {
                      // Show delete confirmation dialog
                      _showDeleteConfirmationDialog(
                          context,
                          appointment[
                              'id']); // Replace with actual appointment ID
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
}
