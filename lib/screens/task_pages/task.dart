import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
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
                              .where('taskId', isEqualTo: widget.taskId)
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
            Text(
              widget.taskName.toString(),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 6),

            Text(
              widget.taskDescription.toString(),
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            Text(
              'Created by: ${user?.email}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              textAlign: TextAlign.center,
            ),

            Text(
              'Due Date: ${widget.taskDueDate}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _database
                      .collection('Tasks')
                      .doc(widget.taskId)
                      .update({
                        'task_name': nameController.text,
                        'description': descController.text,
                      });

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
