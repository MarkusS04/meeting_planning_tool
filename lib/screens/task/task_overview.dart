import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/task/task.dart';
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/data/task/task_detail.dart';
import 'package:meeting_planning_tool/screens/navbar.dart';
import 'package:meeting_planning_tool/screens/task/add_task.dart';
import 'package:meeting_planning_tool/widgets/edit_menu.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = _fetchTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tasks"),
          actions: [_reloadButton()],
        ),
        body: FutureBuilder<List<Task>>(
          future: _tasks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Task>? task = snapshot.data;
              return _dataView(task!);
            }
          },
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 3),
        floatingActionButton: _floatingAction());
  }

  IconButton _reloadButton() {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        setState(() {
          _tasks = _fetchTask();
        });
      },
    );
  }

  Widget _floatingAction() {
    return FloatingActionButton(
      onPressed: addNewTask,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }

  Widget _dataView(List<Task> task) {
    return task.isNotEmpty
        ? ListView.builder(
            itemCount: task.length,
            itemBuilder: (context, index) {
              return ExpansionTile(
                title: Text(task[index].descr),
                subtitle: Text("ID: ${task[index].id}"),
                trailing: _taskMenu(task[index]),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0), // Adjust the padding as needed
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: task[index].taskDetails.map((taskDetail) {
                        return ListTile(
                            title: Text(taskDetail.descr),
                            subtitle: Text("ID: ${taskDetail.id}"),
                            trailing: _taskdetailMenu(taskDetail, task[index]));
                      }).toList(),
                    ),
                  ),
                ],
              );
            })
        : const Center(child: Text("No Data available"));
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

  PopupMenuButton<String> _taskMenu(Task task) {
    return PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'Delete') {
            await ApiService.deleteData(context, "task/${task.id}", null);
            setState(() {
              _tasks = _fetchTask();
            });
          } else if (value == 'Update') {
            _updateDescr('task/${task.id}', task.descr);
          }
        },
        itemBuilder: (context) => editItems());
  }

  PopupMenuButton<String> _taskdetailMenu(TaskDetail detail, Task task) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'Delete') {
          await ApiService.deleteData(
              context, "task/${task.id}/detail/${detail.id}", null);
          setState(() {
            _tasks = _fetchTask();
          });
        } else if (value == 'Update') {
          _updateDescr('task/${task.id}/detail/${detail.id}', detail.descr);
        }
      },
      itemBuilder: (context) => editItems(),
    );
  }

  void addNewTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(),
      ),
    ).then((value) {
      setState(() {
        _tasks = _fetchTask();
      });
    });
  }

  void _updateDescr(String url, String old) {
    final TextEditingController descrController =
        TextEditingController(text: old);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Description'),
        content: TextField(
          controller: descrController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ApiService.putData(
                  context, url, {"Descr": descrController.text}, (p0) => null);
              setState(() {
                _tasks = _fetchTask();
              });
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
