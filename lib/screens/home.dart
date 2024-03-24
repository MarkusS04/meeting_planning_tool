import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/screens/navbar.dart';
import 'package:meeting_planning_tool/data/user.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Text("Welcome back: ${User.username}!\nEnjoy the programm"),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
