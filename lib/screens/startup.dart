import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/models/api.dart';
import 'package:meeting_planning_tool/screens/home.dart';
import 'package:meeting_planning_tool/screens/settings/settings.dart';
import 'package:meeting_planning_tool/screens/user/login.dart';
import 'package:meeting_planning_tool/screens/meeting/meeting_overview.dart';
import 'package:meeting_planning_tool/screens/person/person.dart';
import 'package:meeting_planning_tool/screens/plan/plan.dart';
import 'package:meeting_planning_tool/screens/task/task_overview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StartPageScreen extends StatefulWidget {
  const StartPageScreen(
      {super.key, required this.initTheme, required this.locale});

  final ThemeMode initTheme;
  final Locale locale;

  @override
  State<StartPageScreen> createState() => StartPageScreenState();
}

class StartPageScreenState extends State<StartPageScreen> {
  static ThemeMode? _theme;
  static Locale? _locale;
  void _setTheme(ThemeMode mode) {
    setState(() {
      _theme = mode;
    });
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  static void setTheme(BuildContext context, ThemeMode theme) {
    if (context.mounted) {
      StartPageScreenState? state =
          context.findAncestorStateOfType<StartPageScreenState>();
      if (state != null) {
        state._setTheme(theme);
      }
    }
  }

  static void setLocale(BuildContext context, Locale locale) {
    StartPageScreenState? state =
        context.findAncestorStateOfType<StartPageScreenState>();
    if (state != null) {
      state._setLocale(locale);
    }
  }

  @override
  void initState() {
    super.initState();
    _theme = widget.initTheme;
    _locale = widget.locale;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
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
