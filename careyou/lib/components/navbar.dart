import 'package:careyou/pages/app_manage.dart';
import 'package:careyou/pages/caregiver_appointmentOFelder.dart';
import 'package:careyou/pages/caregiver_profile.dart';
import 'package:careyou/pages/elder_appointment.dart';
import 'package:careyou/pages/homePageCareGiver.dart';
import 'package:careyou/pages/pillBox.dart'; // Import caregiver appointment page
import 'package:careyou/pages/pillBoxs_caregiver.dart'; // Import caregiver pill box page
import 'package:careyou/pages/pillsManagePageCareGiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careyou/pages/homePageElder.dart';
import 'package:careyou/pages/elder_profile.dart';

class NavBar extends StatefulWidget {
  final String token;
  final int initialIndex;
  final String selectedRole;

  const NavBar({
    required this.token,
    this.initialIndex = 0,
    required this.selectedRole,
  });

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<String> iconPaths = [
    'assets/images/home.svg',
    'assets/images/pill.svg',
    'assets/images/emergency.svg',
    'assets/images/prescriptions.svg',
    'assets/images/account.svg',
  ];

  final List<Color> defaultColors = [
    Colors.black54,
    Colors.black54,
    Colors.black54,
    Colors.black54,
    Colors.black54,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _defaultOnPressed(index);
  }

  void _defaultOnPressed(int index) {
    switch (index) {
      case 0:
        if (widget.selectedRole == 'Elderly') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageElder(
                token: widget.token,
                selectedRole: widget.selectedRole,
              ),
            ),
          );
        } else if (widget.selectedRole == 'Caregiver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageCareGiver(
                token: widget.token,
                selectedRole: widget.selectedRole,
              ),
            ),
          );
        }
        break;
      case 1:
        if (widget.selectedRole == 'Elderly') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PillBox(
                token: widget.token,
                selectedRole: widget.selectedRole,
              ),
            ),
          );
        } else if (widget.selectedRole == 'Caregiver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PillsManagePageCareGiver(
                token: widget.token,
                selectedRole: widget.selectedRole,
              ),
            ),
          );
        }
        break;
      case 2:
        _call911();
        break;
      case 3:
        if (widget.selectedRole == 'Elderly') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentForElder(
                token: widget.token,
              ),
            ),
          );
        } else if (widget.selectedRole == 'Caregiver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AppManage(
                token: widget.token,
                selectedRole: widget.selectedRole,
              ),
            ),
          );
        }
        break;
      case 4:
        if (widget.selectedRole == 'Elderly') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => elder_profile_page(
                token: widget.token,
                selectedRole: widget.selectedRole,
              ),
            ),
          );
        } else if (widget.selectedRole == 'Caregiver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => caregiver_profile_page(
                token: widget.token,
                selectedRole: widget.selectedRole,
              ),
            ),
          );
        }
        break;
      default:
        break;
    }
  }

  Future<void> _call911() async {
    final url = 'tel:+66933041278';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110, // Reduce height to move the entire navbar up
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
      child: Padding(
        padding: const EdgeInsets.only(
            top: 0.0), // Adjust top padding to move icons up
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconButton(
              iconPaths[0],
              _selectedIndex == 0 ? Color(0xFF00916E) : defaultColors[0],
              () => _onItemTapped(0),
            ),
            _buildIconButton(
              iconPaths[1],
              _selectedIndex == 1 ? Color(0xFF00916E) : defaultColors[1],
              () => _onItemTapped(1),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Transform.translate(
                offset: const Offset(0, -35),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDC2B2B),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/emergency.svg',
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildIconButton(
              iconPaths[3],
              _selectedIndex == 3 ? Color(0xFF00916E) : defaultColors[3],
              () => _onItemTapped(3),
            ),
            _buildIconButton(
              iconPaths[4],
              _selectedIndex == 4 ? Color(0xFF00916E) : defaultColors[4],
              () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(String iconPath, Color color, Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: 10.0), // Adjust bottom padding to move icons up
      child: IconButton(
        icon: SvgPicture.asset(
          iconPath,
          width: 35,
          height: 35,
          color: color,
        ),
        onPressed: onPressed,
        iconSize: 35,
      ),
    );
  }
}
