import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/services/person_service.dart';

class AddPersonWidget extends StatelessWidget {
  AddPersonWidget({super.key});

  final TextEditingController _givenNameController =
      TextEditingController(text: "");
  final TextEditingController _lastNameController =
      TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).addPerson),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            onChanged: (value) {
              _givenNameController.text = value;
            },
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).givenname,
            ),
          ),
          TextField(
            onChanged: (value) {
              _lastNameController.text = value;
            },
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).lastname,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () async {
            addPerson(context, Person(givenName: _givenNameController.text, lastName: _lastNameController.text));
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(MaterialLocalizations.of(context).saveButtonLabel),
        ),
      ],
    );
  }
}
