import 'package:flutter/material.dart';

class user_onboard_page extends StatefulWidget {
  const user_onboard_page();

  @override
  State<user_onboard_page> createState() => _HomepageState();
}

class _HomepageState extends State<user_onboard_page> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: 'UserBoarding',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          // Wrap SingleChildScrollView with Container
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF00916E), // Changed to solid color
          ),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 100.0, left: 20.0),
                        child: Image.asset(
                          'assets/images/plain_design.png',
                          width: 120,
                          height: 122,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text(
                          'CARE YOU',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 250.0),
                        child: Container(
                          width: double.infinity,
                          height: screenHeight - 450.0,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 310),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 320,
                          height: 320,
                          child: Image.asset(
                            'assets/images/DocDac.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          'LET\'S GET START',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 13.0),
                          child: Text(
                            'Please select who you are',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF8D8D8D),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30.0), // Adjusted top padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: 120, // Set width for Caregiver button
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        const Color(
                                            0xFF99D19C), // Color for Caregiver button
                                      ),
                                    ),
                                    child: Text(
                                      'Caregiver',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: 120, // Set width for Elder button
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        const Color(
                                            0xFF99D19C), // Color for Elder button
                                      ),
                                    ),
                                    child: Text(
                                      'Elder',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
