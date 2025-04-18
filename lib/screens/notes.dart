import 'package:flutter/material.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(18),
      child: Column(
        children: [

          Text('Notes', style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 28,
            fontWeight: FontWeight.w600
          ),)

        ],
      ),
    );
  }
}