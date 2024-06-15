import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';

class sign_up_page extends StatefulWidget {
  const sign_up_page();

  @override
  State<sign_up_page> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<sign_up_page> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';
  String _elderEmail = '';
  String _relation = '';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      title: 'UserBoarding',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF00916E),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF00916E),
          ),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0, left: 20.0),
                        child: Image.asset(
                          'assets/images/plain_design.png',
                          width: 120,
                          height: 122,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: Text(
                          'CARE YOU',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 0.0),
                        child: Text(
                          'Creating Account',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 160.0),
                        child: Container(
                          width: double.infinity,
                          height: screenHeight - 470.0,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                    child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 240),
                    child: Container(
                      width: 280,
                      height: 290,
                      child: Image.asset(
                        'assets/images/BoardBrad.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ])),
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 470),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email*',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF00916E),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.contains('@')) {
                                      return null;
                                    } else {
                                      return 'Please enter a valid email address';
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _email = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Username*',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF00916E),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'Please set username';
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _username = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password*',
                                    labelStyle: TextStyle(
                                      color: Color(0xFF00916E),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF00916E)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'Please enter your password';
                                    }
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _password = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 25),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState != null &&
                                        _formKey.currentState!.validate()) {
                                      _showPinDialog();
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      const Color(0xFF00916E),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                RichText(
                                  text: TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Log in',
                                        style: TextStyle(
                                          color: Color(0xFF00916E),
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamed(
                                                context, '/login');
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPinDialog() {
    final _elderEmailController = TextEditingController();
    final _relationController = TextEditingController();
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(40),
          content: Form(
            key: _dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: SvgPicture.asset(
                    'assets/images/partner.svg',
                    color: Color(0xFF00916E),
                    width: 80,
                    height: 80,
                  ),
                ),
                Text(
                  'Elder Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _elderEmailController,
                  decoration: InputDecoration(
                    labelText: "Elder's Email*",
                    labelStyle: TextStyle(
                      color: Color(0xFF00916E),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF00916E),
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF00916E),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.contains('@')) {
                      return null;
                    } else {
                      return 'Please enter a valid email address';
                    }
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _relationController,
                  decoration: InputDecoration(
                    labelText: 'Relation*',
                    labelStyle: TextStyle(
                      color: Color(0xFF00916E),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF00916E),
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF00916E),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return null;
                    } else {
                      return 'Please enter relation';
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_dialogFormKey.currentState != null &&
                      _dialogFormKey.currentState!.validate()) {
                    String elderEmail = _elderEmailController.text;
                    String relation = _relationController.text;
                    print('Elder Email: $elderEmail');
                    print('Relation: $relation');
                    Navigator.of(context).pop();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color(0xFF00916E),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
