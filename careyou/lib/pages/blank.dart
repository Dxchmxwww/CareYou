import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pill {
  final String pillName;
  final String pillType;
  final String pillNote;
  final String pillTime;
  final String reminderTimes;
  final int status; // New field for status

  Pill({
    required this.pillName,
    required this.pillType,
    required this.pillNote,
    required this.pillTime,
    required this.reminderTimes,
    required this.status, // Initialize with status
  });

  factory Pill.fromJson(Map<String, dynamic> json) {
    return Pill(
      pillName: json['pill_name'],
      pillType: json['pill_type'],
      pillNote: json['pill_note'],
      pillTime: json['pill_Time'],
      reminderTimes: json['reminder_times'],
      status: json['status'], // Assign status from JSON
    );
  }
}

class PillsCardCareGiver extends StatelessWidget {
  final String token;

  const PillsCardCareGiver({required this.token});

  Future<List<Pill>> fetchPills() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/pills/ShowTodayPillRemindersOfElderForCaregiverHome'),
        headers: {
          'Authorization': 'Bearer $token', // Replace with your actual token
        },
      );

      print('Backend Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pill.fromJson(json)).toList();
      } else if (response.statusCode == 204) {
        print('You have no pills for Today');
        return [];
      } else {
        print(
            'Failed to load pills - Server responded with status code ${response.statusCode}');
        throw Exception('Failed to load pills');
      }
    } catch (e) {
      print('Failed to load pills: $e');
      throw Exception('Failed to load pills: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pill>>(
      future: fetchPills(),
      builder: (context, AsyncSnapshot<List<Pill>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('You don\'t have pills today'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pill = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PillCard(
                  pill: pill,
                ),
              );
            },
          );
        }
      },
    );
  }
}

class PillCard extends StatelessWidget {
  final Pill pill;

  const PillCard({
    required this.pill,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? parsedTime;
    try {
      if (pill.reminderTimes.contains('T')) {
        // For pillTime in full date-time format (e.g., yyyy-MM-dd'T'HH:mm:ss)
        parsedTime =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(pill.reminderTimes);
      } else {
        // For reminderTimes in time format (e.g., HH:mm)
        DateTime now = DateTime.now();
        List<String> timeParts = pill.reminderTimes.split(':');
        parsedTime = DateTime(now.year, now.month, now.day,
            int.parse(timeParts[0]), int.parse(timeParts[1]));
      }
    } catch (e) {
      // Handle invalid date format here, e.g., show an error message or log it
      print('Invalid date format for pill time: ${pill.reminderTimes}');
    }

    // Check if the pill status is 'TAKEN' (status == 1)
    bool isTaken = pill.status == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isTaken ? Colors.grey.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1),
            blurRadius: 8,
            spreadRadius: 0.1,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/crycat.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pill.pillName} (${pill.pillType})',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isTaken ? Colors.grey : Color(0xFFee6123),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pill.pillNote,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isTaken ? Colors.grey : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                color:
                                    isTaken ? Colors.grey : Color(0xFF00916E),
                                size: 19.0),
                            const SizedBox(width: 4),
                            Text(
                              parsedTime != null
                                  ? DateFormat('HH:mm').format(parsedTime)
                                  : pill.reminderTimes,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: isTaken ? Colors.grey : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.pending_actions_outlined,
                                color:
                                    isTaken ? Colors.grey : Color(0xFF00916E)),
                            const SizedBox(width: 4),
                            Text(
                              pill.pillTime,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: isTaken ? Colors.grey : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
