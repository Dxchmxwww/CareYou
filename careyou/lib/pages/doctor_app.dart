import 'package:flutter/material.dart';
import 'package:careyou/widgets/navbar.dart';


class DocApp extends StatelessWidget {
  const DocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(106),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF00916E),
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Doctor Appointment',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                child: Text(
                  'Your Appointment',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00916E),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  'Today is June 24, 2024',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00916E),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 30, left: 20, right: 20),
                  child: Column(
                    children: [
                      // AppCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: NavBar(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }
}
