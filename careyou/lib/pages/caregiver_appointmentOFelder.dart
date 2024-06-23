import 'package:careyou/components/navbar.dart';
import 'package:flutter/material.dart';

class CaregiverAppointmentOfElder extends StatefulWidget {
  final String token;
  final String selectedRole;

  const CaregiverAppointmentOfElder({required this.token, required this.selectedRole});

  @override
  _CaregiverAppointmentOfElderState createState() =>
      _CaregiverAppointmentOfElderState();
}

class _CaregiverAppointmentOfElderState
    extends State<CaregiverAppointmentOfElder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caregiver Appointment of Elder'),
      ),
      body: Container(
        // Add your UI components here
      ),
      bottomNavigationBar: NavBar(
          token: widget.token,
          initialIndex: 3,
          selectedRole: widget.selectedRole),
    );
  }
}