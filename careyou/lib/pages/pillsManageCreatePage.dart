import 'package:careyou/components/createPillsTime.dart';
import 'package:careyou/components/createSetReminder.dart';
import 'package:flutter/material.dart';
import 'package:careyou/components/createPillsCard.dart';
import 'package:careyou/components/createPillsType.dart';

class PillsmanageCreatePage extends StatefulWidget {
  const PillsmanageCreatePage({super.key});

  @override
  State<PillsmanageCreatePage> createState() => _PillsmanageCreatePageState();
}

class _PillsmanageCreatePageState extends State<PillsmanageCreatePage> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set scaffold background color
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // Adjust as needed
        child: Container(
          color:
              const Color(0xFF00916E), // Set background color for the title bar
          padding: const EdgeInsets.only(top: 20), // Adding top padding of 20
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              "Pills management",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.white, // Text color for the title
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20), // Add top padding here
                    child: CreatePillsCard(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10), // Add top padding here
                    child: CreatePillsType(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10), // Add top padding here
                    child: CreatePillsTime(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10), // Add top padding here
                    child: CreateSetReminder(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed logic here
        },
        backgroundColor: const Color(0xFF00916E),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.save,
          size: 30,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // bottomNavigationBar: const NavBar(),
    );
  }
}
