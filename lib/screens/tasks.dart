import 'package:flutter/material.dart';
import './task_pages/completed_tasks.dart';
import './task_pages/tasks.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
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
          final _formKey = GlobalKey<FormState>();
          final TextEditingController _titleController =
              TextEditingController();
          final TextEditingController _descriptionController =
              TextEditingController();
          String? _selectedPriority;

          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
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
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _titleController,
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
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Task Description (optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
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
                              _selectedPriority = value;
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final taskTitle = _titleController.text;
                                final taskDescription =
                                    _descriptionController.text;
                                final taskPriority = _selectedPriority;

                                // Handle the form submission logic here
                                print('Task Title: $taskTitle');
                                print('Task Description: $taskDescription');
                                print('Task Priority: $taskPriority');

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
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
