import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/medication');
        break;
      case 3:
        Navigator.pushNamed(context, '/books');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
      default:
        break;
    }
  }

  Future<void> _call911() async {
    final url = Uri.parse('tel:+123 456 789');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
    print('successful call');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,  // Adjust this height as needed
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
              _buildIconButton(
                'assets/images/home.svg',
                _selectedIndex == 0 ? Color(0xFF00916E) : Colors.black54,
                () => _onItemTapped(0),
              ),
              _buildIconButton(
                'assets/images/pill.svg',
                _selectedIndex == 1 ? Color(0xFF00916E) : Colors.black54,
                () => _onItemTapped(1),
              ),
              GestureDetector(
                onTap: _call911,
                child: Transform.translate(
                  offset: const Offset(0, -30),
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
                          width: 40,
                          height: 40,
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
                'assets/images/prescriptions.svg',
                _selectedIndex == 3 ? Color(0xFF00916E) : Colors.black54,
                () => _onItemTapped(3),
              ),
              _buildIconButton(
                null, // Placeholder for non-SvgPicture icon
                _selectedIndex == 4 ? Color(0xFF00916E) : Colors.black54,
                () => _onItemTapped(4),
                icon: Icon(
                  Icons.account_circle_outlined,
                  color: _selectedIndex == 4 ? Color(0xFF00916E) : Colors.black54,
                  size: 35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(String? iconPath, Color color, Function()? onPressed, {Icon? icon}) {
    Widget iconWidget;

    if (iconPath != null) {
      iconWidget = SvgPicture.asset(
        iconPath,
        width: 35,
        height: 35,
        color: color,
      );
    } else if (icon != null) {
      iconWidget = icon;
    } else {
      // Default fallback icon (could be an empty container or another default widget)
      iconWidget = Container();
    }

    return IconButton(
      icon: iconWidget,
      onPressed: onPressed,
      iconSize: 35,
    );
  }
}
