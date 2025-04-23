import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String displayName = 'loading...';
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("user_id", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        displayName = querySnapshot.docs[0].data()['displayName'] ?? "Unknown";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(18),
      child: Column(
        children: [

          Text('Hello, $displayName', style: TextStyle(
            // color: Colors.grey.shade700,
            fontSize: 28,
            fontWeight: FontWeight.w600
          ),),

        ],
      ),
    );
  }
}