import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/services/api_service.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/models/task/task.dart';
import 'package:meeting_planning_tool/services/person_service.dart';
import 'package:meeting_planning_tool/screens/person/person_absence.dart';
import 'package:meeting_planning_tool/screens/person/task_picker.dart';
import 'package:meeting_planning_tool/screens/person/task_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PersonTileWidget extends StatefulWidget {
  const PersonTileWidget(
      {super.key, required this.person, required this.tasks});
  final Person person;
  final List<Task> tasks;

  @override
  State<PersonTileWidget> createState() => _PersonTileWidgetState();
}

class _PersonTileWidgetState extends State<PersonTileWidget> {
  List<Task>? _tasksPerson;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('${widget.person.givenName} ${widget.person.lastName}'),
      trailing: _personMenu(widget.person),
      onExpansionChanged: (expanded) async {
        if (expanded && (_tasksPerson == null || _tasksPerson!.isEmpty)) {
          var t = await getPersonTask(context, widget.person.id);
          setState(() {
            _tasksPerson = t;
          });
        }
      },
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _tasksPerson == null
                ? const CircularProgressIndicator()
                : _tasksPerson!.isEmpty
                    ? Text(AppLocalizations.of(context).noData)
                    : TaskViewPersonPage(tasks: _tasksPerson!)),
      ],
    );
  }

  PopupMenuButton<String> _personMenu(Person person) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'Update':
            _updateTaskPerson(person);
            break;
          case 'Absence':
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PersonAbsenceWidget(person: person)),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Update',
          child: Row(
            children: [
              const Icon(Icons.change_circle_outlined),
              Text(AppLocalizations.of(context).changeTask),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Absence',
          child: Row(
            children: [
              const Icon(Icons.calendar_month),
              Text(AppLocalizations.of(context).absence2),
            ],
          ),
        )
      ],
    );
  }

  void _updateTaskPerson(Person person) async {
    List<int> selected = [];
    await getPersonTask(context, person.id).then((value) {
      List<Task> selectedTasks = value;

      for (var t in selectedTasks) {
        for (var td in t.taskDetails) {
          selected.add(td.id);
        }
      }
    });
    List<List<int>>? tasks = await showDialog<List<List<int>>>(
      context: context,
      builder: (context) =>
          TaskDialog(tasks: widget.tasks, selectedTasks: selected),
    );

    if (tasks != null && tasks.isNotEmpty && mounted) {
      Future<void> addTask() async {
        if (tasks[0].isNotEmpty) {
          var d = await ApiService.postData(context,
              'person/${person.id}/task', tasks[0], {}, (data) => null);
        }
      }

      Future<void> deleteTask() async {
        if (tasks[1].isNotEmpty) {
          ApiService.deleteData(context, 'person/${person.id}/task', tasks[1]);
        }
      }
      await Future.wait([addTask(), deleteTask()]);

      var t = await getPersonTask(context, person.id);
      setState(() {
        _tasksPerson = t;
      });
    }
  }
}
