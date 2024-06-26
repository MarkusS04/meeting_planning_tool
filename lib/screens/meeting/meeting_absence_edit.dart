import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeetingAbseneEdit extends StatefulWidget {
  final List<Person> people;
  final List<int> peopleSelected;
  const MeetingAbseneEdit(
      {super.key, required this.people, required this.peopleSelected});

  @override
  State<MeetingAbseneEdit> createState() => _MeetingAbseneEditState();
}

class _MeetingAbseneEditState extends State<MeetingAbseneEdit> {
  late List<int> selectedPeople;
  late List<int> previouSelected;
  List<int> deselectedPeople = [];

  @override
  void initState() {
    super.initState();
    selectedPeople = List.from(widget.peopleSelected);
    previouSelected = List.from(widget.peopleSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).editAbsence),
      content: SingleChildScrollView(
        child: _buildContent(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            for (var i in previouSelected) {
              selectedPeople.remove(i);
            }
            Navigator.of(context).pop([selectedPeople, deselectedPeople]);
          },
          child: Text(MaterialLocalizations.of(context).saveButtonLabel),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (MediaQuery.of(context).size.width > 600) {
      // For larger screens
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).available,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Makes text bold
                  fontSize: 20.0, // Increases font size
                ),
              ),
              ..._buildAvailablePeople(),
            ],
          )),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).absence,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Makes text bold
                  fontSize: 20.0, // Increases font size
                ),
              ),
              ..._buildAbsentPeople(),
            ],
          ))
        ],
      );
    } else {
      // For smaller screens
      return Column(
        children: [
          Text(
            AppLocalizations.of(context).available,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Makes text bold
              fontSize: 20.0, // Increases font size
            ),
          ),
          ..._buildAvailablePeople(),
          Text(
            AppLocalizations.of(context).absence,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Makes text bold
              fontSize: 20.0, // Increases font size
            ),
          ),
          ..._buildAbsentPeople(),
        ],
      );
    }
  }

  List<Widget> _buildAvailablePeople() {
    return widget.people.map((person) {
      if (!selectedPeople.contains(person.id)) {
        return InkWell(
          onTap: () {
            setState(() {
              if (selectedPeople.contains(person.id)) {
                selectedPeople.remove(person.id);
                if (previouSelected.contains(person.id)) {
                  deselectedPeople.add(person.id);
                }
              } else {
                deselectedPeople.remove(person.id);
                selectedPeople.add(person.id);
              }
            });
          },
          child: ListTile(
            title: Text('${person.givenName} ${person.lastName}'),
          ),
        );
      } else {
        return Container(); // Already selected, don't display
      }
    }).toList();
  }

  List<Widget> _buildAbsentPeople() {
    return widget.people.map((person) {
      if (selectedPeople.contains(person.id)) {
        return InkWell(
          onTap: () {
            setState(() {
              // Toggle selection
              if (selectedPeople.contains(person.id)) {
                selectedPeople.remove(person.id);
                if (previouSelected.contains(person.id)) {
                  deselectedPeople.add(person.id);
                }
              } else {
                deselectedPeople.remove(person.id);
                selectedPeople.add(person.id);
              }
            });
          },
          child: ListTile(
            title: Text('${person.givenName} ${person.lastName}'),
          ),
        );
      } else {
        return Container(); // Not selected, don't display
      }
    }).toList();
  }
}
