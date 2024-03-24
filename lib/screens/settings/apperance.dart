import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/screens/startup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetApperance extends StatefulWidget {
  const SetApperance({super.key});

  @override
  State<SetApperance> createState() => _SetApperanceState();
}

class _SetApperanceState extends State<SetApperance> {
  late SharedPreferences _prefs;
  late String _theme;
  late List<bool> _selections;

  @override
  void initState() {
    super.initState();
    _selections = [false, false, false];
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final t = _prefs.getString('theme');
    _theme = t ?? "system";
    _updateSelections();
  }

  void _updateSelections() {
    switch (_theme) {
      case "light":
        _selections = [true, false, false];
        break;
      case "dark":
        _selections = [false, true, false];
        break;
      case "system":
      default:
        _selections = [false, false, true];
    }
  }

  void _onToggle(int index) async {
    switch (index) {
      case 0:
        _theme = "light";
        break;
      case 1:
        _theme = "dark";
        break;
      case 2:
        _theme = "system";
        break;
    }
    StartPageScreenState.setTheme(context);
    await _prefs.setString('theme', _theme);
    setState(() {
      _updateSelections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return ListTile(
              title: const Text('Switch Theme'),
              trailing: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ToggleButtons(
                  isSelected: _selections,
                  onPressed: _onToggle,
                  children: const [
                    Icon(Icons.light_mode),
                    Icon(Icons.dark_mode),
                    Icon(Icons.phone_android)
                  ],
                ),
              ));
        }
      },
    );
  }
}
