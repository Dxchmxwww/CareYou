import 'package:flutter/material.dart';

class CreatePillsType extends StatefulWidget {
  const CreatePillsType({Key? key}) : super(key: key);

  @override
  _CreatePillsTypeState createState() => _CreatePillsTypeState();
}

class _CreatePillsTypeState extends State<CreatePillsType> {
  List<String> pillTypes = [
    'capsule',
    'tablets',
    'gel',
    'lotion',
    'injection',
  ];
  String? selectedPillType;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Card(
        child: Container(
          width: screenWidth * 0.9,
          height: 50,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(15),
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
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 10.0, right: 4.0),
                child: Text(
                  'Pill Types',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00916E),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: pillTypes.map((type) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedPillType = type;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical:
                                  10, // Adjust vertical padding to accommodate the text
                              horizontal:
                                  10, // Adjust horizontal padding to accommodate the text
                            ),
                            minimumSize: const Size(
                                20, 30), // Set a minimum size for the button
                            backgroundColor: selectedPillType == type
                                ? const Color(0xFFF54900)
                                : const Color(0xFFD1D1D1),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 10.0,
                              fontFamily: 'Poppins',
                              color: selectedPillType == type
                                  ? const Color(0xFFFFFFFF)
                                  : const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
