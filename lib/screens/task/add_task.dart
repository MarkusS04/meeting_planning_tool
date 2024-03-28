import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/task/task.dart';
import 'package:meeting_planning_tool/data/task/task_detail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _descrController = TextEditingController();
  final List<TextEditingController> _taskDetailControllers = [];

  Task? _task;

  late AppLocalizations _locale;

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _descrController.dispose();
    for (var controller in _taskDetailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).addTask),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDescriptionTextField(),
                _buildTaskDetailList(),
                ElevatedButton(
                  onPressed: _addTaskDetail,
                  child: Text(AppLocalizations.of(context).addTaskDetail),
                ),
                const SizedBox(height: 20.0),
                _buildSubmitButton(),
              ],
            )));
  }

  Widget _buildDescriptionTextField() {
    return TextField(
      controller: _descrController,
      decoration: InputDecoration(
        labelText: _locale.description,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTaskDetailList() {
    return Expanded(
        child: SingleChildScrollView(
      child: Column(
        children: List.generate(
          _taskDetailControllers.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskDetailControllers[index],
                    decoration: InputDecoration(
                      labelText: "${_locale.taskDetail} ${index + 1}",
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _taskDetailControllers.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _submitTask();

          Navigator.pop(context, true);
        },
        child: Text(MaterialLocalizations.of(context).saveButtonLabel),
      ),
    );
  }

  void _addTaskDetail() {
    setState(() {
      _taskDetailControllers.add(TextEditingController());
    });
  }

  Future<void> _submitTask() async {
    final String description = _descrController.text;
    final List<String> taskDetails =
        _taskDetailControllers.map((controller) => controller.text).toList();

    // Create Task object with description and task details
    _task = Task(
      id: 0,
      descr: description,
      taskDetails: taskDetails
          .map((detail) => TaskDetail(id: 0, descr: detail, taskId: 0))
          .toList(),
    );

    if (_task != null) {
      ApiService.postData(context, 'task', _task!.toJson(), {}, (p0) => null);
    }
  }
}
