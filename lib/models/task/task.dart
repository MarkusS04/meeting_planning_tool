import 'package:meeting_planning_tool/models/task/task_detail.dart';

class Task {
  final int id;
  final String descr;
  final List<TaskDetail> taskDetails;

  Task({required this.id, required this.descr, required this.taskDetails});

  factory Task.fromJson(Map<String, dynamic> json) {
    var list = json['TaskDetails'] as List?;
    List<TaskDetail> taskDetailsList = list != null
        ? list.map((json) => TaskDetail.fromJson(json)).toList()
        : [];

    return Task(
      id: json['ID'],
      descr: json['Descr'],
      taskDetails: taskDetailsList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> taskDetailsJsonList =
        taskDetails.map((detail) => detail.toJson()).toList();

    return {
      'ID': id,
      'Descr': descr,
      'TaskDetails': taskDetailsJsonList,
    };
  }
}
