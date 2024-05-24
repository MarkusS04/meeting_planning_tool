import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/models/task/task_detail.dart';
import 'package:meeting_planning_tool/services/api_service.dart';

class OrderTaskDetailWidget extends StatefulWidget {
  const OrderTaskDetailWidget(
      {super.key, required this.tasks, required this.taskID});

  final int taskID;
  final List<TaskDetail> tasks;

  @override
  State<OrderTaskDetailWidget> createState() => _OrderTaskDetailWidgetState();
}

class _OrderTaskDetailWidgetState extends State<OrderTaskDetailWidget> {
  @override
  Widget build(BuildContext context) {
    List<TaskDetail> tasks = widget.tasks;
    for (int i = 1; i < tasks.length; i++) {
      if (tasks[i].orderNumber <= tasks[i - 1].orderNumber) {
        tasks[i].orderNumber = tasks[i - 1].orderNumber + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextButton(
            onPressed: () async {
              var data = tasks
                  .map((elem) => {
                        "taskDetailID": elem.id,
                        "orderNumber": elem.orderNumber
                      })
                  .toList();
              await ApiService.putData(
                  context, 'task/${widget.taskID}/detail', data, (p0) => null);
              Navigator.of(context).pop();
            },
            child: Text(MaterialLocalizations.of(context).saveButtonLabel),
          ),
          Flexible(
            child: ReorderableListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index].descr),
                  key: ValueKey(tasks[index].orderNumber),
                );
              },
              itemCount: tasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final task = tasks.removeAt(oldIndex);
                  tasks.insert(newIndex, task);

                  // Update orderNumber for each task to match the new index
                  for (int i = 0; i < tasks.length; i++) {
                    tasks[i].orderNumber = i;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
