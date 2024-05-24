import 'package:meeting_planning_tool/models/task/task_detail.dart';

class Task {
  final int id;
  final String descr;
  final List<TaskDetail> taskDetails;
  int orderNumber;

  Task({required this.id, required this.descr, required this.taskDetails, this.orderNumber = 0});

  factory Task.fromJson(Map<String, dynamic> json) {
    var list = json['TaskDetails'] as List?;
    List<TaskDetail> taskDetailsList = list != null
        ? list.map((json) => TaskDetail.fromJson(json)).toList()
        : [];

    return Task(
      id: json['ID'],
      descr: json['Descr'],
      taskDetails: taskDetailsList,
      orderNumber: json['OrderNumber']
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> taskDetailsJsonList =
        taskDetails.map((detail) => detail.toJson()).toList();

    return {
      'ID': id,
      'Descr': descr,
      'TaskDetails': taskDetailsJsonList,
      'OrderNumber': orderNumber,
    };
  }
}
