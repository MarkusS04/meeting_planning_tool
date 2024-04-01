import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/screens/startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    ThemeMode mode;
    switch (index) {
      case 0:
        _theme = "light";
        mode = ThemeMode.light;
        break;
      case 1:
        _theme = "dark";
        mode = ThemeMode.dark;
        break;
      default:
        _theme = "system";
        mode = ThemeMode.system;
        break;
    }

    StartPageScreenState.setTheme(context, mode);
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
              title: Text(AppLocalizations.of(context).changeTheme),
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
