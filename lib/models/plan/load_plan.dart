import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/services/api_service.dart';
import 'package:meeting_planning_tool/models/plan/plan.dart';
import 'package:meeting_planning_tool/models/task/task.dart';

Future<TransformedPlan?> fetchPlan(BuildContext context, DateTime month) async {
  try {
    List<Plan> plan = await ApiService.fetchData(
      context,
      "plan",
      queryParam(month),
      (data) => (data as List).map((json) => Plan.fromJson(json)).toList(),
    );
    List<Task> task = [];
    if (context.mounted) {
      task = await ApiService.fetchData(
        context,
        "task",
        {},
        (data) => (data as List).map((json) => Task.fromJson(json)).toList(),
      );
    }
    return TransformedPlan(plan, task);
  } catch (e) {
    Logger().e(e);
    return Future.value();
  }
}

Map<String, dynamic> queryParam(DateTime month) {
  final startDate = month;
  // returns last day of prev month, when day=0
  final endDate = DateTime(month.year, month.month + 1, 0);
  return {
    "StartDate": DateFormat("yyyy-MM-dd").format(startDate),
    "EndDate": DateFormat("yyyy-MM-dd").format(endDate)
  };
}
