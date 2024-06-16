import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  final String selectedRole; // Add role parameter

  const SignUpPage({required this.selectedRole}); // Require role parameter

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _elderEmailController = TextEditingController();
  final _relationController = TextEditingController();
  String _email = '';
  String _password = '';
  String _username = '';
  String _elderEmail = '';
  String _relation = '';

  Future<void> _registerUser() async {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _username,
          'password': _password,
          'email': _email,
          'role': widget.selectedRole,
          'yourelderly_email': _elderEmail,
          'yourelderly_relation': _relation,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('User registered successfully');
        Navigator.pushNamed(context, '/login');
      } else if (response.statusCode == 409) {
        _showErrorDialog('The elderly user already has a caregiver assigned.');
      } else if (response.statusCode == 404) {
        _showErrorDialog('Elderly user not found with provided email.');
      } else {
        // Handle other status codes if needed
        _showErrorDialog('Error: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: 'Sign up',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF00916E),
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
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 0.0),
                        child: Text(
                          'Creating Account',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 180.0),
                        child: Container(
                          width: double.infinity,
                          height: screenHeight - 430.0,
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
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 340),
                        child: Container(
                          width: 280,
                          height: 290,
                          child: Image.asset(
                            'assets/images/BoardBrad.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 570),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email*',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF00916E),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.contains('@')) {
                                      return null;
                                    } else {
                                      return 'Please enter a valid email address';
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _email = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Username*',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF00916E),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'Please set username';
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _username = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password*',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF00916E),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'Please enter your password';
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _password = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 25),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState != null &&
                                        _formKey.currentState!.validate()) {
                                      _showPinDialog();
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      const Color(0xFF00916E),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                RichText(
                                  text: TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Log in',
                                        style: TextStyle(
                                          color: Color(0xFF00916E),
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamed(
                                                context, '/login');
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  void _showPinDialog() {
    if (widget.selectedRole == 'Elderly') {
      _registerUser();
      return; // Exit early without showing the dialog
    }
    // Create a new GlobalKey<FormState> for the dialog form
    final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(40),
          content: Form(
            key: _dialogFormKey, // Use the new GlobalKey here
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: SvgPicture.asset(
                    'assets/images/partner.svg',
                    color: Color(
                        0xFF00916E), // Use the asset path directly from pubspec.yaml
                    width: 80,
                    height: 80,
                  ),
                ),
                Text(
                  'Elder Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _elderEmailController,
                  decoration: InputDecoration(
                    labelText: "Elder's Email*",
                    labelStyle: TextStyle(
                      color: Color(0xFF00916E),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00916E)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00916E)),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.contains('@')) {
                      return null;
                    } else {
                      return 'Please enter a valid email address';
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      _elderEmail = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _relationController,
                  decoration: InputDecoration(
                    labelText: "Relationship*",
                    labelStyle: TextStyle(
                      color: Color(0xFF00916E),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00916E)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00916E)),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return null;
                    } else {
                      return 'Please enter the relationship';
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      _relation = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF00916E)),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  if (_dialogFormKey.currentState != null &&
                      _dialogFormKey.currentState!.validate()) {
                    _registerUser();
                    Navigator.pop(context); // Close the dialog
                  }
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF00916E)),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
