import 'package:careyou/components/appointmentCard.dart';
import 'package:careyou/components/logOutButton.dart';
import 'package:careyou/components/pillsCardElder.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePageElder extends StatefulWidget {
  final String token;

  const HomePageElder({required this.token});

  @override
  State<HomePageElder> createState() => _HomePageElderState();
}

class _HomePageElderState extends State<HomePageElder> {
  TextEditingController usernameController = TextEditingController();

  String username = '';
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    fetchElderlyData();
  }

  Future<void> fetchElderlyData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/profiles/Showusername'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'];
          currentDate = data['currentDate'];
          usernameController.text = username;
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
                child: Text('OK'),
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
              ],
            ),
          ),

          // White box with scrollable content
          Positioned.fill(
            top: 205.0,
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
                      child: AppointmentCard(token: widget.token),
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
                      child: PillsCardElder(token: widget.token),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}