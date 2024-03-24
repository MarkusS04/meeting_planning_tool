import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/person/person.dart';

class PersonDropdown extends StatefulWidget {
  final List<Person> personsAvailable;
  final Person initialSelectedPerson;
  final int planId;

  const PersonDropdown({
    super.key,
    required this.personsAvailable,
    required this.initialSelectedPerson,
    required this.planId,
  });

  @override
  State<PersonDropdown> createState() => _PersonDropdownState();
}

class _PersonDropdownState extends State<PersonDropdown> {
  late Person selectedPerson;

  @override
  void initState() {
    selectedPerson = widget.initialSelectedPerson;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Person'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<Person>(
            value: selectedPerson,
            onChanged: (newValue) {
              setState(() {
                selectedPerson = newValue!;
              });
            },
            items: widget.personsAvailable.map((person) {
              return DropdownMenuItem<Person>(
                value: person,
                child: Text('${person.givenName} ${person.lastName}'),
              );
            }).toList(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            ApiService.putData(context, 'plan/${widget.planId}',
                {'id': selectedPerson.id}, (p0) => null);
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
