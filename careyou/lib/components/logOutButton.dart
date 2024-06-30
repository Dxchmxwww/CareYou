import 'dart:io';

import 'package:careyou/pages/user_onboard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _showConfirmationDialog(context);
      },
      child: const Text(
        'Log Out',
        style: TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
          color: Colors.white,
          fontFamily: 'poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing on tap outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            children: [
              Icon(
                Icons.logout,
                size: 40.0,
                color: Color.fromARGB(255, 240, 145,
                    22), // Customize the color of the icon as needed
              ),
              SizedBox(height: 8.0), // Add some spacing between icon and text
              Text(
                'Log Out',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.grey.shade300),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(
                    width: 8), // Adjust spacing between buttons if needed
                TextButton(
                  onPressed: () async {
                    Navigator.of(context)
                        .pop(); // Close the dialog before making the network request
                    await _handleLogout(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 255, 17, 0)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.0,
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  String getServerUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:8000'; // iOS simulator
    } else{
      return 'http://localhost:8000';
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final url = '${getServerUrl()}/auth/logout';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Navigate back to the login screen or home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const user_onboard_page()), // Change this to your login screen
        (Route<dynamic> route) => false,
      );
    } else {
      // Handle error
      print('Error logging out: ${response.statusCode}');
    }
  }
}
