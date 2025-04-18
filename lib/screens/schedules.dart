import 'package:flutter/material.dart';

class Schedules extends StatefulWidget {
  const Schedules({super.key});

  @override
  State<Schedules> createState() => _SchedulesState();
}

class _SchedulesState extends State<Schedules> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(18),
      child: Column(
        children: [

          Text('Schedules', style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 28,
            fontWeight: FontWeight.w600
          ),)

        ],
      ),
    );
  }
}