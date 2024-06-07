import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/models/task/task.dart';
import 'package:meeting_planning_tool/services/person_service.dart';
import 'package:meeting_planning_tool/services/task_service.dart';
import 'package:meeting_planning_tool/widgets/navbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meeting_planning_tool/widgets/person/person_add.dart';
import 'package:meeting_planning_tool/widgets/person/person_tile.dart';

class PersonListPage extends StatefulWidget {
  const PersonListPage({super.key});

  @override
  State<PersonListPage> createState() => _PersonListPageState();
}

class _PersonListPageState extends State<PersonListPage> {
  ScrollController scrollController = ScrollController();
  bool fabVisible = true;
  List<Person> people = [];
  List<Task> tasks = [];

  late Future<void> initialization;
  late AppLocalizations locale;

  @override
  void didChangeDependencies() {
    locale = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    initialization = _initialize();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<void> _initialize() async {
    Future<void> loadTasks() async {
      tasks = await fetchTasks(context);
    }

    Future<void> loadPeople() async {
      people = await getPeople(context);
    }

    await Future.wait([loadTasks(), loadPeople()]);
  }

  void _scrollListener() {
    if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        fabVisible) {
      setState(() => fabVisible = false);
    } else if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward &&
        !fabVisible) {
      setState(() => fabVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${locale.error}: ${snapshot.error}'));
        } else {
          return Scaffold(
            // Wrap with Scaffold
            appBar: AppBar(
              title: Text(locale.people),
            ),
            body: ListView.builder(
              controller: scrollController,
              itemCount: people.length,
              itemBuilder: (context, index) {
                return PersonTileWidget(person: people[index], tasks: tasks);
              },
            ),
            floatingActionButton: Visibility(
              visible: fabVisible,
              child: FloatingActionButton(
                onPressed: addPerson,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              ),
            ),
            bottomNavigationBar: const BottomNavBar(currentIndex: 1),
          );
        }
      },
    );
  }

  void addPerson() async {
    await showDialog(context: context, builder: (context) => AddPersonWidget());
    if (!mounted) {
      return;
    }
    var p = await getPeople(context);
    setState(() {
      people = p;
    });
  }
}
