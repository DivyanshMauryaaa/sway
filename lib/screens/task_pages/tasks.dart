import 'package:flutter/material.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksStatePage();
}

class _TasksStatePage extends State<TasksPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(7),
      child: Column(
        children: [

          Text("Your Tasks will be displayed here")

        ],
      ),
    );
  }
}