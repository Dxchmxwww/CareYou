

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Pill {
  final String pillName;
  final String pillType;
  final String pillNote;
  final String pillTime;
  final String reminderTimes;
  final int? status; // New field for status

  Pill({
    required this.pillName,
    required this.pillType,
    required this.pillNote,
    required this.pillTime,
    required this.reminderTimes,
    required this.status, // Initialize with s
  });

  factory Pill.fromJson(Map<String, dynamic> json) {
    return Pill(
      pillName: json['pill_name'],
      pillType: json['pill_type'],
      pillNote: json['pill_note'],
      pillTime: json['pill_Time'],
      reminderTimes: json['reminder_times'],
      status: json['status'],
    );
  }
}

class PillsCardCareGiver extends StatefulWidget {
  final String token;

  const PillsCardCareGiver({required this.token});

  @override
  _PillsCardCareGiverState createState() => _PillsCardCareGiverState();
}

class _PillsCardCareGiverState extends State<PillsCardCareGiver> {
  List<Pill> _pills = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchPillsPeriodically();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _fetchPillsPeriodically() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchPills();
    });
  }

  Future<void> _fetchPills() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/pills/ShowPillRemailderListForCaregiver'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Backend Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Data from Backend: $data');

        // Filter pills scheduled for today
        DateTime now = DateTime.now();
        List<Pill> todayPills = data
            .map((json) => Pill.fromJson(json))
            .where((pill) => isSameDay(pill.reminderTimes, now))
            .toList();

        // Sort pills by reminderTimes
        todayPills.sort((a, b) =>
            _parseTime(a.reminderTimes).compareTo(_parseTime(b.reminderTimes)));

        setState(() {
          _pills = todayPills;
        });
      } else if (response.statusCode == 204) {
        print('You have no pills for Today');
        setState(() {
          _pills = [];
        });
      } else {
        print(
            'Failed to load pills - Server responded with status code ${response.statusCode}');
        // Handle error as needed
      }
    } catch (e) {
      print('Failed to load pills: $e');
      throw Exception('Failed to load pills: $e');
    }
  }

  DateTime _parseTime(String reminderTimes) {
    try {
      if (reminderTimes.contains('T')) {
        // For reminderTimes in full date-time format (e.g., yyyy-MM-dd'T'HH:mm:ss)
        return DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(reminderTimes);
      } else {
        // For reminderTimes in time format (e.g., HH:mm)
        DateTime now = DateTime.now();
        List<String> timeParts = reminderTimes.split(':');
        return DateTime(now.year, now.month, now.day, int.parse(timeParts[0]),
            int.parse(timeParts[1]));
      }
    } catch (e) {
      // Handle invalid date format here, e.g., show an error message or log it
      print('Invalid date format for pill time: $reminderTimes');
      return DateTime.now(); // Return current time as fallback
    }
  }

  bool isSameDay(String reminderTimes, DateTime date) {
    try {
      if (reminderTimes.contains('T')) {
        // For reminderTimes in full date-time format (e.g., yyyy-MM-dd'T'HH:mm:ss)
        DateTime pillDateTime =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(reminderTimes);
        return pillDateTime.year == date.year &&
            pillDateTime.month == date.month &&
            pillDateTime.day == date.day;
      } else {
        // For reminderTimes in time format (e.g., HH:mm)
        List<String> timeParts = reminderTimes.split(':');
        DateTime pillDateTime = DateTime(date.year, date.month, date.day,
            int.parse(timeParts[0]), int.parse(timeParts[1]));
        return true; // Assuming the time format implies today
      }
    } catch (e) {
      // Handle invalid date format here, e.g., show an error message or log it
      print('Invalid date format for pill time: $reminderTimes');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _pills.length,
      itemBuilder: (context, index) {
        final pill = _pills[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: PillCard(
            pill: pill,
          ),
        );
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

    bool isTaken = pill.status == 1;

    String imagePath = 'assets/images/';
    if (isTaken) {
      switch (pill.pillType.toLowerCase()) {
        case 'capsule':
          imagePath += 'g_capsule.png';
          break;
        case 'gel':
          imagePath += 'g_gel.png';
          break;
        case 'tablet':
          imagePath += 'g_tablets.png';
          break;
        case 'injection':
          imagePath += 'g_capsule.png';
          break;
        case 'lotion':
          imagePath += 'g_lotion.png';
          break;
        default:
          imagePath += 'default.png'; // Handle default case
      }
    } else {
      switch (pill.pillType.toLowerCase()) {
        case 'capsule':
          imagePath += 'capsule.png';
          break;
        case 'gel':
          imagePath += 'gel.png';
          break;
        case 'tablet':
          imagePath += 'tablets.png';
          break;
        case 'injection':
          imagePath += 'capsule.png';
          break;
        case 'lotion':
          imagePath += 'lotion.png';
          break;
        default:
          imagePath += 'default.png'; // Handle default case
      }
    }

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
        color: isTaken
            ? const Color.fromARGB(206, 240, 240, 240)
            : Color.fromARGB(255, 255, 255, 255),
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
                      image: DecorationImage(
                        image: AssetImage(imagePath),
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
                            color: isTaken
                                ? const Color.fromARGB(255, 0, 0, 0)
                                : Color(0xFFee6123),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                color: isTaken
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Color(0xFF00916E),
                                size: 19.0),
                            const SizedBox(width: 4),
                            Text(
                              '${pill.pillTime}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isTaken
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Color(0xFFee6123),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.pending_actions_outlined,
                                color: isTaken
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Color(0xFF00916E)),
                            const SizedBox(width: 4),
                            Text(
                              isTaken ? 'TAKED' : pill.pillTime,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }
}
