import 'package:careyou/components/pillsCard.dart';
<<<<<<< Updated upstream
import 'package:careyou/pages/pillsManageCreatePage.dart';
=======
>>>>>>> Stashed changes
import 'package:flutter/material.dart';

class PillsmanagePageCareGiver extends StatefulWidget {
  final String token;

  const PillsmanagePageCareGiver({required this.token});

  @override
  State<PillsmanagePageCareGiver> createState() =>
      _PillsmanagePageCareGiverState();
}

class _PillsmanagePageCareGiverState extends State<PillsmanagePageCareGiver> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEditMode) {
          setState(() {
            isEditMode = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
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
<<<<<<< Updated upstream
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PillsmanageCreatePage(),
                                ),
                              );
=======
                              // Navigator.push(
                              //   context,
                              //   // MaterialPageRoute(
                              //   //   builder: (context) => PillsmanageCreatePage(),
                              //   // ),
                              // );
>>>>>>> Stashed changes
                            }
                            isEditMode = !isEditMode;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF54900),
<<<<<<< Updated upstream
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
=======
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // minimumSize: Size(double.infinity, 0.3),
>>>>>>> Stashed changes
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEditMode ? Icons.add : Icons.edit,
<<<<<<< Updated upstream
                              size: 12,
=======
                              size: 14,
>>>>>>> Stashed changes
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              isEditMode ? 'Add' : 'Edit',
                              style: TextStyle(
                                fontFamily: 'Poppins',
<<<<<<< Updated upstream
                                fontSize: 12,
=======
                                fontSize: 15,
>>>>>>> Stashed changes
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
<<<<<<< Updated upstream
      preferredSize: const Size.fromHeight(80.0),
      child: Container(
        color: const Color(0xFF00916E),
        padding: const EdgeInsets.only(top: 20),
=======
      preferredSize: const Size.fromHeight(70.0),
      child: Container(
        color: const Color(0xFF00916E),
        padding: const EdgeInsets.only(top: 10),
>>>>>>> Stashed changes
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Pills management",
            style: TextStyle(
              fontFamily: 'Poppins',
<<<<<<< Updated upstream
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
=======
              fontSize: 22,
              fontWeight: FontWeight.w700,
>>>>>>> Stashed changes
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }
}
