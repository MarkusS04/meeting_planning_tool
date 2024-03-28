import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context).home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: AppLocalizations.of(context).people,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.edit_calendar),
          label: AppLocalizations.of(context).meeting,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.task_outlined),
          label: AppLocalizations.of(context).task,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_outlined),
          label: AppLocalizations.of(context).plan,
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context).settings)
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
