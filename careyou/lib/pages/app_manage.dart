import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:careyou/widgets/navbar.dart';
import 'package:careyou/widgets/app_card.dart';

class AppManage extends StatefulWidget {
  const AppManage({Key? key}) : super(key: key);

  @override
  _AppManageState createState() => _AppManageState();
}

class _AppManageState extends State<AppManage> {
  bool showEditDeleteButtons = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(106),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF00916E),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'Appointment Management',
                    style: GoogleFonts.poppins(
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today is Wed 24, 2024',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00916E),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // Toggle the state to show/hide edit and delete buttons
                              showEditDeleteButtons = !showEditDeleteButtons;
                            });
                          },
                          child: Container(
                            width: 71,
                            height: 21,
                            decoration: BoxDecoration(
                              color: Color(0xFFF54900),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                showEditDeleteButtons ? '+ Add' : 'Edit',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 30, left: 20, right: 20),
                      child: Column(
                        children: [
                          AppCard(
                            showButtons: showEditDeleteButtons,
                          ),
                          const SizedBox(height: 35),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: NavBar(),
              ),
            ],
          );
        },
      ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }
}
