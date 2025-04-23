import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './task_pages/completed_tasks.dart';
import './task_pages/tasks.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final _database = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              'Tasks',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 10),

            DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue.shade800,
                    tabs: [Tab(text: 'Tasks'), Tab(text: 'Completed Tasks')],
                  ),
                  SizedBox(
                    height: 600, // Adjust height as needed
                    child: TabBarView(
                      children: [TasksPage(), CompletedTasks()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final formKey = GlobalKey<FormState>();
          final TextEditingController titleController = TextEditingController();
          final TextEditingController descriptionController =
              TextEditingController();
          String? selectedPriority;
          final TextEditingController _dateController = TextEditingController();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                scrollable: true,
                insetPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 24,
                ),
                content: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Task',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Task Title',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Task title is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Task Description (optional)',
                                border: OutlineInputBorder(),
                              ),
                              minLines: 3,
                              maxLines: 20,
                            ),
                            SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  ['High', 'Medium', 'Low']
                                      .map(
                                        (priority) => DropdownMenuItem(
                                          value: priority,
                                          child: Text(priority),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                selectedPriority = value;
                              },
                            ),
                            SizedBox(height: 20),

                            TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(),
                              ),
                              enabled: false,
                              readOnly: true,
                            ),

                            TextButton(
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  // 🎯 Use pickedDate however you want (setState, store in DB, etc.)
                                  _dateController.text =
                                      DateFormat('yyyy-MM-dd').format(pickedDate);
                                }
                              },
                              child: Text("Pick Due Date"),
                            ),

                            SizedBox(height: 20),

                            FilledButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final taskTitle = titleController.text;
                                  final taskDescription =
                                      descriptionController.text;
                                  final taskPriority = selectedPriority;

                                  // Handle the form submission logic here
                                  await _database
                                      .collection("Tasks")
                                      .add(<String, dynamic>{
                                        'title': taskTitle,
                                        'description': taskDescription,
                                        'priority': taskPriority,
                                        'completed': false,
                                        'user_id': user?.uid,
                                        'due_date': _dateController.text,
                                        'task_date': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
                                      });

                                  Navigator.pop(context);
                                }
                              },
                              child: Text('Add Task'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
