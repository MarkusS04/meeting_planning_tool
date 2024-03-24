import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentIndex});

  final int currentIndex; // Add this property

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'People',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_calendar),
          label: 'Meeting',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_outlined),
          label: 'Task',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Plan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.amber[800],
      onTap: (int index) {
        // Handle navigation
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/people');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/meeting');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/task');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/plan');
            break;
          case 5:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
        }
      },
    );
  }
}
