import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/api.dart';
import 'package:meeting_planning_tool/screens/home.dart';
import 'package:meeting_planning_tool/screens/settings/settings.dart';
import 'package:meeting_planning_tool/screens/user/login.dart';
import 'package:meeting_planning_tool/screens/meeting/meeting_overview.dart';
import 'package:meeting_planning_tool/screens/person/person.dart';
import 'package:meeting_planning_tool/screens/plan/plan.dart';
import 'package:meeting_planning_tool/screens/task/task_overview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPageScreen extends StatefulWidget {
  const StartPageScreen({super.key, required this.initTheme});

  final ThemeMode initTheme;

  @override
  State<StartPageScreen> createState() => StartPageScreenState();
}

class StartPageScreenState extends State<StartPageScreen> {
  static ThemeMode? _theme;
  void _setTheme(ThemeMode mode) {
    setState(() {
      _theme = mode;
    });
  }

  static void setTheme(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('theme');
    if (context.mounted) {
      StartPageScreenState? state =
          context.findAncestorStateOfType<StartPageScreenState>();
      if (state != null) {
        ThemeMode mode = ThemeMode.system;
        if (url != null) {
          if (url == "light") {
            mode = ThemeMode.light;
          } else if (url == "dark") {
            mode = ThemeMode.dark;
          }
        }
        state._setTheme(mode);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _theme = widget.initTheme;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Planning Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: _theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthenticationWrapper(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/people': (context) => const PersonListPage(),
        '/meeting': (context) => const MeetingPage(),
        '/task': (context) => const TaskPage(),
        '/plan': (context) => const PlanPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    bool isValidToken = ApiData.isTokenValid();

    if (isValidToken) {
      return const HomePage();
    } else {
      // Navigate to login page
      return const LoginPage();
    }
  }
}
