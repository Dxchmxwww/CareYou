// // ignore: file_names
// import 'package:careyou/components/appointmentCard.dart';
// import 'package:careyou/components/logOutButton.dart';
// import 'package:careyou/components/pillsCardCareGiver.dart';
// import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// // ignore: camel_case_types
// class HomePageCareGiver extends StatefulWidget {
//   const HomePageCareGiver({super.key});

//   @override
//   State<HomePageCareGiver> createState() => _HomePageCareGiverState();
// }

// class _HomePageCareGiverState extends State<HomePageCareGiver> {
//   String username = '';

//   String jwtToken = 'your_jwt_token_here'; // Replace with actual JWT token

//   Future<void> fetchUsername() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:8000/users/Showusername'),
//         headers: {
//           'Authorization': 'Bearer $jwtToken',
//         },
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = json.decode(response.body);
//         setState(() {
//           username = responseData['username'];
//         });
//       } else if (response.statusCode == 401) {
//         // Handle unauthorized error
//         setState(() {
//           username = 'Guest'; // Set default username to 'Guest'
//         });
//         print('Unauthorized: ${response.statusCode}');
//       } else {
//         // Handle other HTTP errors
//         print('Failed to load username: ${response.statusCode}');
//         setState(() {
//           username = 'Guest'; // Set default username to 'Guest'
//         });
//       }
//     } catch (e) {
//       // Handle network or decoding errors
//       setState(() {
//         username = 'Guest'; // Set default username to 'Guest'
//       });
//       print('Error fetching username: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchUsername();
//   }

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
//         Padding(
//           padding: EdgeInsets.only(top: 80.0, left: 50.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               //1 Hello user
//               Padding(
//                 padding: EdgeInsets.only(),
//                 child: Text(
//                   'Hello, ${username.isNotEmpty ? username : 'Guest'}',
//                   // "Hi, ${user.displayName ?? 'Guest'}",
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 32,
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
//                     fontFamily: 'Poppins',
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               //3 select under care
//               Padding(
//                 padding: EdgeInsets.only(top: 20.0, left: 0.0),
//                 child: Row(
//                   children: [
//                     Text(
//                       'Your under care',
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(width: 20),
//                     UnderCareBox(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // White box
//         Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 220.0),
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
//                     padding: EdgeInsets.only(top: 250, left: 20.0, right: 20.0),
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
//                 // Positioned(
//                 //   left: 20.0,
//                 //   right: 20.0,
//                 //   child: Padding(
//                 //     padding: EdgeInsets.only(top: 0.5, left: 20.0, right: 20.0),
//                 //     child: PillsCardCareGiver(),
//                 //   ),
//                 // ),
//               ],
//             )
//           ],
//         ),
//       ]),
//     ));
//   }
// }

// //Undercare Box
// class UnderCareBox extends StatelessWidget {
//   const UnderCareBox({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 30,
//       padding: const EdgeInsets.symmetric(horizontal: 40),
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
//       child: const Center(
//         child: Text(
//           'grandmom',
//           style: TextStyle(
//             color: Color.fromARGB(255, 255, 255, 255),
//             fontSize: 12,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }
