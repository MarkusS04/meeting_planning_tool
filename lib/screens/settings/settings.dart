import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/api.dart';
import 'package:meeting_planning_tool/screens/navbar.dart';
import 'package:meeting_planning_tool/screens/settings/apperance.dart';
import 'package:meeting_planning_tool/screens/settings/change_api.dart';
import 'package:meeting_planning_tool/screens/settings/language.dart';
import 'package:meeting_planning_tool/screens/settings/version.dart';
import 'package:meeting_planning_tool/screens/user/change_pw.dart';
import 'package:meeting_planning_tool/widgets/settings_group.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.settings),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          SettingGroup(
            title: locale.apperance,
            settingItems: [
              const SetApperance(),
              SetLanguageWidget(
                locale: Localizations.localeOf(context),
              )
            ],
          ),
          SettingGroup(
            title: locale.appInfo,
            settingItems: const [VersionView()],
          ),
          SettingGroup(title: locale.user, settingItems: [
            ListTile(
                title: Text(locale.changepw),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const PasswordChangeDialog();
                      });
                }),
            ListTile(
              title: Text(locale.apiUrl),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const UpdateApiUrlDialog();
                    });
              },
            ),
            ListTile(
              title: Center(
                  child: Text(
                locale.logout,
              )),
              onTap: () {
                ApiData.authToken = null;
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ]),
        ]),
      )),
      bottomNavigationBar: const BottomNavBar(currentIndex: 5),
    );
  }
}
