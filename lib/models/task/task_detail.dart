import 'package:meeting_planning_tool/models/task/task.dart';

class TaskDetail {
  final int id;
  final String descr;
  final int taskId;
  int orderNumber;
  Task? task;

  TaskDetail(
      {required this.id, required this.descr, required this.taskId, this.task, this.orderNumber = 0});

  factory TaskDetail.fromJson(Map<String, dynamic> json) {
    if (json['Task'] != null) {
      var task = Task.fromJson(json['Task']) as Task?;
      return TaskDetail(
          id: json['ID'],
          descr: json['Descr'],
          taskId: json['TaskID'],
          orderNumber: json['OrderNumber'],
          task: task);
    } else {
      return TaskDetail(
          id: json['ID'], descr: json['Descr'], taskId: json['TaskID'], orderNumber: json['OrderNumber']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Descr': descr,
    };
  }
}
