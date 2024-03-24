import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/task/task.dart';
import 'package:meeting_planning_tool/data/task/task_detail.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _descrController = TextEditingController();
  final List<TextEditingController> _taskDetailControllers = [];

  Task? _task;

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
          title: const Text('Add New Task'),
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
                  child: const Text('Add Task Detail'),
                ),
                const SizedBox(height: 20.0),
                _buildSubmitButton(),
              ],
            )));
  }

  Widget _buildDescriptionTextField() {
    return TextField(
      controller: _descrController,
      decoration: const InputDecoration(
        labelText: "Description",
        border: OutlineInputBorder(),
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
                      labelText: "Task Detail ${index + 1}",
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
        child: const Text('Submit'),
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
      id: 0, // ID will be set by API
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
