import 'package:flutter/material.dart';

class CreateSetReminder extends StatefulWidget {
  const CreateSetReminder({super.key});

  @override
  _CreateSetReminderState createState() => _CreateSetReminderState();
}

class _CreateSetReminderState extends State<CreateSetReminder> {
  List<String> pillTypes = [
    'After Meal',
    'Before Meal',
    'Take with meal',
  ];
  String? selectedPillType;
  DateTime? selectedDate1;
  DateTime? selectedDate2;
  DateTime picked = DateTime.now();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      child: Card(
        child: Container(
          width: screenWidth * 0.9,
          height: 160,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 6.5,
                spreadRadius: 2,
              ),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, left: 10, right: 10, bottom: 10),
              child: Text(
                'Set the Reminder',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00916E),
                ),
              ),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    'Duration:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedDate1 != null
                        ? const Color(0xFFF54900)
                        : const Color(0xFFD1D1D1),
                    shadowColor: const Color(0xFF9D9D9D),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 12.0,
                    ),
                    minimumSize: selectedDate1 != null
                        ? const Size(65, 35)
                        : const Size(65, 35),
                  ),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData(
                            brightness: Brightness.light,
                            primaryColor: const Color(0xFFF54900),
                            hintColor: Colors.black,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null && pickedDate != selectedDate1) {
                      setState(() {
                        selectedDate1 = pickedDate;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        selectedDate1 == null
                            ? 'date'
                            : selectedDate1!.toString().substring(0, 10),
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontFamily: 'Poppins',
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      if (selectedDate1 == null)
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    'to',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedDate2 != null
                        ? const Color(0xFFF54900)
                        : const Color(0xFFD1D1D1),
                    shadowColor: const Color(0xFF9D9D9D),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: 12.0,
                    ),
                    minimumSize: selectedDate1 != null
                        ? const Size(65, 35)
                        : const Size(65, 35),
                  ),
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData(
                            brightness: Brightness.light,
                            primaryColor: const Color(0xFFF54900),
                            hintColor: Colors.black,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null && pickedDate != selectedDate2) {
                      setState(() {
                        selectedDate2 = pickedDate;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        selectedDate2 == null
                            ? 'date'
                            : selectedDate2!.toString().substring(0, 10),
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontFamily: 'Poppins',
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      if (selectedDate2 == null)
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    'Repeat:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                DropdownRepeat(
                  options: [
                    '1 daily',
                    '2 daily',
                    '3 daily',
                    '4 daily',
                    '5 daily'
                  ],
                  dropdownBackgroundColor: const Color(0xFFF54900),
                )
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    'Set time reminder:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
                DropdownTime(
                  options: [
                    '1 time',
                    '2 times',
                    '3 times',
                    '4 times',
                    '5 times'
                  ],
                  dropdownBackgroundColor: const Color(0xFFF54900),
                ),
                const SizedBox(width: 10),
                DropdownPill(
                  options: [
                    '1 pill',
                    '2 pills',
                    '3 pills',
                    '4 pills',
                    '5 pills',
                    '6 pills',
                    '7 pills',
                    '8 pills',
                    '9 pills',
                    '10 pills',
                  ],
                  dropdownBackgroundColor: const Color(0xFFF54900),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

//dropdownRepeat
class DropdownRepeat extends StatefulWidget {
  final List<String> options;
  final Color dropdownBackgroundColor;

  const DropdownRepeat(
      {super.key,
      required this.options,
      required this.dropdownBackgroundColor});

  @override
  _DropdownRepeatState createState() => _DropdownRepeatState();
}

class _DropdownRepeatState extends State<DropdownRepeat> {
  late String _selectedOptionRepeat;

  @override
  void initState() {
    super.initState();
    _selectedOptionRepeat = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedOptionRepeat.isNotEmpty
            ? const Color(0xFFF54900)
            : const Color(0xFFD1D1D1),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              _selectedOptionRepeat.isNotEmpty ? _selectedOptionRepeat : null,
          hint: const Text(
            'select',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 10.0,
              fontFamily: 'Poppins',
            ),
          ),
          items: widget.options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 10.0,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedOptionRepeat = newValue ?? '';
            });
          },
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          dropdownColor: widget.dropdownBackgroundColor,
        ),
      ),
    );
  }
}

//2 dropdownTime
class DropdownTime extends StatefulWidget {
  final List<String> options;
  final Color dropdownBackgroundColor;

  const DropdownTime(
      {super.key,
      required this.options,
      required this.dropdownBackgroundColor});

  @override
  _DropdownTimeState createState() => _DropdownTimeState();
}

class _DropdownTimeState extends State<DropdownTime> {
  late String _selectedOptionTime;

  @override
  void initState() {
    super.initState();
    _selectedOptionTime = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedOptionTime.isNotEmpty
            ? const Color(0xFFF54900)
            : const Color(0xFFD1D1D1),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOptionTime.isNotEmpty ? _selectedOptionTime : null,
          hint: const Text(
            'time',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 10.0,
              fontFamily: 'Poppins',
            ),
          ),
          items: widget.options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 10.0,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedOptionTime = newValue ?? '';
            });
          },
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          dropdownColor: widget.dropdownBackgroundColor,
        ),
      ),
    );
  }
}

//2 dropdownPill
class DropdownPill extends StatefulWidget {
  final List<String> options;
  final Color dropdownBackgroundColor;

  const DropdownPill(
      {super.key,
      required this.options,
      required this.dropdownBackgroundColor});

  @override
  _DropdownPillState createState() => _DropdownPillState();
}

class _DropdownPillState extends State<DropdownPill> {
  late String _selectedOptionPill;

  @override
  void initState() {
    super.initState();
    _selectedOptionPill = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _selectedOptionPill.isNotEmpty
            ? const Color(0xFFF54900)
            : const Color(0xFFD1D1D1),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOptionPill.isNotEmpty ? _selectedOptionPill : null,
          hint: const Text(
            'take per time',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 10.0,
              fontFamily: 'Poppins',
            ),
          ),
          items: widget.options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 10.0,
                  fontFamily: 'Poppins',
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedOptionPill = newValue ?? '';
            });
          },
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          dropdownColor: widget.dropdownBackgroundColor,
        ),
      ),
    );
  }
}
