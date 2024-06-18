// // ignore: file_names
// import 'package:careyou/components/appointmentCard.dart';
// import 'package:careyou/components/logOutButton.dart';
// import 'package:careyou/components/pillsCardElder.dart';
// import 'package:flutter/material.dart';

// // ignore: camel_case_types
// class HomePageElder extends StatefulWidget {
//   const HomePageElder({super.key});

//   @override
//   State<HomePageElder> createState() => _HomePageElderState();
// }

// class _HomePageElderState extends State<HomePageElder> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: SingleChildScrollView(
//       child: Stack(children: [
//         // Background color
//         SizedBox(
//           height: MediaQuery.of(context).size.height,
//           child: Container(
//             decoration: const BoxDecoration(
//               color: Color(0xFF00916E),
//             ),
//           ),
//         ),

//         // Log out button
//         const Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(right: 20.0, top: 40),
//               child: LogoutButton(),
//             ),
//           ],
//         ),

//         // Text and Card List
//         const Padding(
//           padding: EdgeInsets.only(top: 80.0, left: 50.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               //1 Hello user
//               Padding(
//                 padding: EdgeInsets.only(),
//                 child: Text(
//                   "Hello, Bella",
//                   // "Hi, ${user.displayName ?? 'Guest'}",
//                   style: TextStyle(
//                     fontFamily: 'poppins',
//                     fontSize: 35,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               //2 Date
//               Padding(
//                 padding: EdgeInsets.only(),
//                 child: Text(
//                   'Today is Wed 24, 2024',
//                   style: TextStyle(
//                     fontFamily: 'poppins',
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               //3 select under care
//             ],
//           ),
//         ),

//         // White box
//         Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 185.0),
//               child: Container(
//                 height: MediaQuery.of(context).size.height,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30.0),
//                     topRight: Radius.circular(30.0),
//                   ),
//                 ),
//               ),
//             ),
//             //Today Appointment Card
//             const Column(
//               children: [
//                 Positioned(
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 200, left: 20.0, right: 20.0),
//                     child: AppointmentCard(),
//                   ),
//                 ),

//                 // Line between AppointmentCard and PillsCard
//                 Positioned(
//                   left: 20.0,
//                   right: 20.0,
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 0.5, left: 20.0, right: 20.0),
//                     child: Center(
//                       child: Divider(
//                         color: Color(0xFF00916E),
//                         height: 40,
//                         thickness: 1,
//                         indent: 10,
//                         endIndent: 10,
//                       ),
//                     ),
//                   ),
//                 ),

//                 //Pills Card
//                 Positioned(
//                   left: 20.0,
//                   right: 20.0,
//                   child: Padding(
//                       padding:
//                           EdgeInsets.only(top: 0.5, left: 20.0, right: 20.0),
//                       child: PillsCardElder()),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ]),
//     ));
//   }
// }

// //Undercare Dropdown
// class DropdownBox extends StatefulWidget {
//   final List<String> options;
//   final Color dropdownBackgroundColor; // Add this property

//   const DropdownBox(
//       {super.key,
//       required this.options,
//       required this.dropdownBackgroundColor});

//   @override
//   // ignore: library_private_types_in_public_api
//   _DropdownBoxState createState() => _DropdownBoxState();
// }

// class _DropdownBoxState extends State<DropdownBox> {
//   late String _selectedOption; // Change this to late

//   @override
//   void initState() {
//     super.initState();
//     // Set the initial selected option to the first option in the list
//     _selectedOption = widget.options.isNotEmpty ? widget.options[0] : '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 30,
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF99D19C),
//         borderRadius: BorderRadius.circular(40),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 5,
//             spreadRadius: 1,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedOption.isNotEmpty ? _selectedOption : null,
//           items: widget.options.map((String option) {
//             return DropdownMenuItem<String>(
//               value: option,
//               child: Text(
//                 option,
//                 style: const TextStyle(
//                   color: Color.fromARGB(255, 255, 255, 255),
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             setState(() {
//               _selectedOption = newValue ?? '';
//             });
//           },
//           icon: const Icon(
//             Icons.arrow_drop_down,
//             color: Color.fromARGB(255, 255, 255, 255),
//           ),
//           dropdownColor: widget
//               .dropdownBackgroundColor, // Set the dropdown background color
//         ),
//       ),
//     );
//   }
// }
