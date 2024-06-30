
import 'dart:convert';
import 'dart:io';
import 'package:careyou/pages/app_manage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

class CreateAppointmentReminder extends StatefulWidget {
  final String token;
  final String selectedRole;

  const CreateAppointmentReminder({required this.token, required this.selectedRole});

  @override
  _CreateAppointmentReminderState createState() =>
      _CreateAppointmentReminderState();
}

class _CreateAppointmentReminderState extends State<CreateAppointmentReminder> {
  final _reminderController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

    Future<void> _submitAppointment() async {
    final appointmentName = _reminderController.text;
    final location = _locationController.text;
    final date = _selectedDate;
    final startTime = _startTime;
    final endTime = _endTime;

    if (appointmentName.isEmpty ||
        location.isEmpty ||
        date == null ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final now = DateTime.now();
    if (selectedDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot schedule in the past')),
      );
      return;
    }

    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End time cannot be before start time')),
      );
      return;
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

    final url = Uri.parse(
        '${getServerUrl()}/appointments/CreateAppointmentReminder');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    // Format date in YYYY-MM-DD format
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Format time in HH:MM format
    final formattedStartTime =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
    final formattedEndTime =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

    final body = json.encode({
      'Appointment_name': appointmentName,
      'Date': formattedDate,
      'StartTime': formattedStartTime,
      'EndTime': formattedEndTime,
      'Location': location,
    });

    print(body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Appointment added successfully'); // Navigate back or show confirmation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to add appointment: ${response.reasonPhrase}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _startTime = null; // Reset time when date changes
        _endTime = null;
      });
    }
  }

  String formatTime(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour}:${timeOfDay.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? now : _startTime ?? now,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          if (_endTime != null && _endTime!.hour < _startTime!.hour) {
            _endTime = _startTime;
          } else if (_endTime != null &&
              _endTime!.hour == _startTime!.hour &&
              _endTime!.minute < _startTime!.minute) {
            _endTime = _startTime;
          }
        } else {
          _endTime = picked;
          if (_startTime != null && _endTime!.hour < _startTime!.hour) {
            _startTime = _endTime;
          } else if (_startTime != null &&
              _endTime!.hour == _startTime!.hour &&
              _endTime!.minute < _startTime!.minute) {
            _startTime = _endTime;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF00916E),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'Appointment Management',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop(); // Navigate back
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today is ${DateFormat('E, dd MMM, yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00916E),
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set the Reminder',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00916E),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointment Name:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _reminderController,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF00916E),
                                    width: 2.0,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF00916E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Date:',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                height: 20,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedDate == null
                                          ? 'Select Date'
                                          : DateFormat('dd/MM/yyyy')
                                              .format(_selectedDate!),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        color: Color(0xFF00916E),
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down,
                                        color: Color.fromARGB(255, 98, 98,
                                            98)), // Adjust color as needed
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration:',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _selectTime(context, true),
                            child: Container(
                              height: 20,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _startTime == null
                                        ? 'Start Time'
                                        : '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Color(0xFF00916E),
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down,
                                      color: Color.fromARGB(255, 98, 98, 98)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'to',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _selectTime(context, false),
                            child: Container(
                              height: 20,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _endTime == null
                                        ? 'End Time'
                                        : '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Color(0xFF00916E),
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down,
                                      color: Color.fromARGB(255, 98, 98, 98)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _locationController,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF00916E),
                                    width: 2.0,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF00916E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "Create Appointment",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: const Text(
                  "Are you sure you want to create this appointment?",
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
                          await _submitAppointment(); // Wait for data submission to complete
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AppManage(
                                    token: widget.token, selectedRole: widget.selectedRole
                                  ),
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