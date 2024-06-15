import 'package:flutter/material.dart';

class caregiver_profile_page extends StatefulWidget {
  const caregiver_profile_page();

  @override
  State<caregiver_profile_page> createState() => _HomepageState();
}

class _HomepageState extends State<caregiver_profile_page> {
  bool isEditingUsername = false;
  bool isEditingPassword = false;
  TextEditingController usernameController =
      TextEditingController(text: 'Ebbabo');
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  List<ElderModel> elders = [
    ElderModel(name: 'Ebbabo', relation: 'Grandmother'),
  ];

  TextEditingController _elderEmailController = TextEditingController();
  TextEditingController _relationController = TextEditingController();

  void toggleEditMode(String field) {
    setState(() {
      isEditingUsername = false;
      isEditingPassword = false;
      if (field == 'username') {
        isEditingUsername = true;
      } else if (field == 'password') {
        isEditingPassword = true;
      }
    });
  }

  void saveData() {
    if (isEditingPassword) {
      // Simulate checking old password
      String storedPassword = 'password'; // Replace with your stored password
      String enteredOldPassword = oldPasswordController.text;

      if (enteredOldPassword == storedPassword) {
        // Password matches, proceed with saving
        setState(() {
          isEditingUsername = false;
          isEditingPassword = false;
        });
        // Show success dialog or perform save operation
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Success',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
      } else {
        // Password does not match, show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Error',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text('Old password does not match.'),
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
      // Save username logic can go here if needed
      setState(() {
        isEditingUsername = false;
      });
      // Show success message or perform save operation for username
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
    }
  }

  void addElder() {
    String elderEmail = _elderEmailController.text.trim();
    String relation = _relationController.text.trim();

    if (elderEmail.isNotEmpty && relation.isNotEmpty) {
      // Add new elder to the list
      ElderModel newElder =
          ElderModel(name: elderEmail.split('@').first, relation: relation);
      elders.add(newElder);

      // Clear the input fields
      _elderEmailController.clear();
      _relationController.clear();

      setState(() {});
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

  void deleteElder(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Confirm Deletion',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete this elder?'),
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('DELETE'),
              onPressed: () {
                // Delete elder and close dialog
                elders.removeAt(index);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

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
                    const Padding(
                      padding: EdgeInsets.only(top: 130.0, left: 50.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hello, Ebbabo',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0, left: 50.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Today is Wed 24, 20204',
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
                                  'abcd_123@gmail.com',
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
                                          '${usernameController.text}',
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40.0),
                                  child: Center(
                                    // Center widget added here
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (!isEditingPassword)
                                      Text(
                                        'Password: ', // Show label when not editing password
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF00916E),
                                        ),
                                      ),
                                    if (!isEditingPassword)
                                      Expanded(
                                        child: Text(
                                          '${'*' * 8}', // Show 8 hidden digits
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    if (!isEditingPassword)
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Color(0xFFF54900)),
                                        onPressed: () =>
                                            toggleEditMode('password'),
                                      ),
                                  ],
                                ),
                              ),
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF00916E),
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    if (elders.isEmpty)
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
                                      )
                                    else
                                      Column(
                                        children: elders
                                            .map((elder) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 10.0),
                                                  child: Container(
                                                    padding: EdgeInsets.all(15),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                              elder.name,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                              elder.relation,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () =>
                                                              deleteElder(elders
                                                                  .indexOf(
                                                                      elder)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    if (elders
                                        .isEmpty) // Show add elder UI only when elders list is empty
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

class ElderModel {
  final String name;
  final String relation;

  ElderModel({required this.name, required this.relation});
}

void main() {
  runApp(const caregiver_profile_page());
}
