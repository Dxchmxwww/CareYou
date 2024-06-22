// // ignore: file_names
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
            'http://localhost:8000/pills/ShowTodayPillRemindersOfElderForCaregiverHome'),
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
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 85,
      child: Card(
          child: Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 1),
              blurRadius: 6.5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 67,
                height: 67,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/crycat.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 17),
                  Text(
                    'Captopril(Capsule)',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFee6123)),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'The red one in black package',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Color(0xFF00916E), size: 19.0),
                      SizedBox(width: 4),
                      Text(
                        '08.00',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black,
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
                              parsedTime != null
                                  ? DateFormat('HH:mm').format(parsedTime)
                                  : pill
                                      .reminderTimes, // Format the time or display original text
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.black,
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
      )),
    );
  }
}
