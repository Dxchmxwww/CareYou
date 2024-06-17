import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class caregiver_profile_page extends StatefulWidget {
  final String token;
  
  const caregiver_profile_page({required this.token});


  @override
  State<caregiver_profile_page> createState() => _HomepageState();
}

class _HomepageState extends State<caregiver_profile_page> {
  bool isEditingUsername = false;
  bool isEditingPassword = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  String elderlyUsername = '';
  String elderlyRelation = '';
  String email = '';
  String username = '';
  String currentDate = '';

  TextEditingController _elderEmailController = TextEditingController();
  TextEditingController _relationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCaregiverData();
  }

  Future<void> fetchCaregiverData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/profiles/Caregiver'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['caregiver']['username'];
          email = data['caregiver']['email'];
          currentDate = data['currentDate'];
          // Check if 'yourelderly_relation' exists
          if (data['caregiver'].containsKey('yourelderly_relation')) {
            elderlyRelation = data['caregiver']['yourelderly_relation'];
          } else {
            elderlyRelation = ''; // Set to empty if not found
          }
        });
      } else {
        // Handle error
        print('Failed to load data: ${response.statusCode}');
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
      if (field == 'username') {
        if (!isEditingUsername) {
          // When entering edit mode, set the controller text to the current username
          usernameController.text = username;
        }
        isEditingUsername = !isEditingUsername;
      } else if (field == 'password') {
        isEditingPassword = !isEditingPassword;
      }
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

  void addElder() async {
    String elderEmail = _elderEmailController.text.trim();
    String relation = _relationController.text.trim();

    if (elderEmail.isNotEmpty && relation.isNotEmpty) {
      try {
        // Make POST request to backend API to add elderly
        var response = await http.post(
          Uri.parse('http://localhost:8000/profiles/AddElderly'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'Bearer ${widget.token}', // Replace with actual token
          },
          body: jsonEncode(<String, String>{
            'elderEmail': elderEmail,
            'relation': relation,
          }),
        );

        // if (response.statusCode == 200) {
        //   // Elderly added successfully
        //   ElderModel newElder = ElderModel(relation: relation);

        //   // Update UI
        //   setState(() {
        //     elders.add(newElder.toMap()); // Adjusted to use toMap()
        //     _elderEmailController.clear();
        //     _relationController.clear();
        //   });
        // } else {
        //   // Show error message if request failed
        //   showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         backgroundColor: Colors.white,
        //         title: Text(
        //           'Error',
        //           style: TextStyle(fontWeight: FontWeight.bold),
        //         ),
        //         content: Text('Failed to add elderly. Please try again later.'),
        //         actions: [
        //           TextButton(
        //             child: Text('OK'),
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //             },
        //           ),
        //         ],
        //       );
        //     },
        //   );
        // }
      } catch (e) {
        print('Exception during adding elderly: $e');
        // Handle exception if any
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Error',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text('An error occurred. Please try again later.'),
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
    } else {
      // Show validation error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Error',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('Please fill out all fields.'),
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

  // void deleteElder(int index) async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         title: Text(
  //           'Confirm Deletion',
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         content: Text(
  //             'Are you sure you want to delete this elder\'s email and relationship?'),
  //         actions: [
  //           TextButton(
  //             child: Text('CANCEL'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('DELETE'),
  //             onPressed: () async {
  //               Navigator.of(context).pop(); // Close the confirmation dialog

  //               try {
  //                 // Make DELETE request to backend API to delete specific fields of the elderly
  //                 var response = await http.delete(
  //                   Uri.parse(
  //                       'http://localhost:8000/DeleteElderly/${elders[index]['id']}'),
  //                   headers: <String, String>{
  //                     'Authorization':
  //                         'Bearer ${widget.token}', // Replace with actual token
  //                   },
  //                 );

  //                 if (response.statusCode == 200) {
  //                   // Fields deleted successfully
  //                   setState(() {
  //                     elders[index]['email'] = null;
  //                     elders[index]['relationship'] = null;
  //                   });
  //                 } else {
  //                   // Show error message if request failed
  //                   showDialog(
  //                     context: context,
  //                     builder: (BuildContext context) {
  //                       return AlertDialog(
  //                         backgroundColor: Colors.white,
  //                         title: Text(
  //                           'Error',
  //                           style: TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                         content: Text(
  //                             'Failed to delete elderly details. Please try again later.'),
  //                         actions: [
  //                           TextButton(
  //                             child: Text('OK'),
  //                             onPressed: () {
  //                               Navigator.of(context).pop();
  //                             },
  //                           ),
  //                         ],
  //                       );
  //                     },
  //                   );
  //                 }
  //               } catch (e) {
  //                 print('Exception during deleting elderly details: $e');
  //                 // Handle exception if any
  //                 showDialog(
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return AlertDialog(
  //                       backgroundColor: Colors.white,
  //                       title: Text(
  //                         'Error',
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       content:
  //                           Text('An error occurred. Please try again later.'),
  //                       actions: [
  //                         TextButton(
  //                           child: Text('OK'),
  //                           onPressed: () {
  //                             Navigator.of(context).pop();
  //                           },
  //                         ),
  //                       ],
  //                     );
  //                   },
  //                 );
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: 'Caregiver Profile',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                            hintStyle:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: Text(
                                          username, // Display the username directly
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
                              SizedBox(height: 15.0),
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
                              SizedBox(height: 30.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Under Your Care:',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                        color: Color(0xFF00916E),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    // Display `yourelderly_relation` if it exists
                                    if (elderlyRelation.isNotEmpty)
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.grey[200],
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        elderlyRelation,
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w700,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  20), // Adjust spacing as needed
                                        ],
                                      ),
                                    // Show message when `yourelderly_relation` is empty
                                    if (elderlyRelation.isEmpty)
                                      Center(
                                        child: Text(
                                          'No elders under your care.',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    // Add elder UI when both `elders` list and `yourelderly_relation` are empty
                                    if (elders.isEmpty &&
                                        elderlyRelation.isEmpty)
                                      Column(
                                        children: [
                                          SizedBox(height: 30),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _elderEmailController,
                                                  decoration: InputDecoration(
                                                    labelText: "Elder's Email*",
                                                    labelStyle: TextStyle(
                                                      color: Color(0xFF00916E),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0xFF00916E),
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0xFF00916E),
                                                      ),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value != null &&
                                                        value.contains('@')) {
                                                      return null;
                                                    } else {
                                                      return 'Please enter a valid email address';
                                                    }
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _relationController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Relation*',
                                                    labelStyle: TextStyle(
                                                      color: Color(0xFF00916E),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0xFF00916E),
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0xFF00916E),
                                                      ),
                                                    ),
                                                  ),
                                                  validator: (value) {
                                                    if (value != null &&
                                                        value.isNotEmpty) {
                                                      return null;
                                                    } else {
                                                      return 'Please enter relation';
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: addElder,
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                Color(0xFFF54900),
                                              ),
                                            ),
                                            child: Text(
                                              'ADD ELDER',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const caregiver_profile_page(token: 'your-token'));
}

class ElderModel {
  final String relation;

  ElderModel({
    required this.relation,
  });

  Map<String, dynamic> toMap() {
    return {
      'relation': relation,
    };
  }
}

List<ElderModel> elders = [];

