import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class PillsmanageCreatePage extends StatefulWidget {
  final String token; // Add the 'token' field here

  const PillsmanageCreatePage({Key? key, required this.token})
      : super(key: key);

  @override
  State<PillsmanageCreatePage> createState() => _PillsmanageCreatePageState();
}

class PillManagement {
  final String pillName;
  final String note;
  final String pillType;
  final String pillTime;
  final String reminderDurationStart;
  final String reminderDurationEnd;
  final List<String> reminderTime;
  final int reminderFrequency;
  final String token;

  PillManagement({
    required this.pillName,
    required this.note,
    required this.pillType,
    required this.pillTime,
    required this.reminderDurationStart,
    required this.reminderDurationEnd,
    required this.reminderTime,
    required this.reminderFrequency,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'pillName': pillName,
      'note': note,
      'pillType': pillType,
      'pillTime': pillTime,
      'reminderDurationStart': reminderDurationStart,
      'reminderDurationEnd': reminderDurationEnd,
      'reminderTime': reminderTime,
      'reminderFrequency': reminderFrequency,
    };
  }
}

class _PillsmanageCreatePageState extends State<PillsmanageCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pillNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? selectedPillType;
  String? selectedPillTime;
  DateTime? selectedDate1;
  DateTime? selectedDate2;
  List<TimeOfDay?> selectedreminderTime = [];
  int? selectedFrequency;
  int? selectedPillCount;

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      // Convert selected dates to ISO 8601 strings
      String formattedStartDate =
          selectedDate1?.toIso8601String().substring(0, 10) ?? '';
      String formattedEndDate =
          selectedDate2?.toIso8601String().substring(0, 10) ?? '';

      // Convert reminder times to a list of strings in 'HH:MM' format
      List<String> reminderTimesFormatted = selectedreminderTime
          .map((time) => time != null
              ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
              : '')
          .where((time) => time.isNotEmpty)
          .toList();

      // Prepare the reminder times based on frequency
      String reminderTimesString;
      if (selectedFrequency == 1) {
        reminderTimesString = reminderTimesFormatted.first;
      } else {
        reminderTimesString = reminderTimesFormatted.join(', ');
      }

      // Validate if at least one reminder time is selected
      if (_pillNameController.text.isEmpty) {
        _showValidationError('Please fill Pill Name');
        return;
      }
      if (_noteController.text.isEmpty) {
        _showValidationError('Please fill Note');
        return;
      }
      if (selectedPillType?.isEmpty ?? true) {
        _showValidationError('Please chosse Pill Type');
        return;
      }
      if (selectedPillTime?.isEmpty ?? true) {
        _showValidationError('Please choose Pill Time');
        return;
      }
      if (selectedDate1 == null && selectedDate2 == null) {
        _showValidationError('Please choose Date');
        return;
      }
      if (selectedDate1 == null) {
        _showValidationError('Please choose Start Date');
        return;
      }
      if (selectedDate2 == null) {
        _showValidationError('Please choose End Date');
        return;
      }
      if (selectedreminderTime.isEmpty ||
          selectedreminderTime.any((time) => time == null)) {
        _showValidationError('Please fill reminder time');
        return;
      }
      if (selectedFrequency == null) {
        _showValidationError('Please choose Reminder Frequency');
        return;
      }
      if (selectedPillCount == null) {
        _showValidationError('Please choose Pill Count');
        return;
      }

      // Create a map with all the necessary data
      final data = {
        'pill_name': _pillNameController.text,
        'pill_note': _noteController.text,
        'pill_type': selectedPillType,
        'pill_Time': selectedPillTime,
        'start_date': formattedStartDate,
        'end_date': formattedEndDate,
        'reminder_times': reminderTimesFormatted,
        'frequency': selectedFrequency,
        'NumberofPills': selectedPillCount,
      };

      // Print data to verify before sending
      print('Sending data to backend: $data');

      // Call the function to send data to backend
      await sendReminderData(data);

      // If data submission is successful, navigate to the next page
      // Navigator.of(context).pop();
      // Navigator.of(context).pop();
      // Navigator.of(context).popUntil((route) => route.isFirst);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PillsManagePageCareGiver(
      //       token: widget.token,
      //       selectedRole: '',
      //     ),
      //   ),
      // );
    } else {
      print('Please fill all the fields');
      _showValidationError('Please fill all the fields.');
    }
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Validation Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendReminderData(Map<String, dynamic> data) async {
    // Replace this with your actual API call to send data
    final Uri url = Uri.parse('http://localhost:8000/pills/CreatePillReminder');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        // Handle successful API call
        print('Data sent successfully');

        // Assuming you want to pop back to the previous screen after successful send
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        // Handle API errors
        print('Failed to send data. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle network errors
      print('Failed to connect to the server. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          color: const Color(0xFF00916E),
          padding: const EdgeInsets.only(top: 20),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CreatePillsCard(
                        pillNameController: _pillNameController,
                        noteController: _noteController,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CreatePillsType(
                        onPillTypeSelected: (value) {
                          setState(() {
                            selectedPillType = value;
                            print(selectedPillType);
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CreatePillsTime(
                        onPillTimeSelected: (value) {
                          setState(() {
                            selectedPillTime = value;
                            print(selectedPillTime);
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CreateSetReminder(
                        onStartDateSelected: (value) {
                          setState(() {
                            selectedDate1 = value;
                            print(selectedDate1);
                          });
                        },
                        onEndDateSelected: (value) {
                          setState(() {
                            selectedDate2 = value;
                            print(selectedDate2);
                          });
                        },
                        onReminderTimeSelected: (value) {
                          setState(() {
                            selectedreminderTime = value as List<TimeOfDay?>;
                            print(selectedreminderTime);
                          });
                        },
                        onFrequencySelected: (value) {
                          setState(() {
                            selectedFrequency = value;
                            print(selectedFrequency);
                          });
                        },
                        onPillCountSelected: (value) {
                          setState(() {
                            selectedPillCount = value;
                            print(selectedPillCount);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "Create Medication",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: const Text(
                  "Are you sure you want to create this medication?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: const Color.fromARGB(
                              255, 218, 218, 218), // background color
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12, // text size
                            fontWeight: FontWeight.bold, // text weight
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15), // button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // button border radius
                          ),
                        ),
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(
                              255, 66, 169, 144), // background color
                          textStyle: const TextStyle(
                            fontSize: 12, // text size
                            fontWeight: FontWeight.bold, // text weight
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15), // button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // button border radius
                          ),
                        ),
                        child: const Text("Create"),
                        onPressed: () async {
                          await _submitData(); // Wait for data submission to complete
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
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
    );
  }
}

class CreatePillsCard extends StatelessWidget {
  final TextEditingController pillNameController;
  final TextEditingController noteController;

  const CreatePillsCard({
    Key? key,
    required this.pillNameController,
    required this.noteController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Card(
        child: Container(
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 6.5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 5.0, left: 15.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pill Name:',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00916E),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: screenHeight * 0.025,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF00916E),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: pillNameController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Type pill name, treat for, label',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF999797),
                                      fontSize: screenWidth * 0.025,
                                    ),
                                    contentPadding:
                                        EdgeInsets.only(left: 5.0, bottom: 18),
                                    border: InputBorder.none,
                                  ),
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Please enter the pill name';
                                  //   }
                                  // },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Note:',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00916E),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: screenHeight * 0.025,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF00916E),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: noteController,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText: 'Add more detail',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF999797),
                                      fontSize: screenWidth * 0.025,
                                    ),
                                    contentPadding:
                                        EdgeInsets.only(left: 5.0, bottom: 18),
                                    border: InputBorder.none,
                                  ),
                                  // validator: (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Please enter a note';
                                  //   }
                                  //   return null;
                                  // },
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
            ],
          ),
        ),
      ),
    );
  }
}

class CreatePillsType extends StatefulWidget {
  final ValueChanged<String> onPillTypeSelected;

  const CreatePillsType({
    Key? key,
    required this.onPillTypeSelected,
  }) : super(key: key);

  @override
  _CreatePillsTypeState createState() => _CreatePillsTypeState();
}

class _CreatePillsTypeState extends State<CreatePillsType> {
  String selectedType = '';

  List<String> pillTypes = [
    'Tablet',
    'Capsule',
    'Gel',
    'Injection',
    'Lotion',
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      child: Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 1),
              blurRadius: 6.5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 5.0),
              child: Text(
                'Pill Type',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00916E),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Wrap(
                spacing: 3.0,
                children: pillTypes.map((type) {
                  return Container(
                    width: 65,
                    height: 25,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedType = selectedType == type ? '' : type;
                          widget.onPillTypeSelected(selectedType);
                        });
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.all(1), // Adjust padding as needed
                        ),
                        backgroundColor: selectedType == type
                            ? MaterialStateProperty.all<Color>(
                                const Color(0xFFF54900))
                            : MaterialStateProperty.all<Color>(
                                const Color(0xFFD1D1D1)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: const Color(0xFFD1D1D1)),
                          ),
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}

class CreatePillsTime extends StatefulWidget {
  final ValueChanged<String> onPillTimeSelected;

  const CreatePillsTime({
    Key? key,
    required this.onPillTimeSelected,
  }) : super(key: key);

  @override
  _CreatePillsTimeState createState() => _CreatePillsTimeState();
}

class _CreatePillsTimeState extends State<CreatePillsTime> {
  String selectedTime = '';

  List<String> pillTimes = [
    'Before Meal',
    'After Meal',
    'Take with Meal',
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      child: Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 1),
              blurRadius: 6.5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 5.0),
              child: Text(
                'Pill Time',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00916E),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Wrap(
                spacing: 3.0,
                children: pillTimes.map((time) {
                  return Container(
                      width: 90,
                      height: 25,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTime = selectedTime == time ? '' : time;
                            widget.onPillTimeSelected(selectedTime);
                          });
                        },
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.all(1), // Adjust padding as needed
                          ),
                          backgroundColor: selectedTime == time
                              ? MaterialStateProperty.all<Color>(
                                  const Color(0xFFF54900))
                              : MaterialStateProperty.all<Color>(
                                  const Color(0xFFD1D1D1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: const Color(0xFFD1D1D1)),
                            ),
                          ),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ));
                }).toList(),
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}

class CreateSetReminder extends StatefulWidget {
  final Function(DateTime) onStartDateSelected;
  final Function(DateTime) onEndDateSelected;
  final Function(List<TimeOfDay?>)
      onReminderTimeSelected; // Updated to pass list of TimeOfDay?
  final Function(int) onFrequencySelected;
  final Function(int) onPillCountSelected;

  const CreateSetReminder({
    Key? key,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    required this.onReminderTimeSelected,
    required this.onFrequencySelected,
    required this.onPillCountSelected,
  }) : super(key: key);

  @override
  _CreateSetReminderState createState() => _CreateSetReminderState();
}

class _CreateSetReminderState extends State<CreateSetReminder> {
  DateTime? startDate;
  DateTime? endDate;
  List<TimeOfDay?> selectedreminderTime =
      []; // Changed to initialize as empty list
  int selectedFrequency = 0;
  int selectedPillCount = 0;

  List<int> frequencyOptions = [1, 2, 3, 4, 5];
  List<int> pillCountOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  void initState() {
    super.initState();
  }

  DateTime currentDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            // Customize your theme here
            primaryColor:
                const Color(0xFFF54900), // Color of the header background
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFF54900), // Selected day color
              onPrimary: Color.fromARGB(
                  255, 255, 255, 255), // Text color of the selected day
              surface: const Color.fromARGB(
                  255, 255, 255, 255), // Background color of non-selected days
              onSurface: const Color.fromARGB(
                  255, 0, 0, 0), // Text color of non-selected days
            ),
            // Specify any additional ThemeData properties you want to customize
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          widget.onStartDateSelected(startDate!);
        } else {
          endDate = picked;
          widget.onEndDateSelected(endDate!);
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            // Customize your theme here
            primaryColor:
                const Color(0xFFF54900), // Color of the header background
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFF54900), // Selected day color
              onPrimary: Color.fromARGB(
                  255, 255, 255, 255), // Text color of the selected day
              surface: const Color.fromARGB(
                  255, 255, 255, 255), // Background color of non-selected days
              onSurface: const Color.fromARGB(
                  255, 0, 0, 0), // Text color of non-selected days
            ),
            // Specify any additional ThemeData properties you want to customize
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final DateTime now = DateTime.now();
      final DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      // Check if selected date is today and picked time is in the past
      if (selectedDateTime.isBefore(now) && selectedDateTime.day == now.day) {
        _selectedTimeError('Cannot select a past time.');
        return;
      }

      // Check if the picked time already exists in selectedreminderTime
      bool isTimeAlreadySelected = selectedreminderTime.any((time) {
        return time?.hour == picked.hour && time?.minute == picked.minute;
      });

      if (isTimeAlreadySelected) {
        _selectedSameTimeError('This time is already selected.');
        return;
      }

      setState(() {
        if (selectedreminderTime.length <= index) {
          selectedreminderTime.add(picked);
        } else {
          selectedreminderTime[index] = picked;
        }
        widget.onReminderTimeSelected(selectedreminderTime);
      });
    }
  }

  void _selectedSameTimeError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selected Time Error'),
          content: Text(message),
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

  void _selectedTimeError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selected Time Error'),
          content: Text(message),
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

  void _updateFrequency(int frequency) {
    setState(() {
      selectedFrequency = frequency;
      selectedreminderTime = List.filled(frequency, null);
      widget.onFrequencySelected(selectedFrequency);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      child: Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 1),
              blurRadius: 6.5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Reminder',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00916E),
                ),
              ),
              const SizedBox(height: 7.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            height: 30,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: startDate != null
                                  ? const Color(0xFFF54900)
                                  : const Color(0xFFD1D1D1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment
                                .center, // Center aligns the child (Text widget)
                            padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10), // Adjust padding as needed
                            child: Text(
                              startDate == null
                                  ? 'Select Start Date'
                                  : DateFormat('yyyy-MM-dd').format(startDate!),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            height: 30,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: endDate != null
                                  ? const Color(0xFFF54900)
                                  : const Color(0xFFD1D1D1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment
                                .center, // Center aligns the child (Text widget)
                            padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10), // Adjust padding as needed
                            child: Text(
                              endDate == null
                                  ? 'Select End Date'
                                  : DateFormat('yyyy-MM-dd').format(endDate!),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                'Reminder Frequency',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5.0),
              DropdownTime(
                options:
                    frequencyOptions.map((freq) => freq.toString()).toList(),
                dropdownBackgroundColor: Colors.grey[200]!,
                onPressed: (String newValue) {
                  // Handle frequency selection here
                  _updateFrequency(int.parse(newValue));
                },
              ),
              const SizedBox(height: 10.0),
              if (selectedFrequency > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Time',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Column(
                      children: List.generate(selectedFrequency, (index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => _selectTime(context, index),
                              child: Container(
                                height: 30,
                                width: 170,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: selectedreminderTime[index] != null
                                      ? const Color(0xFFF54900)
                                      : const Color(0xFFD1D1D1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  selectedreminderTime.length > index &&
                                          selectedreminderTime[index] != null
                                      ? selectedreminderTime[index]!
                                          .format(context)
                                      : 'Select Time',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height:
                                    10.0), // Adjust this SizedBox height as per your requirement
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              const SizedBox(height: 10.0),
              Text(
                'Pill Count',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5.0),
              DropdownPillCount(
                options: pillCountOptions,
                dropdownBackgroundColor: Colors.grey[200]!,
                onChanged: (selectedCount) {
                  setState(() {
                    selectedPillCount = selectedCount;
                  });
                  widget.onPillCountSelected(selectedPillCount);
                },
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownTime extends StatefulWidget {
  final List<String> options;
  final Color dropdownBackgroundColor;
  final Function(String) onPressed;

  DropdownTime({
    Key? key,
    required this.options,
    required this.dropdownBackgroundColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  _DropdownTimeState createState() => _DropdownTimeState();
}

class _DropdownTimeState extends State<DropdownTime> {
  late String _selectedOptionTime;

  @override
  void initState() {
    super.initState();
    _selectedOptionTime = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 170,
      decoration: BoxDecoration(
        color: _selectedOptionTime.isNotEmpty
            ? const Color(0xFFF54900)
            : const Color(0xFFD1D1D1),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedOptionTime.isNotEmpty ? _selectedOptionTime : null,
            hint: const Text(
              'Select Frequency',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 12.0,
                fontFamily: 'Poppins',
              ),
            ),
            items: widget.options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'Poppins',
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedOptionTime = newValue ?? '';
              });
              widget.onPressed(newValue ?? '');
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            dropdownColor: const Color(0xFFD1D1D1),
          ),
        ),
      ),
    );
  }
}

class DropdownPillCount extends StatefulWidget {
  final List<int> options;
  final Color dropdownBackgroundColor;
  final Function(int) onChanged;

  const DropdownPillCount({
    Key? key,
    required this.options,
    required this.dropdownBackgroundColor,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DropdownPillCountState createState() => _DropdownPillCountState();
}

class _DropdownPillCountState extends State<DropdownPillCount> {
  int? _selectedCount; // Use nullable int to handle initial hint

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedCount != null
            ? const Color(0xFFF54900)
            : const Color(0xFFD1D1D1),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCount,
          hint: const Text(
            'Select Pill Count',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 12.0,
              fontFamily: 'Poppins',
            ),
          ),
          items: widget.options.map((int count) {
            return DropdownMenuItem<int>(
              value: count,
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCount = newValue;
              });
              widget.onChanged(newValue);
            }
          },
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          dropdownColor: const Color(0xFFD1D1D1),
        ),
      ),
    );
  }
}
