import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/widgets/navbar.dart';
import 'package:meeting_planning_tool/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).home),
      ),
      body: Center(
        child: Text(
            '${AppLocalizations.of(context).welcomeback}: ${User.username}!'),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
