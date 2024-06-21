import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pill {
  final String pillName;
  final String pillType;
  final String pillNote;
  final String pillTime; // Renamed to pillTime for backward compatibility
  final int? frequency; // Changed to nullable int
  bool taken; // Track whether pill has been taken

  Pill({
    required this.pillName,
    required this.pillType,
    required this.pillNote,
    required this.pillTime,
    required this.frequency,
    this.taken = false, // Default to not taken
  });

  factory Pill.fromJson(Map<String, dynamic> json) {
    return Pill(
      pillName: json['pill_name'],
      pillType: json['pill_type'],
      pillNote: json['pill_note'],
      pillTime: json['pill_Time'], // Adjust the key based on your API response
      frequency: json['frequency'] ?? 0, // Nullable int
      taken: json['taken'] ?? false,
    );
  }
}

class PillsCard extends StatelessWidget {
  final String token;
  final bool isEditMode; // Add isEditMode to constructor

  const PillsCard({required this.token, required this.isEditMode});

  Future<List<Pill>> fetchPills() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/pills/ShowPillRemailderListForCaregiver'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 201) {
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
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: PillsCard2(
                  pill: pill,
                  getImageForMedicationType: getImageForMedicationType,
                  isEditMode: isEditMode,
                  token: token, // Pass the token
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
  final bool isEditMode;
  final String token; // Add token to the constructor
  final String Function(String)
      getImageForMedicationType; // Pass the function as a parameter

  const PillsCard2(
      {required this.pill,
      required this.isEditMode,
      required this.token,
      required this.getImageForMedicationType});

  @override
  _PillsCard2State createState() => _PillsCard2State();
}

class _PillsCard2State extends State<PillsCard2> {
  bool isDeleted = false;

  @override
  Widget build(BuildContext context) {
    if (isDeleted) {
      return SizedBox.shrink(); // Return an empty SizedBox if deleted
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: widget.isEditMode ? screenHeight * 0.14 : screenHeight * 0.12,
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
                        borderRadius: BorderRadius.circular(5),
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
                        screenHeight * 0.03, // top padding value
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
                          Text(
                            widget.pill.pillNote,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenWidth * 0.04, // left
                      screenHeight * 0.03, // top padding value
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
              if (widget.isEditMode)
                Positioned(
                  bottom: 10,
                  right: 18,
                  child: Container(
                    height: 20, // Set desired height here
                    child: ElevatedButton(
                      onPressed: () {
                        // Show delete confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                "Confirm Deletion",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: const Text(
                                "Are you sure you want to delete this medication?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
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
                                            255,
                                            218,
                                            218,
                                            218), // background color
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
                                              30), // button border radius
                                        ),
                                      ),
                                      child: const Text("Cancel"),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Colors.red, // background color
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
                                              30), // button border radius
                                        ),
                                      ),
                                      child: const Text("Delete"),
                                      onPressed: () {
                                        setState(() {
                                          isDeleted = true;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
