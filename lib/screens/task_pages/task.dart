import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatefulWidget {
  final dynamic taskId;
  final dynamic taskName;
  final dynamic taskDescription;
  final dynamic taskStatus;
  final dynamic taskPriority;
  final dynamic taskDueDate;

  const TaskPage({
    super.key,
    required this.taskId,
    required this.taskName,
    required this.taskDescription,
    required this.taskStatus,
    required this.taskPriority,
    required this.taskDueDate,
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _database = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  String? userName;
  late dynamic taskPriority;

  @override
  void initState() {
    super.initState();
    taskPriority = widget.taskPriority.toString();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData =
        await FirebaseFirestore.instance
            .collection('users')
            .where('user_id', isEqualTo: user?.uid)
            .get();

    setState(() {
      userName = userData.docs[0].data()['displayName'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.taskName.toString()),
        centerTitle: true,
        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  MediaQuery.of(context).size.width - 50,
                  70,
                  0,
                  0,
                ),
                items: [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(Duration.zero, () => _showEditDialog());
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                    onTap: () async {
                      final query =
                          await FirebaseFirestore.instance
                              .collection('Tasks')
                              .where('id', isEqualTo: widget.taskId)
                              .get();

                      if (query.docs.isNotEmpty) {
                        await query.docs[0].reference.delete();
                        if (mounted) {
                          setState(
                            () {},
                          ); // this tells Flutter to rebuild after deletion
                          Navigator.pop(context); // closes task detail
                        }
                      }
                    },
                  ),
                ],
              );
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(6),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade800),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text("Task"),
            ),

            Text(
              widget.taskName.toString(),
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.taskDescription.toString(),
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.person, color: Colors.grey.shade700),
                Text(
                  '$userName',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.grey.shade700),
                Text(
                  widget.taskDueDate.toString(),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(children: [
              Icon(widget.taskStatus ?? false ? Icons.cancel : Icons.check_circle),
              Text(
                widget.taskStatus ?? false ? 'Completed' : 'Not Completed',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16
                ),
              )
            ],),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    TextEditingController nameController = TextEditingController(
      text: widget.taskName,
    );
    TextEditingController descController = TextEditingController(
      text: widget.taskDescription,
    );

    TextEditingController dueDateController = TextEditingController(
      text: widget.taskDueDate,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: dueDateController,
                  decoration: InputDecoration(labelText: 'Due Date'),
                  enabled: true,
                  readOnly: true,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Priority'),
                  items:
                      ['Low', 'Medium', 'High']
                          .map(
                            (String priority) => DropdownMenuItem<String>(
                              value: priority,
                              child: Text(priority),
                            ),
                          )
                          .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      taskPriority = value;
                    });
                  },
                  value: taskPriority,
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );

                    if (pickedDate != null) {
                      dueDateController.text = DateFormat(
                        'yyyy-MM-dd',
                      ).format(pickedDate);
                    }
                  },
                  child: Text('Pick a new date'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final query =
                      await _database
                          .collection('Tasks')
                          .where('id', isEqualTo: widget.taskId)
                          .get();

                  if (query.docs.isNotEmpty) {
                    await query.docs[0].reference.update({
                      'title': nameController.text,
                      'description': descController.text,
                      'due_date': dueDateController.text,
                      'priority': taskPriority,
                    });
                  }

                  setState(() {}); // update UI
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }
}
