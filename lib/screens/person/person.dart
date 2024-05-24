import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/services/api_service.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/models/task/task.dart';
import 'package:meeting_planning_tool/widgets/navbar.dart';
import 'package:meeting_planning_tool/screens/person/person_absence.dart';
import 'package:meeting_planning_tool/screens/person/task_picker.dart';
import 'package:meeting_planning_tool/screens/person/task_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PersonListPage extends StatefulWidget {
  const PersonListPage({super.key});

  @override
  State<PersonListPage> createState() => _PersonListPageState();
}

class _PersonListPageState extends State<PersonListPage> {
  late Future<List<Person>> _futurePersons;
  late List<Task> _tasks;
  late AppLocalizations _locale;

  ScrollController scrollController = ScrollController();
  bool fabVisible = true;

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _fetchTask().then((value) => _tasks = value);
    _futurePersons = _fetchPersons();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        fabVisible = false;
      });
    } else if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        fabVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap with Scaffold
      appBar: AppBar(
        title: Text(_locale.people),
      ),
      body: _personDataView(),
      floatingActionButton: Visibility(
        visible: fabVisible,
        child: FloatingActionButton(
          onPressed: _addPerson,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  // Widgets
  Widget _personDataView() {
    return FutureBuilder<List<Person>>(
      future: _futurePersons,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${_locale.error}: ${snapshot.error}'));
        } else {
          List<Person>? persons = snapshot.data;
          return ListView.builder(
            controller: scrollController,
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
    return ExpansionTile(
      title: Text('${person.givenName} ${person.lastName}'),
      trailing: _personMenu(person),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Adjust the padding as needed
          child: FutureBuilder<List<Task>>(
            future: _loadPersonTask(person),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('${_locale.error}: ${snapshot.error}'));
              } else {
                List<Task>? tasks = snapshot.data;
                if (tasks == null) {
                  return Text(_locale.noData);
                }
                return TaskViewPersonPage(tasks: tasks);
              }
            },
          ),
        ),
      ],
    );
  }

  PopupMenuButton<String> _personMenu(Person person) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'Update':
            _updateTaskPerson(person);
            break;
          case 'Absence':
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PersonAbsenceWidget(person: person)),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Update',
          child: Row(
            children: [
              const Icon(Icons.change_circle_outlined),
              Text(_locale.changeTask),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Absence',
          child: Row(
            children: [
              const Icon(Icons.calendar_month),
              Text(_locale.absence2),
            ],
          ),
        )
      ],
    );
  }

  // load data
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

  Future<List<Task>> _loadPersonTask(Person person) async {
    return ApiService.fetchData(context, "person/${person.id}/task", {},
        (data) => (data as List).map((json) => Task.fromJson(json)).toList());
  }

  // actions
  void _addPerson() {
    String givenName = '';
    String lastName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_locale.addPerson),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  givenName = value;
                },
                decoration: InputDecoration(
                  hintText: _locale.givenname,
                ),
              ),
              TextField(
                onChanged: (value) {
                  lastName = value;
                },
                decoration: InputDecoration(
                  hintText: _locale.lastname,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
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
              child: Text(MaterialLocalizations.of(context).saveButtonLabel),
            ),
          ],
        );
      },
    );
  }

  void _updateTaskPerson(Person person) async {
    List<int> selected = [];
    await _loadPersonTask(person).then((value) {
      List<Task> selectedTasks = value;

      for (var t in selectedTasks) {
        for (var td in t.taskDetails) {
          selected.add(td.id);
        }
      }
    });
    List<List<int>>? tasks = await showDialog<List<List<int>>>(
      context: context,
      builder: (context) => TaskDialog(tasks: _tasks, selectedTasks: selected),
    );

    if (tasks != null && tasks.isNotEmpty && mounted) {
      if (tasks[0].isNotEmpty) {
        ApiService.postData(
            context, 'person/${person.id}/task', tasks[0], {}, (p0) => null);
      }
      if (tasks[1].isNotEmpty) {
        ApiService.deleteData(context, 'person/${person.id}/task', tasks[1]);
      }
    }
    setState(() {
      _futurePersons = _fetchPersons();
    });
  }
}
