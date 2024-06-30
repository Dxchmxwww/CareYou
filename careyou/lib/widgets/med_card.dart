import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pill {
  final int id;
  final String pillName;
  final String pillType;
  final String pillNote;
  final String pillTime;
  final int? frequency;
  bool taken;

  Pill({
    required this.id,
    required this.pillName,
    required this.pillType,
    required this.pillNote,
    required this.pillTime,
    required this.frequency,
    this.taken = false,
  });

  factory Pill.fromJson(Map<String, dynamic> json) {
    return Pill(
      id: json['PillReminder_id'] ?? 0, // Adjust based on your API response
      pillName: json['pill_name'],
      pillType: json['pill_type'],
      pillNote: json['pill_note'],
      pillTime: json['pill_Time'],
      frequency: json['frequency'] ?? 0,
      taken: json['taken'] ?? false,
    );
  }
}

class MedCard extends StatelessWidget {
  final String token;

  const MedCard({required this.token});
  
  String getServerUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000'; // iOS simulator
    } else{
      return 'http://localhost:8000';
    }
  }

  Future<List<Pill>> fetchPills() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${getServerUrl()}/pills/ShowPillRemindersListForElderlyPillBoxs'),
        headers: {'Content-Type': 'application/json',
                'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pill.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
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
          return Center(child: Text('You don\'t have medicine today'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pill = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: PillsCard2(
                  pill: pill,
                  getImageForMedicationType: getImageForMedicationType,
                  token: token,
                ),
              );
            },
          );
        }
      },
    );
  }
}

class PillsCard2 extends StatefulWidget {
  final Pill pill;
  final String token;
  final String Function(String) getImageForMedicationType;

  const PillsCard2({
    required this.pill,
    required this.token,
    required this.getImageForMedicationType,
  });

  @override
  _PillsCard2State createState() => _PillsCard2State();
}

class _PillsCard2State extends State<PillsCard2> {
  bool isDeleted = false;

  @override
  Widget build(BuildContext context) {
    if (isDeleted) {
      return SizedBox.shrink();
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
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
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Container(
                      width: screenWidth * 0.18,
                      height: screenWidth * 0.18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage(widget
                              .getImageForMedicationType(widget.pill.pillType)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.04, // left
                        screenHeight * 0.00, // top padding value
                        screenWidth * 0.04, // right
                        0, // bottom
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.pill.pillName} (${widget.pill.pillType})',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00916E),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.04, // left
                      screenHeight * 0.00, // top padding value
                      screenWidth * 0.04, // right
                      0, // bottom
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                color: const Color(0xFF00916E), size: 20),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              '${widget.pill.frequency} times/day',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Row(
                          children: [
                            Icon(Icons.pending_actions_outlined,
                                color: const Color(0xFF00916E), size: 20),
                            SizedBox(width: screenWidth * 0.01),
                            Text(
                              '${widget.pill.pillTime}',
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
            ],
          ),
        ),
      ),
    );
  }
}