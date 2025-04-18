import 'package:flutter/material.dart';

class Reminders extends StatefulWidget {
  const Reminders({super.key});

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(18),
      child: Column(
        children: [

          Text('Reminders', style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 28,
            fontWeight: FontWeight.w600
          ),)

        ],
      ),
    );
  }
}