import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/models/plan/plan.dart';
import 'package:meeting_planning_tool/models/task/task.dart';
import 'package:meeting_planning_tool/models/task/task_detail.dart';
import 'package:meeting_planning_tool/widgets/date_text.dart';
import 'package:meeting_planning_tool/widgets/plan/person_tile.dart';

class SmallPlanView extends StatelessWidget {
  final TransformedPlan data;
  const SmallPlanView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.data.length,
      itemBuilder: (context, index) {
        PlanMeetingData planData = data.data[index];
        if (planData.meeting.tag != null) {
          return ListTile(
            title: ShowDateWidget(
              date: DateTime.parse(planData.meeting.date),
              child: Text(planData.meeting.tag!.descr),
            ),
          );
        }
        return ExpansionTile(
          title: ShowDateWidget(date: DateTime.parse(planData.meeting.date)),
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _taskPersonView(planData.person, data.tasks, context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _taskPersonView(Map<TaskDetail, PersonWithPlanId> personTask,
      List<Task> tasks, BuildContext context) {
    return Column(
      children: tasks
          .map((task) => ExpansionTile(
                title: Text(task.descr),
                children: [
                  ...task.taskDetails.map((detail) {
                    PersonWithPlanId? person;
                    for (var entry in personTask.entries) {
                      if (entry.key.id == detail.id) {
                        person = entry.value;
                        break;
                      }
                    }
                    return PlanPersonTile(
                      person: person,
                      task: detail.descr,
                    );
                  })
                ],
              ))
          .toList(),
    );
  }
}
