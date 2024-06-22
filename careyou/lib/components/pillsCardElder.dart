import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Pill {
  final int? PillReminder_id;
  final String pillName;
  final String pillType;
  final String? pillNote;
  final String pillTime;
  final String reminderTimes;
  final String reminderDates;
  bool taken;

  Pill({
    required this.PillReminder_id,
    required this.pillName,
    required this.pillType,
    this.pillNote,
    required this.pillTime,
    required this.reminderTimes,
    required this.reminderDates,
    required this.taken,
  });

  factory Pill.fromJson(Map<String, dynamic> json) {
    return Pill(
      PillReminder_id: json['PillReminder_id'],
      pillName: json['pill_name'] ?? '', // Provide default value or handle null
      pillType: json['pill_type'] ?? '', // Provide default value or handle null
      pillNote: json['pill_note'], // Can be null, no need for default
      pillTime: json['pill_Time'] ?? '', // Provide default value or handle null
      reminderTimes:
          json['reminder_times'] ?? '', // Provide default value or handle null
      reminderDates: json['reminder_dates'] ?? '', //
      taken: false, // Initialize as false
    );
  }
}

class PillsCardElder extends StatefulWidget {
  final String token;

  const PillsCardElder({required this.token});

  @override
  _PillsCardElderState createState() => _PillsCardElderState();
}

class _PillsCardElderState extends State<PillsCardElder> {
  late Timer _timer;
  List<Pill> _pills = [];

  @override
  void initState() {
    super.initState();
    // Fetch pills initially
    fetchAndSortPills();

    // Setup periodic data refresh
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchAndSortPills();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  Future<void> fetchAndSortPills() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/pills/ShowTodayPillRemailderListForElderly'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Pill> pills = data.map((json) => Pill.fromJson(json)).toList();

        // Sort pills by reminderTimes
        pills.sort((a, b) => sortPillsByReminderTime(a, b));

        setState(() {
          _pills = pills;
        });
      } else if (response.statusCode == 204) {
        print('You have no pills for Today');
        setState(() {
          _pills = [];
        });
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

  int sortPillsByReminderTime(Pill a, Pill b) {
    DateTime timeA = parseReminderTime(a.reminderTimes);
    DateTime timeB = parseReminderTime(b.reminderTimes);
    return timeA.compareTo(timeB);
  }

  DateTime parseReminderTime(String reminderTime) {
    try {
      if (reminderTime.contains('T')) {
        return DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(reminderTime);
      } else {
        DateTime now = DateTime.now();
        List<String> timeParts = reminderTime.split(':');
        return DateTime(now.year, now.month, now.day, int.parse(timeParts[0]),
            int.parse(timeParts[1]));
      }
    } catch (e) {
      print('Invalid date format for reminderTime: $reminderTime');
      return DateTime.now(); // Default to current time if parsing fails
    }
  }

  String getImageForMedicationType(String pillType) {
    switch (pillType.toLowerCase()) {
      case 'capsule':
        return 'assets/images/capsule.png';
      case 'gel':
        return 'assets/images/gel.png';
      case 'injection':
        return 'assets/images/injection.png';
      case 'lotion':
        return 'assets/images/lotion.png';
      case 'tablet':
        return 'assets/images/tablets.png';
      default:
        return 'none';
    }
  }

  String getGrayImageForMedicationType(String pillType) {
    switch (pillType.toLowerCase()) {
      case 'capsule':
        return 'assets/images/g_capsule.png';
      case 'gel':
        return 'assets/images/g_gel.png';
      case 'injection':
        return 'assets/images/g_injection.png';
      case 'lotion':
        return 'assets/images/g_lotion.png';
      case 'tablet':
        return 'assets/images/g_tablets.png';
      default:
        return 'none';
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
            token: widget.token,
            pill: pill,
            getImageForMedicationType: getImageForMedicationType,
            getGrayImageForMedicationType: getGrayImageForMedicationType,
            onTake: (Pill pill) {
              // Define the action to take when the 'Take' button is pressed
              print('Pill taken: ${pill.pillName}');
              print('Pill taken ID: ${pill.PillReminder_id}');
              print('Pill taken Remainder Time: ${pill.reminderTimes}');
              // Optionally, you can update the UI or make API calls here
            },
          ),
        );
      },
    );
  }
}

class PillCard extends StatelessWidget {
  final Pill pill;
  final Function(Pill) onTake;
  final String Function(String) getImageForMedicationType;
  final String Function(String) getGrayImageForMedicationType;
  final String token;

  const PillCard({
    required this.pill,
    required this.onTake,
    required this.getImageForMedicationType,
    required this.getGrayImageForMedicationType,
    required this.token,
  });

  void updateStatusInDatabase(String reminderTimes, int? pillReminderId) async {
    if (pillReminderId == null) {
      print('Error: pillReminderId is null');
      return;
    }

    await updatePillStatus(reminderTimes, pillReminderId, token);
  }

  Future<void> updatePillStatus(
      String? reminderTimes, int? pillReminderId, String token) async {
    String url = 'http://localhost:8000/pills/UpdatePillStatus';

    Map<String, dynamic> body = {
      'PillReminder_id': pillReminderId,
      'reminder_times': reminderTimes,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Pill status updated and moved to Taken pill successfully');
        pill.taken = true;
      } else {
        print(
            'Failed to update pill status. Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating pill status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? parsedTime;
    try {
      if (pill.reminderTimes.contains('T')) {
        parsedTime =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").parse(pill.reminderTimes);
      } else {
        DateTime now = DateTime.now();
        List<String> timeParts = pill.reminderTimes.split(':');
        parsedTime = DateTime(now.year, now.month, now.day,
            int.parse(timeParts[0]), int.parse(timeParts[1]));
      }
    } catch (e) {
      print('Invalid date format for pill time: ${pill.reminderTimes}');
    }

    if (parsedTime == null || parsedTime.isBefore(DateTime.now())) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0), // Add margin here
        child: Card(
          elevation: 0,
          color: const Color.fromARGB(255, 238, 238, 238),
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
                          image: AssetImage(
                              getGrayImageForMedicationType(pill.pillType)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warning,
                                        color: Colors.orange, size: 30),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${pill.pillName}',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            '(${pill.pillType})',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      size: 19.0),
                                  SizedBox(width: 4),
                                  Text(
                                    parsedTime != null
                                        ? DateFormat('HH:mm').format(parsedTime)
                                        : pill.reminderTimes,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.pending_actions_outlined,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      size: 19.0),
                                  SizedBox(width: 4),
                                  Text(
                                    pill.pillTime,
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
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  color: Color.fromARGB(255, 174, 174, 174),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  Colors.white, // Set background color to white
                              title: Row(
                                children: [
                                  Icon(Icons.warning,
                                      color:
                                          Colors.orange), // Consideration icon
                                  SizedBox(width: 10),
                                  Text('Confirm Medicine Taken'),
                                ],
                              ),
                              content: Text(
                                  'Are you sure you want to mark this medicine as taken?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'OK',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    onTake(pill);
                                    updateStatusInDatabase(pill.reminderTimes,
                                        pill.PillReminder_id);
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Taken ?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (pill.taken) {
      return SizedBox.shrink(); // If pill is taken, hide the card
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
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
          color: Colors.white,
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
                          image: AssetImage(
                              getImageForMedicationType(pill.pillType)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${pill.pillName}',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              Text(
                                                '(${pill.pillType})',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: Color(0xFF00916E), size: 19.0),
                                      SizedBox(width: 4),
                                      Text(
                                        parsedTime != null
                                            ? DateFormat('HH:mm')
                                                .format(parsedTime)
                                            : pill.reminderTimes,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.pending_actions_outlined,
                                          color: Color(0xFF00916E), size: 19.0),
                                      SizedBox(width: 4),
                                      Text(
                                        pill.pillTime,
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
                              SizedBox(width: 15),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  color: Color(0xFF00916E),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  Colors.white, // Set background color to white
                              title: Row(
                                children: [
                                  Icon(Icons.warning,
                                      color:
                                          Colors.orange), // Consideration icon
                                  SizedBox(width: 10),
                                  Text('Confirm Midicine Taken'),
                                ],
                              ),
                              content: Text(
                                  'Are you sure you want to mark this medicine as taken?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'OK',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    onTake(pill);
                                    updateStatusInDatabase(pill.reminderTimes,
                                        pill.PillReminder_id);
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Take',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white,
                        ),
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
}
