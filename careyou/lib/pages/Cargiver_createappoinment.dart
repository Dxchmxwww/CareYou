// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:careyou/components/navbar.dart';

// class CreateAppointmentReminder extends StatefulWidget {
// final String token;

//   // const AppManage({required this.token, this.selectedRole = 'Caregiver'});
//   const CreateAppointmentReminder({required this.token});

//   @override
//   _CreateAppointmentReminder createState() => _CreateAppointmentReminder();
// }

// class _CreateAppointmentReminder extends State<CreateAppointmentReminder> {
//   final _reminderController = TextEditingController();
//   final _locationController = TextEditingController();
//   String _selectedDate = 'DD/MM/YYYY';
//   String _startTime = 'HH:MM:SS';
//   String _endTime = 'HH:MM:SS';

//   // Replace with your actual authentication token
//   final String authToken = 'Bearer YOUR_AUTH_TOKEN_HERE';

//   Future<void> _submitAppointment() async {
//     final appointmentName = _reminderController.text;
//     final location = _locationController.text;
//     final date = _selectedDate;
//     final startTime = _startTime;
//     final endTime = _endTime;

//     if (appointmentName.isEmpty ||
//         location.isEmpty ||
//         date == 'DD/MM/YYYY' ||
//         startTime == 'HH:MM:SS' ||
//         endTime == 'HH:MM:SS') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill in all fields')),
//       );
//       return;
//     }

//     final url = Uri.parse('http://localhost:8000/CreateAppointmentReminder');
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': authToken, // Add authorization header
//     };
//     final body = json.encode({
//       'Appointment_name': appointmentName,
//       'Date': date,
//       'StartTime': startTime,
//       'EndTime': endTime,
//       'Location': location,
//     });

//     try {
//       final response = await http.post(url, headers: headers, body: body);
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Appointment added successfully')),
//         );
//         Navigator.of(context).pop(); // Navigate back or show confirmation
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add appointment: ${response.reasonPhrase}')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $error')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(106),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: const Color(0xFF00916E),
//           flexibleSpace: Padding(
//             padding: const EdgeInsets.only(top: 40.0),
//             child: Stack(
//               children: [
//                 Center(
//                   child: Text(
//                     'Appointment Management',
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontSize: 20,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Positioned(
//                   left: 16,
//                   top: 0,
//                   bottom: 0,
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back),
//                     color: Colors.white,
//                     onPressed: () {
//                       Navigator.of(context).pop(); // Navigate back
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Today is Wed 24, 2024',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: const Color(0xFF00916E),
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.shade300,
//                         spreadRadius: 3,
//                         blurRadius: 7,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Set the Reminder',
//                         style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF00916E),
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Appointment Name:',
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF000000),
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                             ],
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: TextField(
//                               controller: _reminderController,
//                               style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 12,
//                                 color: Colors.black,
//                               ),
//                               decoration: const InputDecoration(
//                                 isDense: true,
//                                 contentPadding: EdgeInsets.zero,
//                                 focusedBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                     color: Color(0xFF00916E),
//                                     width: 2.0,
//                                   ),
//                                 ),
//                                 enabledBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                     color: Color(0xFF00916E),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 12),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Select Date:',
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Container(
//                             height: 20,
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(100),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: _selectedDate,
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   fontSize: 7,
//                                   color: Colors.black,
//                                 ),
//                                 items: <String>[
//                                   'DD/MM/YYYY',
//                                   '24/06/2024',
//                                   '25/06/2024',
//                                   '26/06/2024'
//                                 ].map((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 4),
//                                       alignment: Alignment.centerLeft,
//                                       child: Text(value),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     _selectedDate = newValue!;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 12),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Duration:',
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Container(
//                             height: 20,
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(100),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: _startTime,
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   fontSize: 7,
//                                   color: Colors.black,
//                                 ),
//                                 items: <String>[
//                                   'HH:MM:SS',
//                                   '08:00:00',
//                                   '09:00:00',
//                                   '10:00:00'
//                                 ].map((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 4),
//                                       alignment: Alignment.centerLeft,
//                                       child: Text(value),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     _startTime = newValue!;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'to',
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Container(
//                             height: 20,
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(100),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 value: _endTime,
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   fontSize: 7,
//                                   color: Colors.black,
//                                 ),
//                                 items: <String>[
//                                   'HH:MM:SS',
//                                   '12:00:00',
//                                   '13:00:00',
//                                   '14:00:00'
//                                 ].map((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 4),
//                                       alignment: Alignment.centerLeft,
//                                       child: Text(value),
//                                     ),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     _endTime = newValue!;
//                                   });
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 12),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Location:',
//                                 style: TextStyle(
//                                   fontFamily: 'Poppins',
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF000000),
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                             ],
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: TextField(
//                               controller: _locationController,
//                               style: TextStyle(
//                                 fontFamily: 'Poppins',
//                                 fontSize: 12,
//                                 color: Colors.black,
//                               ),
//                               decoration: const InputDecoration(
//                                 isDense: true,
//                                 contentPadding: EdgeInsets.zero,
//                                 focusedBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                     color: Color(0xFF00916E),
//                                     width: 2.0,
//                                   ),
//                                 ),
//                                 enabledBorder: UnderlineInputBorder(
//                                   borderSide: BorderSide(
//                                     color: Color(0xFF00916E),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 57,
//                       height: 57,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF00916E),
//                         shape: BoxShape.circle,
//                       ),
//                       child: IconButton(
//                         onPressed: _submitAppointment,
//                         icon: const Icon(
//                           Icons.save_outlined,
//                           color: Colors.white,
//                           size: 35,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Positioned(
//           //       left: 0,
//           //       right: 0,
//           //       bottom: 0,
//           //       child: NavBar(), // Renders the navigation bar at the bottom
//           //     ),
//         ],
//       ),
//       backgroundColor: const Color(0xFFFFFFFF),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

class CreateAppointmentReminder extends StatefulWidget {
  final String token;

  const CreateAppointmentReminder({required this.token});

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

    final url =
        Uri.parse('http://localhost:8000/appointments/CreateAppointmentReminder');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    // Format date in YYYY-MM-DD format
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Format time in HH:MM format
    final formattedStartTime =
        '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}:00';
    final formattedEndTime =
        '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}:00';

    final body = json.encode({
      'Appointment_name': appointmentName,
      'Date': formattedDate,
      'StartTime': formattedStartTime,
      'EndTime': formattedEndTime,
      'Location': location,
    });

    print(body);

    try {
      final response =
          await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment added successfully')),
        );
        Navigator.of(context).pop(); // Navigate back or show confirmation
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
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [   
                                  Text(
                                    _selectedDate == null
                                        ? 'Select Date'
                                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Color(0xFF00916E),
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 98, 98, 98)), // Adjust color as needed
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                        : '${_startTime!.hour}:${_startTime!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Color(0xFF00916E),
                                    ),
                                  ),
                                   Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 98, 98, 98)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                        : '${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: Color(0xFF00916E),
                                    ),
                                  ),
                                   Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 98, 98, 98)),
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
                                'Duration:',
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
                      // Center(
                      //   child: ElevatedButton(
                      //     onPressed: _submitAppointment,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Color(0xFF00916E),
                      //       padding: EdgeInsets.symmetric(
                      //           vertical: 8, horizontal: 24),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(100),
                      //       ),
                      //     ),
                      //     child: Text(
                      //       'Add Appointment',
                      //       style: TextStyle(
                      //         fontFamily: 'Poppins',
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 57,
                              height: 57,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00916E),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: _submitAppointment,
                                icon: const Icon(
                                  Icons.save_outlined,
                                  color: Colors.white,
                                  size: 35,
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
    );
  }
}
