import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pill {
  final int pillReminderId; // Added field
  final String pillName;
  final String pillType;
  final String pillNote;
  final String pillTime;
  final String reminderTimes;
  bool taken;

  Pill({
    required this.pillReminderId,
    required this.pillName,
    required this.pillType,
    required this.pillNote,
    required this.pillTime,
    required this.reminderTimes,
    this.taken = false,
  });

  factory Pill.fromJson(Map<String, dynamic> json) {
    return Pill(
      pillReminderId:
          json['pillReminderId'], // Adjust according to your API response
      pillName: json['pill_name'],
      pillType: json['pill_type'],
      pillNote: json['pill_note'],
      pillTime: json['pill_Time'],
      reminderTimes: json['reminder_times'],
      taken: json['taken'] ?? false,
    );
  }
}

class PillsCardElder extends StatelessWidget {
  final String token;

  const PillsCardElder({required this.token});

  Future<List<Pill>> fetchPills() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/pills/ShowTodayPillRemailderListForElderly'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pill.fromJson(json)).toList();
      } else if (response.statusCode == 204) {
        print('You have no pills for Today nakab');
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

  // Function to get image path based on medication type
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
                  getImageForMedicationType: getImageForMedicationType,
                  onTake: (Pill pill) {
                    // Define the action to take when the 'Take' button is pressed
                    print('Pill taken: ${pill.pillName}');
                    // Optionally, you can update the UI or make API calls here
                  },
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
  final Function(Pill) onTake; // Callback function when pill is taken
  final String Function(String)
      getImageForMedicationType; // Pass the function as a parameter

  const PillCard({
    required this.pill,
    required this.onTake,
    required this.getImageForMedicationType,
  });

  void updateStatusInDatabase(int pillReminderId, String reminderTimes) async {
    String url = 'http://localhost:8000/pills/UpdatePillStatus';

    // Replace with your authentication token if needed
    String token = 'YOUR_AUTH_TOKEN';

    // JSON body to send to the server
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
        print('Pill status updated successfully');
        // Optionally, update the local UI state to reflect the pill as taken
      } else {
        print('Failed to update pill status. Error: ${response.statusCode}');
        // Handle failure based on response
      }
    } catch (e) {
      print('Error updating pill status: $e');
      // Handle network or other errors
    }
  }

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

    if (parsedTime == null || parsedTime.isBefore(DateTime.now())) {
      // If pill time cannot be parsed or has passed, show a different UI (e.g., red card)
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors
              .red, // Example of a red card for missed pills or invalid dates
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            parsedTime == null
                ? 'Invalid pill time format'
                : 'Missed pill: ${pill.pillName}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (pill.taken) {
      // If pill is taken, hide the card
      return SizedBox.shrink(); // This will render nothing (hides the card)
    } else {
      // Normal pill card display
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
                          Text(
                            '${pill.pillName} (${pill.pillType})',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFee6123),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pill.pillNote,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: Color(0xFF00916E), size: 19.0),
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
                                  color: Color(0xFF00916E)),
                              const SizedBox(width: 4),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Call the onTake callback function when 'Take' is pressed
                    // onTake(pill);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            "Confirm Medication",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: const Text(
                            "Have you taken your medicine?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: const Color.fromARGB(
                                        255, 218, 218, 218), // background color
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12, // text size
                                      fontWeight:
                                          FontWeight.bold, // text weight
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15), // button padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // button border radius
                                    ),
                                  ),
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color.fromARGB(
                                        255, 66, 169, 144), // background color
                                    textStyle: const TextStyle(
                                      fontSize: 12, // text size
                                      fontWeight:
                                          FontWeight.bold, // text weight
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15), // button padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // button border radius
                                    ),
                                  ),
                                  child: const Text("Yes, I took it"),
                                  onPressed: () {
                                    updateStatusInDatabase(pill.pillReminderId,
                                        pill.reminderTimes);
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF42A990)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topLeft: Radius.zero,
                          topRight: Radius.zero,
                        ),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(vertical: 12.5),
                    ), // Adjust padding here
                  ),
                  child: const Text(
                    'Take',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
