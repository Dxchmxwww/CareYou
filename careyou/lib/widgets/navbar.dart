import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,  
        ),
        Container(
          height: 87,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black87.withOpacity(0.1), 
                offset: const Offset(0, -4), 
                blurRadius: 6, 
                spreadRadius: 0, 
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                iconSize: 35,
              ),
              IconButton(
                icon: const Icon(Icons.medication_liquid_sharp),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                iconSize: 35,
              ),
              Transform.translate(
                offset: const Offset(0, -30), 
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDC2B2B),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.phone_in_talk_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    color: Colors.white,
                    iconSize: 45,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.my_library_books_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                iconSize: 35,
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                iconSize: 35,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
