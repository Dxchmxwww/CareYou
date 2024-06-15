import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCard extends StatefulWidget {
  final bool showButtons;

  const AppCard({Key? key, required this.showButtons}) : super(key: key);

  @override
  _AppCardState createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  void _showDeleteConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          surfaceTintColor: const Color(0xFFFFFFFF), // Set background color to white
          title: Text(
            "Delete Appointment",
            textAlign: TextAlign.center,  // Center the title text
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: const Color(0xFF000000),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,  // Center the column contents
            children: <Widget>[
              Text(
                "Are you sure you want to delete this appointment?",
                textAlign: TextAlign.center,  // Center the text content
                style: GoogleFonts.poppins(
                  fontSize: 11.12,
                  color: const Color(0xFF727070),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,  // Center the buttons
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDADADA),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  const SizedBox(width: 8),  // Add spacing between buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000),
                    ),
                    child: Text(
                      "Yes, Delete",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      // Perform delete operation here
                      print('Appointment deleted');
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Cardiology Consult',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF54900),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Color(0xFF00916E)),
                        const SizedBox(width: 4),
                        Text(
                          '24/06/2024   08:00 - 12:00',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(Icons.place_outlined, color: Color(0xFF00916E)),
                        const SizedBox(width: 4),
                        Text(
                          'BPK 1 Hospital',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.showButtons)
            Positioned(
              top: 15,
              right: 14,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle edit button action
                      print('Edit button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xFFFFB82D), // Yellow button color
                      minimumSize: const Size(60, 18), // Adjust button size
                      fixedSize: const Size(60, 18), // Set fixed size using width and height
                    ),
                    child: Container(
                      width: 60,
                      height: 18,
                      alignment: Alignment.center,
                      child: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 10, // Adjust font size
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  ElevatedButton(
                    onPressed: () {
                      // Show delete confirmation dialog
                      _showDeleteConfirmationDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xFFFF0000), // Red button color
                      minimumSize: const Size(60, 18), // Adjust button size
                      fixedSize: const Size(60, 18), // Set fixed size using width and height
                    ),
                    child: Container(
                      width: 60,
                      height: 18,
                      alignment: Alignment.center,
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontSize: 10, // Adjust font size
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // Text color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
