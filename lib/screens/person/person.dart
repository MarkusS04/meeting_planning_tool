import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/person/person.dart';
import 'package:meeting_planning_tool/data/task/task.dart';
import 'package:meeting_planning_tool/screens/navbar.dart';
import 'package:meeting_planning_tool/screens/person/task_picker.dart';
import 'package:meeting_planning_tool/screens/person/task_view.dart';

class PersonListPage extends StatefulWidget {
  const PersonListPage({super.key});

  @override
  State<PersonListPage> createState() => _PersonListPageState();
}

class _PersonListPageState extends State<PersonListPage> {
  late Future<List<Person>> _futurePersons;
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _fetchTask().then((value) => _tasks = value);
    _futurePersons = _fetchPersons();
  }

  Future<List<Person>> _fetchPersons() async {
    try {
      List<Person> persons = await ApiService.fetchData(
          context,
          "person",
          {},
          (data) =>
              (data as List).map((json) => Person.fromJson(json)).toList());
      return persons;
    } catch (e) {
      Logger().e(e);
      return List.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap with Scaffold
      appBar: AppBar(
        title: const Text('Person List'),
      ),
      body: _personDataView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPerson,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _personDataView() {
    return FutureBuilder<List<Person>>(
      future: _futurePersons,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Person>? persons = snapshot.data;
          return ListView.builder(
            itemCount: persons!.length,
            itemBuilder: (context, index) {
              return _buildPersonTile(persons[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildPersonTile(Person person) {
    Future<List<Task>> tasksFuture = ApiService.fetchData(
        context,
        "person/${person.id}/task",
        {},
        (data) => (data as List).map((json) => Task.fromJson(json)).toList());

    return ExpansionTile(
      title: Text("${person.givenName} ${person.lastName}"),
      trailing: _personMenu(person),
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0), // Adjust the padding as needed
            child: FutureBuilder<List<Task>>(
                future: tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Task>? tasks = snapshot.data;
                    if (tasks == null) {
                      return const Text("No Tasks for Person");
                    }
                    return TaskViewPersonPage(tasks: tasks);
                  }
                })),
      ],
    );
  }

  void _addPerson() {
    String givenName = '';
    String lastName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  givenName = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Givenname',
                ),
              ),
              TextField(
                onChanged: (value) {
                  lastName = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Lastname',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.postData(
                    context,
                    "person",
                    {"GivenName": givenName, "LastName": lastName},
                    {},
                    (p0) => null);
                setState(() {
                  _futurePersons = _fetchPersons();
                });
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  PopupMenuButton<String> _personMenu(Person person) {
    List<int> selected = [];
    ApiService.fetchData(
            context,
            "person/${person.id}/task",
            {},
            (data) =>
                (data as List).map((json) => Task.fromJson(json)).toList())
        .then((value) {
      List<Task> selectedTasks = value;

      for (var t in selectedTasks) {
        for (var td in t.taskDetails) {
          selected.add(td.id);
        }
      }
    });

    return PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'Update') {
            List<List<int>>? tasks = await showDialog<List<List<int>>>(
              context: context,
              builder: (context) =>
                  TaskDialog(tasks: _tasks, selectedTasks: selected),
            );

            if (tasks != null && tasks.isNotEmpty && mounted) {
              if (tasks[0].isNotEmpty) {
                ApiService.postData(context, 'person/${person.id}/task',
                    tasks[0], {}, (p0) => null);
              }
              if (tasks[1].isNotEmpty) {
                ApiService.deleteData(
                    context, 'person/${person.id}/task', tasks[1]);
              }
            }
          }
          setState(() {
            _futurePersons = _fetchPersons();
          });
        },
        itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Update',
                child: Row(
                  children: [
                    Icon(Icons.change_circle_outlined),
                    Text('Change Tasks'),
                  ],
                ),
              )
            ]);
  }

  Future<List<Task>> _fetchTask() async {
    try {
      List<Task> task = await ApiService.fetchData(
        context,
        "task",
        {},
        (data) => (data as List).map((json) => Task.fromJson(json)).toList(),
      );
      return task;
    } catch (e) {
      Logger().e(e);
      return List.empty();
    }
  }
}
