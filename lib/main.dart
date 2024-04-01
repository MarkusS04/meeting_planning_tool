import 'package:flutter/material.dart';
import 'dart:io';
import 'package:meeting_planning_tool/models/api.dart';
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
  runApp(StartPageScreen(
    initTheme: mode,
    locale: _getLocale(prefs),
  ));
}

Locale _getLocale(SharedPreferences prefs) {
  final String? langCode = prefs.getString('langCode');
  if (langCode != null) {
    return Locale(langCode, prefs.getString('countryCode'));
  }

  final locale = Platform.localeName;
  RegExp regex = RegExp(r'^([a-z]{2})(?:_([A-Z]{2}))?');
  Match? match = regex.firstMatch(locale);

  if (match != null) {
    String? langCode = match.group(1);
    String? countryCode = match.group(2);
    if (langCode != null) {
      return Locale(langCode, countryCode);
    }
  }

  return const Locale('en', 'EN');
}
