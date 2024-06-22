import 'package:careyou/pages/pillsManagePageCareGiver.dart';
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
  bool isEditMode = false;
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

      // Validate if at least one reminder time is selected
      if (selectedreminderTime.isEmpty ||
          selectedreminderTime.any((time) => time == null)) {
        print('Please select at least one reminder time');
        return;
      }

      // Convert reminder times to a list of strings in 'HH:MM' format
      List<String> reminderTimesFormatted = selectedreminderTime
          .map((time) => time != null
              ? '${time!.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
              : '')
          .where((time) => time.isNotEmpty)
          .toList();

      // Check if there's at least one valid time
      if (reminderTimesFormatted.isEmpty) {
        print('Please select at least one valid reminder time');
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
    } else {
      // Handle validation errors
      print('Please fill all the fields');
    }
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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(data),
      );

      print('Token: ${widget.token}');

      if (response.statusCode == 201) {
        // Handle successful API call
        print('Data sent successfully');
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
                          Navigator.of(context).popUntil((route) =>
                              route.isFirst); // Pop until the first route
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PillsManagePageCareGiver(token: widget.token),
                            ),
                          );
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
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00916E),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 25,
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
                                        EdgeInsets.symmetric(horizontal: 5),
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the pill name';
                                    }
                                    return null;
                                  },
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
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00916E),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 25,
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
                                    hintText: 'Note',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF999797),
                                      fontSize: screenWidth * 0.025,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a note';
                                    }
                                    return null;
                                  },
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
              padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 10.0),
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
                spacing: 10.0,
                children: pillTypes.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        selectedType = selected ? type : '';
                        widget.onPillTypeSelected(selectedType);
                      });
                    },
                    selectedColor: const Color(0xFF00916E),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedType == type ? Colors.white : Colors.black,
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
              padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 10.0),
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
                spacing: 10.0,
                children: pillTimes.map((time) {
                  return ChoiceChip(
                    label: Text(time),
                    selected: selectedTime == time,
                    onSelected: (selected) {
                      setState(() {
                        selectedTime = selected ? time : '';
                        widget.onPillTimeSelected(selectedTime);
                      });
                    },
                    selectedColor: const Color(0xFF00916E),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedTime == time ? Colors.white : Colors.black,
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
    );
    if (picked != null) {
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
          padding: const EdgeInsets.all(10.0),
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
              const SizedBox(height: 10.0),
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
                        GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              startDate == null
                                  ? 'Select Start Date'
                                  : DateFormat('yyyy-MM-dd').format(startDate!),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.03,
                                color: const Color(0xFF00916E),
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
                        GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              endDate == null
                                  ? 'Select End Date'
                                  : DateFormat('yyyy-MM-dd').format(endDate!),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.03,
                                color: const Color(0xFF00916E),
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
              Wrap(
                spacing: 10.0,
                children: frequencyOptions.map((frequency) {
                  return ChoiceChip(
                    label: Text(frequency.toString()),
                    selected: selectedFrequency == frequency,
                    onSelected: (selected) {
                      if (selected) {
                        _updateFrequency(frequency);
                      }
                    },
                    selectedColor: const Color(0xFF00916E),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedFrequency == frequency
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }).toList(),
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
                    ...List.generate(selectedFrequency, (index) {
                      return GestureDetector(
                        onTap: () => _selectTime(context, index),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            selectedreminderTime.length > index &&
                                    selectedreminderTime[index] != null
                                ? selectedreminderTime[index]!.format(context)
                                : 'Select Reminder Time',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.03,
                              color: const Color(0xFF00916E),
                            ),
                          ),
                        ),
                      );
                    }),
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
              Wrap(
                spacing: 10.0,
                children: pillCountOptions.map((count) {
                  return ChoiceChip(
                    label: Text(count.toString()),
                    selected: selectedPillCount == count,
                    onSelected: (selected) {
                      setState(() {
                        selectedPillCount = selected ? count : 0;
                        widget.onPillCountSelected(selectedPillCount);
                      });
                    },
                    selectedColor: const Color(0xFF00916E),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: selectedPillCount == count
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
