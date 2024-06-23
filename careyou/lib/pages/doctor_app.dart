import 'package:flutter/material.dart';
import 'package:careyou/widgets/navbar.dart';
import 'package:careyou/widgets/app_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DocApp extends StatefulWidget {
  const DocApp({super.key});

  @override
  _DocAppState createState() => _DocAppState();
}

class _DocAppState extends State<DocApp> {
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
        Uri.parse('http://localhost:8000/ShowAppointmentListForElderlyAppointmentBoxs'), // Replace with actual endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_token',
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
          'Authorization': 'Bearer $_token',
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
                const Center(
                  child: Text(
                    'Doctor Appointment',
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                child: Text(
                  'Your Appointment',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00916E),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  'Today is June 24, 2024',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00916E),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _appointments.isEmpty
                          ? const Center(child: Text('No appointments found'))
                          : ListView.builder(
                              itemCount: _appointments.length,
                              itemBuilder: (context, index) {
                                final appointment = _appointments[index];
                                return AppCard(
                                  showButtons: true,
                                  appointment: appointment,
                                  deleteAppointment: _deleteAppointment,
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavBar(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }
}

