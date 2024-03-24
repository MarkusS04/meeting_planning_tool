import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/task/task.dart';

class TaskDialog extends StatefulWidget {
  final List<Task> tasks;
  final List<int> selectedTasks;

  const TaskDialog(
      {super.key, required this.tasks, required this.selectedTasks});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late List<int> selectedTaskDetails;
  late List<int> previouSelected;
  List<int> deselectedTask = [];

  @override
  void initState() {
    super.initState();
    selectedTaskDetails = List.from(widget.selectedTasks);
    previouSelected = List.from(widget.selectedTasks);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Task"),
      content: SingleChildScrollView(
        child: Column(
          children: widget.tasks.map<Widget>((task) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.descr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Column(
                  children: task.taskDetails.map<Widget>((taskDetail) {
                    return CheckboxListTile(
                      title: Text(taskDetail.descr),
                      value: selectedTaskDetails.contains(taskDetail.id),
                      onChanged: (value) {
                        setState(() {
                          if (value != null && value) {
                            selectedTaskDetails.add(taskDetail.id);
                            deselectedTask.remove(taskDetail.id);
                          } else {
                            selectedTaskDetails.remove(taskDetail.id);
                            if (previouSelected.contains(taskDetail.id)) {
                              deselectedTask.add(taskDetail.id);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            for (var i in previouSelected) {
              selectedTaskDetails.remove(i);
            }
            Navigator.of(context).pop([selectedTaskDetails, deselectedTask]);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
