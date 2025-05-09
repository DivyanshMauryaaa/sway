import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _TasksStatePage();
}

class _TasksStatePage extends State<CompletedTasks> {
  final _database = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(7),
      child: Column(
        children: [
          FutureBuilder<QuerySnapshot>(
            future:
                _database
                    .collection('Tasks')
                    .where('user_id', isEqualTo: user?.uid).where('completed', isEqualTo: true)
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No completed tasks found');
              }
              final tasks =
                  snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
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
                        color:
                            tasks[index]['priority'] == 'High'
                                ? Colors.red.shade700
                                : tasks[index]['priority'] == 'Medium'
                                ? const Color.fromARGB(255, 192, 139, 6)
                                : tasks[index]['priority'] == 'Low'
                                ? Colors.green.shade700
                                : Colors.black,
                      ),

                      child: Text(
                        tasks[index]['priority'] ?? 'No Priority',
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
