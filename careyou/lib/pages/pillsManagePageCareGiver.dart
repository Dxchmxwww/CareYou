import 'package:flutter/material.dart';
import 'package:careyou/components/pillsCard.dart';
import 'package:careyou/pages/pillsManageCreatePage.dart';

class PillsManagePageCareGiver extends StatefulWidget {
  final String token;

  const PillsManagePageCareGiver({required this.token});

  @override
  State<PillsManagePageCareGiver> createState() =>
      _PillsManagePageCareGiverState(token: token);
}

class _PillsManagePageCareGiverState extends State<PillsManagePageCareGiver> {
  final String token;

  _PillsManagePageCareGiverState({required this.token});
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    print('Bearer Token received: ${widget.token}');
    // Other initialization logic
  }

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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PillsmanageCreatePage(
                                      token: widget.token),
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
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: Container(
        color: const Color(0xFF00916E),
        padding: const EdgeInsets.only(top: 10),
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
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }
}
