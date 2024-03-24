import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/api.dart';
import 'package:meeting_planning_tool/screens/navbar.dart';
import 'package:meeting_planning_tool/screens/settings/apperance.dart';
import 'package:meeting_planning_tool/screens/settings/change_api.dart';
import 'package:meeting_planning_tool/screens/settings/version.dart';
import 'package:meeting_planning_tool/screens/user/change_pw.dart';
import 'package:meeting_planning_tool/widgets/settings_group.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const SettingGroup(
              title: 'Apperance', settingItems: [SetApperance()]),
          const SettingGroup(title: 'App Info', settingItems: [VersionView()]),
          SettingGroup(title: 'User', settingItems: [
            ListTile(
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const PasswordChangeDialog();
                      });
                }),
            ListTile(
              title: const Text('Api URL'),
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
              title: const Center(child: Text('Logout')),
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
