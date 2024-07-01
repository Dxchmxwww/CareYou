//import 'package:careyou/components/appointmentCard.dart';
import 'dart:io';

import 'package:careyou/components/appointmentCard.dart';
import 'package:careyou/components/logOutButton.dart';
import 'package:careyou/components/pillsCardCareGiver.dart';
import 'package:careyou/components/appointmentCard_forCaregiver.dart';
import 'package:careyou/components/navbar.dart'; // Import the file that contains the NavBar class

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePageCareGiver extends StatefulWidget {
  final String token;
  final String selectedRole;

  const HomePageCareGiver({required this.token, required this.selectedRole});

  @override
  State<HomePageCareGiver> createState() => _HomePageCareGiverState();
}

class _HomePageCareGiverState extends State<HomePageCareGiver> {
  TextEditingController usernameController = TextEditingController();

  String username = '';
  String currentDate = '';
  String elderlyRelation = '';

  @override
  void initState() {
    super.initState();
    fetchCaregiverData();
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

  Future<void> fetchCaregiverData() async {
    try {
      final response = await http.get(
        Uri.parse('${getServerUrl()}/profiles/Caregiver'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['caregiver']['username'];
          currentDate = data['currentDate'];
          if (data['caregiver'].containsKey('yourelderly_relation')) {
            elderlyRelation = data['caregiver']['yourelderly_relation'];
          } else {
            elderlyRelation = ''; // Set to empty if not found
          }
        });
      } else {
        // Handle error
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch data. Please try again later.'),
            actions: [
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: const Color(0xFF00916E),
            ),
          ),

          // Log out button
          Positioned(
            top: 60,
            right: 20,
            child: LogoutButton(),
          ),

          // Hello user and Date section
          Padding(
            padding: EdgeInsets.only(top: 100.0, left: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hello user
                Text(
                  'Hello, ${username.length > 8 ? username.substring(0, 8) : username}',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Date
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Today is $currentDate',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 0.0),
                  child: Row(
                    children: [
                      Text(
                        'Your under care',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF99D19C),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$elderlyRelation',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // White box with scrollable content
          Positioned.fill(
            top: 250.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today Appointment Card
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 0),
                      child: AppointmentCard_caregiver(token: widget.token),
                    ),

                    // Line between AppointmentCard and PillsCard
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Divider(
                        color: Color(0xFF00916E),
                        thickness: 1,
                      ),
                    ),

                    // Pills Card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: PillsCardCareGiver(token: widget.token),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
          token: widget.token,
          initialIndex: 0,
          selectedRole: widget.selectedRole),
    );
  }
}
