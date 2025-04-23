import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'task.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksStatePage();
}

class _TasksStatePage extends State<TasksPage> {
  final _database = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  TextEditingController _dateSetController = TextEditingController();
  User? user;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _dateSetController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateSetController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(7),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dateSetController.text.isEmpty ? 'Today' : _dateSetController.text,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _selectDate(context),
                icon: Icon(Icons.calendar_month),
                color: Colors.blue.shade800,
              ),
            ],
          ),

          FutureBuilder<QuerySnapshot>(
            future: _database
                .collection('Tasks')
                .where('user_id', isEqualTo: user?.uid)
                .where('completed', isEqualTo: false)
                .where('task_date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: \${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No tasks found');
              }
              final tasks = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskPage(
                            taskId: snapshot.data!.docs[index].id,
                            taskName: tasks[index]['title'],
                            taskDescription: tasks[index]['description'],
                            taskStatus: tasks[index]['status'],
                            taskPriority: tasks[index]['priority'],
                            taskDueDate: tasks[index]['due_date'],
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    title: Text(
                      tasks[index]['title'] ?? 'No Title',
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      tasks[index]['description'] ?? 'No Description',
                      maxLines: 2,
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: tasks[index]['priority'] == 'High'
                            ? Colors.red.shade700
                            : tasks[index]['priority'] == 'Medium'
                                ? const Color.fromARGB(255, 192, 139, 6)
                                : tasks[index]['priority'] == 'Low'
                                    ? Colors.green.shade700
                                    : Colors.grey.shade800,
                      ),
                      child: Text(
                        tasks[index]['priority'] ?? 'No Priority set',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    leading: Checkbox(
                      value: tasks[index]['completed'] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          tasks[index]['completed'] = value ?? false;
                        });
                        _database
                            .collection('Tasks')
                            .doc(snapshot.data!.docs[index].id)
                            .update({'completed': value ?? false});
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}