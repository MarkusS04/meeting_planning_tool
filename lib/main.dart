import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/api.dart';
import 'package:meeting_planning_tool/screens/startup.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiData.initalize();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('theme');
  ThemeMode mode = ThemeMode.system;
  if (theme != null) {
    switch (theme) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }
  }
  runApp(StartPageScreen(initTheme: mode));
}
