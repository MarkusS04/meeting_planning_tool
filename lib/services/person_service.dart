import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/services/api_service.dart';
import 'package:meeting_planning_tool/models/task/task.dart';

Future<List<Person>> getPeople(BuildContext context) async {
  try {
    List<Person> persons = await ApiService.fetchData(context, "person", {},
        (data) => (data as List).map((json) => Person.fromJson(json)).toList());
    return persons;
  } catch (e) {
    Logger().e(e);
    return List.empty();
  }
}

Future<void> addPerson(BuildContext context, Person p) async {
  await ApiService.postData(context, "person", p.toJson(), {}, (p0) => null);
}

Future<List<Task>> getPersonTask(BuildContext context, int personId) async {
  return ApiService.fetchData(context, "person/$personId/task", {},
      (data) => (data as List).map((json) => Task.fromJson(json)).toList());
}
