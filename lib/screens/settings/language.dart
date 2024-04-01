import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meeting_planning_tool/l10n/lang.dart';
import 'package:meeting_planning_tool/screens/startup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetLanguageWidget extends StatefulWidget {
  final Locale locale;
  const SetLanguageWidget({super.key, required this.locale});

  @override
  State<SetLanguageWidget> createState() => _SetLanguageWidgetState();
}

class _SetLanguageWidgetState extends State<SetLanguageWidget> {
  late Locale _locale;
  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).lang),
      trailing: DropdownButton<Locale>(
        value: _locale,
        onChanged: (Locale? lang) async {
          if (lang != null) {
            _locale = lang;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            setState(() {
              prefs.setString('langCode', _locale.languageCode);
              StartPageScreenState.setLocale(context, _locale);
              FocusScope.of(context).requestFocus(FocusNode());
            });
          }
        },
        items: AppLocalizations.supportedLocales
            .map<DropdownMenuItem<Locale>>((Locale locale) {
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Text(langs[locale.languageCode] ?? locale.languageCode),
          );
        }).toList(),
      ),
    );
  }
}
