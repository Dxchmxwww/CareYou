import 'package:flutter/material.dart';

class CreatePillsCard extends StatelessWidget {
  const CreatePillsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Card(
        child: Container(
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 6.5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Uncomment this section if you have a PillsImage widget
              // Padding(
              //   padding: EdgeInsets.all(screenWidth * 0.02),
              //   child: Container(
              //     width: screenWidth * 0.18,
              //     height: screenWidth * 0.18,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(5),
              //     ),
              //     child: const PillsImage(),
              //   ),
              // ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 5.0, left: 15.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          screenWidth,
                          'Medication Name:',
                          'Type pill name, treat for, label',
                          context,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildTextField(
                          screenWidth,
                          'Note:',
                          'Add more detail',
                          context,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    double screenWidth,
    String labelText,
    String hintText,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00916E),
          ),
        ),
        Expanded(
          child: Container(
            height: 25,
            margin: EdgeInsets.symmetric(
                horizontal: 10), // Adjust horizontal margin
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF00916E), // Underline color
                  width: 1, // Underline width
                ),
              ),
            ),
            child: TextFormField(
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Color(0xFF999797),
                  fontSize: 12,
                ),
                border: InputBorder.none, // Remove default border
                contentPadding: EdgeInsets.only(left: 5.0, bottom: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
