// ignore: file_names
import 'package:flutter/material.dart';

// class AppointmentCard extends StatelessWidget {
//   const AppointmentCard({
//     required Key key, // Fix: Added missing Key parameter
//   }) : super(key: key); // Fix: Initialize key in super constructor

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate device screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      child: Card(
        color: const Color(0xFF42A990),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Grandmom's Today Appointment ",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: screenWidth * 0.9,
                  height: 73,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Icon(
                              Icons.access_time,
                              color: Color(0xFF42A0A9),
                              size: 19.0,
                            ), // Clock icon
                          ),
                          SizedBox(width: 10),
                          Text(
                            "08.00 - 12.00",
                            style:
                                TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 55.0),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF42A0A9),
                              size: 19.0,
                            ), // Location icon
                          ),
                          SizedBox(width: 10),
                          Text(
                            "BPK 1 Hospital",
                            style:
                                TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                      SizedBox(height: 7),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF42A0A9),
                              size: 19.0,
                            ), // Info icon
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Cardiology consult",
                            style:
                                TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ],
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
