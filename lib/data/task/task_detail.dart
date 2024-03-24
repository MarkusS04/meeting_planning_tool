import 'package:meeting_planning_tool/data/task/task.dart';

class TaskDetail {
  final int id;
  final String descr;
  final int taskId;
  Task? task;

  TaskDetail(
      {required this.id, required this.descr, required this.taskId, this.task});

  factory TaskDetail.fromJson(Map<String, dynamic> json) {
    if (json['Task'] != null) {
      var task = Task.fromJson(json['Task']) as Task?;
      return TaskDetail(
          id: json['ID'],
          descr: json['Descr'],
          taskId: json['TaskId'],
          task: task);
    } else {
      return TaskDetail(
          id: json['ID'], descr: json['Descr'], taskId: json['TaskId']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Descr': descr,
    };
  }
}
