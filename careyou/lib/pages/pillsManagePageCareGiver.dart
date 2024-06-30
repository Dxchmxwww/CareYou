import 'package:careyou/components/pillsCard.dart';
import 'package:flutter/material.dart';
import 'package:careyou/pages/pillsManageCreatePage.dart';
import 'package:careyou/components/navbar.dart';

class PillsManagePageCareGiver extends StatefulWidget {
  final String token;
  final String selectedRole;

  const PillsManagePageCareGiver({
    required this.token,
    required this.selectedRole,
  });

  @override
  State<PillsManagePageCareGiver> createState() =>
      _PillsManagePageCareGiverState();
}

class _PillsManagePageCareGiverState extends State<PillsManagePageCareGiver> {
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    print('Bearer Token received: ${widget.token}');
    // Other initialization logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF00916E),
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Medication management',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (isEditMode) {
            setState(() {
              isEditMode = false;
            });
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (isEditMode) {
                              // Navigate to PillsmanageCreatePage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PillsmanageCreatePage(
                                    token: widget.token,// Adjust initial index as needed
                                    selectedRole: widget.selectedRole,
                                  ),
                                ),
                              );
                            }
                            isEditMode = !isEditMode;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF54900),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEditMode ? Icons.add : Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              isEditMode ? 'Add' : 'Edit',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    PillsCard(isEditMode: isEditMode, token: widget.token),
                    // Add other components/widgets as needed
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: NavBar(
        token: widget.token,
        initialIndex: 1, // Adjust initial index as needed
        selectedRole: widget.selectedRole,
      ),
    );
  }
}
