import 'package:flutter/material.dart';
import 'package:careyou/widgets/navbar.dart';
import 'package:careyou/widgets/app_card.dart';
import 'package:careyou/pages/add_app.dart'; // Import AddApp screen
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppManage extends StatefulWidget {
  final String token;

  const AppManage({required this.token});

  @override
  _AppManageState createState() => _AppManageState();
}

class _AppManageState extends State<AppManage> {
  bool showEditButton = true; // Initially show "Edit" button
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  Future<void> _getToken() async {
    // Replace with actual token retrieval logic
    // For example, you might fetch it from secure storage or a login service
    setState(() {
      _token = 'YOUR_TOKEN_HERE'; // Replace with actual token
    });
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    if (_token.isEmpty) {
      print("Token is empty");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/ShowAppointmentListForElderlyAppointmentBoxs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_token', // Use the token
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _appointments = List<Map<String, dynamic>>.from(json.decode(response.body));
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

  Future<void> _deleteAppointment(int appointmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8000/DeleteAppointmentReminder/$appointmentId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_token', // Use the token
        },
      );

      if (response.statusCode == 200) {
        print("Appointment deleted successfully");
        setState(() {
          _appointments.removeWhere((appointment) => appointment['Appointment_id'] == appointmentId);
        });
      } else {
        print("Failed to delete appointment: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception while deleting appointment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(106),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF00916E),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today is Wed 24, 2024',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00916E),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Row(
                          children: [
                            if (showEditButton)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Toggle the state to show/hide edit button
                                    showEditButton = false;
                                  });
                                },
                                child: Container(
                                  width: 60,
                                  height: 21,
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
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (!showEditButton)
                              GestureDetector(
                                onTap: () {
                                  // // Navigate to AddApp screen
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => const AddApp(),
                                  //   ),
                                  // );
                                },
                                child: Container(
                                  width: 60,
                                  height: 21,
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
                                        fontSize: 12,
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
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _appointments.isEmpty
                              ? Center(child: Text('No appointments found'))
                              : ListView.builder(
                                  itemCount: _appointments.length,
                                  itemBuilder: (context, index) {
                                    final appointment = _appointments[index];
                                    return AppCard(
                                      showButtons: !showEditButton,
                                      appointment: appointment,
                                      deleteAppointment: showEditButton ? null : _deleteAppointment,
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
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }
}
