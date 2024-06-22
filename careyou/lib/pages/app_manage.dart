// import 'package:flutter/material.dart';
// import 'package:careyou/widgets/navbar.dart';
// import 'package:careyou/widgets/app_card.dart';


// class AppManage extends StatefulWidget {
//   const AppManage({Key? key}) : super(key: key);

//   @override
//   _AppManageState createState() => _AppManageState();
// }

// class _AppManageState extends State<AppManage> {
//   bool showEditButton = true; // Initially show "Edit" button

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
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return Stack(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         left: 20.0, right: 20.0, top: 30.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Today is Wed 24, 2024',
//                           style: TextStyle(
//                             fontFamily: 'Poppins',
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xFF00916E),
//                           ),
//                           textAlign: TextAlign.left,
//                         ),
//                         Row(
//                           children: [
//                             if (showEditButton)
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     // Toggle the state to show/hide edit button
//                                     showEditButton = false;
//                                   });
//                                 },
//                                 child: Container(
//                                   width: 60,
//                                   height: 21,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF54900),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       'Edit',
//                                       style: TextStyle(
//                                         fontFamily: 'Poppins',
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             if (!showEditButton)
//                               GestureDetector(
//                                 onTap: () {
//                                   // Navigate to AddApp screen
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => const AddApp()),
//                                   );
//                                 },
//                                 child: Container(
//                                   width: 60,
//                                   height: 21,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFF54900),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       '+Add',
//                                       style: TextStyle(
//                                         fontFamily: 'Poppins',
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w500,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding:
//                           const EdgeInsets.only(top: 30, left: 20, right: 20),
//                       child: Column(
//                         children: [
//                           AppCard(
//                             showButtons: !showEditButton,
//                           ),
//                           const SizedBox(height: 35),
//                           // Additional widgets can be added here
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: NavBar(), // Renders the navigation bar at the bottom
//               ),
//             ],
//           );
//         },
//       ),
//       backgroundColor: const Color(0xFFFFFFFF),
//     );
//   }
// }
