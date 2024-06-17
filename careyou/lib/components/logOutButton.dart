// ignore_for_file: use_build_context_synchronously, avoid_print, file_names
import 'package:flutter/material.dart';

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
                    // try {
                    //   await FirebaseAuth.instance.signOut();
                    //   await _handleGoogleSignOut(context);

                    //   // After signing out, navigate back to the login screen or any other desired screen
                    //   // For example, you can navigate back to the home screen
                    //   Navigator.pushAndRemoveUntil(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => const Homepage()),
                    //     (Route<dynamic> route) => false,
                    //   );
                    // } catch (e) {
                    //   print('Error signing out: $e');
                    // }
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

  Future<void> _handleGoogleSignOut(BuildContext context) async {
    // try {
    //   final GoogleSignIn googleSignIn = GoogleSignIn();
    //   await googleSignIn.signOut();
    //   // Perform any other sign-out related operations here
    // } catch (e) {
    //   print(e);
    // }
  }
}
