import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/services/api_service.dart';
import 'package:meeting_planning_tool/models/task/task.dart';

Future<List<Task>> fetchTasks(BuildContext context) async {
  try {
    List<Task> tasks = await ApiService.fetchData(context, "task", {},
        (data) => (data as List).map((json) => Task.fromJson(json)).toList());
    return tasks;
  } catch (e) {
    Logger().e(e);
    return List.empty();
  }
}

