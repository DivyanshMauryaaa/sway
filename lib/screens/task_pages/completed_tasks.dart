import 'package:flutter/material.dart';

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _TasksStatePage();
}

class _TasksStatePage extends State<CompletedTasks> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(7),
      child: Column(
        children: [

          Text("Your Completed Tasks will be displayed here")

        ],
      ),
    );
  }
}