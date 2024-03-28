import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/task/task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskViewPersonPage extends StatelessWidget {
  final List<Task> tasks;

  const TaskViewPersonPage({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return tasks.isNotEmpty
        ? Column(
            children: tasks.map((task) {
              return ExpansionTile(
                title: Text(task.descr),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: task.taskDetails.map((taskDetail) {
                        return ListTile(title: Text(taskDetail.descr));
                      }).toList(),
                    ),
                  ),
                ],
              );
            }).toList(),
          )
        : Center(child: Text(AppLocalizations.of(context).noData));
  }
}
