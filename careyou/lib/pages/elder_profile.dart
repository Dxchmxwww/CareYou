import 'package:careyou/components/navbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:careyou/components/logOutButton.dart';

class elder_profile_page extends StatefulWidget {
  final String token;
  final String selectedRole;

  const elder_profile_page({required this.token, required this.selectedRole});

  @override
  State<elder_profile_page> createState() => _elderProfilePageState();
}

class _elderProfilePageState extends State<elder_profile_page> {
  bool isEditingUsername = false;
  bool isEditingPassword = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  String caregiverUsername = '';
  String email = '';
  String username = '';
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    print("elder_profile_page token here: ${widget.token}"); 
    fetchElderlyData();
  }

  
  bool _validateToken(String token) {
    // Add your token validation logic here
    // Return true if the token is valid, false otherwise
    return true;
  }

// Helper method to show an authentication error dialog
  void _showAuthenticationErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Authentication Error'),
          content: Text('You are not logged in. Please log in and try again.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Optionally, navigate to the login page
                // Navigator.pushReplacementNamed(context, '/loginPage');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchElderlyData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/profiles/Elderly'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response Data: $data');
        setState(() {
          username = data['username'];
          email = data['email'];
          caregiverUsername = data['your_caregiver'];
          currentDate = data['currentDate'];
          usernameController.text = username;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Handle unauthorized access
        print('Unauthorized: Token expired or invalid');
        _showAuthenticationErrorDialog(context);
        print('Authentication error: ${response.statusCode}');
        // Example: Redirect to login page or show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Unauthorized'),
              content: Text('Please login again.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    // Redirect to login page or perform logout
                    // Example: Navigator.pushNamed(context, '/login');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle error
        print('Failed to load  kaaaa: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch data. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void toggleEditMode(String field) {
    setState(() {
      isEditingUsername = field == 'username';
      isEditingPassword = field == 'password';
    });
  }

  void saveData() {
    if (isEditingUsername) {
      String newUsername = usernameController.text.trim();
      if (newUsername.isNotEmpty) {
        updateUsername(newUsername);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Username cannot be empty.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else if (isEditingPassword) {
      String oldPassword = oldPasswordController.text.trim();
      String newPassword = newPasswordController.text.trim();
      if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
        updatePassword(oldPassword, newPassword);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Both old password and new password are required.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8000/profiles/EditUsername'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'newUsername': newUsername}),
      );

      if (response.statusCode == 200) {
        setState(() {
          username = newUsername;
          isEditingUsername = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Success',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text('Username updated successfully.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 400) {
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Unknown error';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to update username: $errorMessage'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to update username: ${response.statusCode}');
        throw Exception('Failed to update username');
      }
    } catch (e) {
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update username. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8000/profiles/EditPassword'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isEditingPassword = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Password updated successfully.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 400) {
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Unknown error';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to update password: $errorMessage'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to update password: ${response.statusCode}');
        throw Exception('Failed to update password');
      }
    } catch (e) {
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update password. Please try again later.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: 'Elder Profile',
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
                Positioned(
                  top: 60,
                  right: 20,
                  child: LogoutButton(),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 130.0, left: 50.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hello, ${username.length > 10 ? username.substring(0, 10) : username}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.0, left: 50.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Today is $currentDate',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Container(
                        width: double.infinity,
                        height: screenHeight - 200.0,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  'YOUR CAREGIVER',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF00916E),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Center(
                                child: Text(
                                  caregiverUsername,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 26,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.0),
                              Center(
                                child: Text(
                                  'Your Email',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF00916E),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Center(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Username: ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF00916E),
                                      ),
                                    ),
                                    if (isEditingUsername)
                                      Expanded(
                                        child: TextField(
                                          controller: usernameController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter username',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: Text(
                                          usernameController.text,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    if (!isEditingUsername)
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Color(0xFFF54900)),
                                        onPressed: () =>
                                            toggleEditMode('username'),
                                      ),
                                  ],
                                ),
                              ),
                              if (isEditingUsername)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(40.0, 20.0, 40.0,
                                      0.0), // Adjust the top padding here
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: saveData,
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color(0xFFF54900),
                                        ),
                                      ),
                                      child: Text(
                                        'SAVE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 15.0),
                              if (!isEditingPassword)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Password: ',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF00916E),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${'*' * 8}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Color(0xFFF54900)),
                                        onPressed: () =>
                                            toggleEditMode('password'),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: 10.0),
                              if (isEditingPassword)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Old Password: ',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF00916E),
                                        ),
                                      ),
                                      TextField(
                                        controller: oldPasswordController,
                                        decoration: InputDecoration(
                                          hintStyle:
                                              TextStyle(color: Colors.black),
                                        ),
                                        obscureText: true,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'New Password: ',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF00916E),
                                        ),
                                      ),
                                      TextField(
                                        controller: newPasswordController,
                                        decoration: InputDecoration(
                                          hintStyle:
                                              TextStyle(color: Colors.black),
                                        ),
                                        obscureText: true,
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: 40.0),
                              if (isEditingPassword)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40.0),
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: saveData,
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Color(0xFFF54900)),
                                      ),
                                      child: Text(
                                        'SAVE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavBar(token: widget.token, initialIndex: 4, selectedRole: widget.selectedRole),
      ),
    );
  }
}