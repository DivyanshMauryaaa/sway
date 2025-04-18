import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(18),
      child: Column(
        children: [

          Text('Home', style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 28,
            fontWeight: FontWeight.w600
          ),)

        ],
      ),
    );
  }
}