import 'package:careyou/components/navbar.dart';
import 'package:careyou/widgets/app_card.dart';
import 'package:flutter/material.dart';

class AppointmentForElder extends StatefulWidget {
  final String token;
  final String selectedRole;

  const AppointmentForElder(
      {required this.token, this.selectedRole = 'Elderly'});

  @override
  State<AppointmentForElder> createState() => _AppointmentForElderState();
}

class _AppointmentForElderState extends State<AppointmentForElder> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEditMode) {
          setState(() {
            isEditMode = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(
                  children: [
                    AppCard(
                      isEditMode: isEditMode,
                      token: widget.token,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavBar(
            token: widget.token,
            initialIndex: 3,
            selectedRole: widget.selectedRole),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: Container(
        color: const Color(0xFF00916E),
        padding: const EdgeInsets.only(top: 10),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF00916E),
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Doctor Appointments',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
