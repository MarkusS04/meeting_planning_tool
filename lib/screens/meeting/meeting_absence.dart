import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/person/person.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeetingAbsenceView extends StatelessWidget {
  final Future<List<Person>> people;
  const MeetingAbsenceView({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: people,
        builder: (context, snapshot) {
          List<Person>? people = snapshot.data;
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${AppLocalizations.of(context).absence}:'),
                  ...(people == null || people.isEmpty
                      ? [Text(AppLocalizations.of(context).noData)]
                      : people.map((person) {
                          final name = '${person.givenName} ${person.lastName}';
                          return ListTile(title: Text(name));
                        }).toList())
                ],
              ));
        });
  }
}
