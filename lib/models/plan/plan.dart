import 'package:meeting_planning_tool/models/meeting/meeting.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/models/task/task.dart';
import 'package:meeting_planning_tool/models/task/task_detail.dart';

class Plan {
  final int id;
  final Person? person;
  final Meeting meeting;
  final TaskDetail taskDetail;

  Plan(
      {required this.id,
      required this.person,
      required this.meeting,
      required this.taskDetail});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['ID'],
      person: Person.fromJson(json['Person']),
      meeting: Meeting.fromJson(json['Meeting']),
      taskDetail: TaskDetail.fromJson(json['TaskDetail']),
    );
  }
}

class PersonWithPlanId {
  final Person? person;
  final int planId;

  PersonWithPlanId({required this.person, required this.planId});
}

class PlanMeetingData {
  late Meeting meeting;
  late Map<TaskDetail, PersonWithPlanId> person;

  PlanMeetingData({required this.meeting, required this.person});
}

class TransformedPlan {
  late List<PlanMeetingData> data;
  late List<Task> tasks;

  TransformedPlan(List<Plan> plans, this.tasks) {
    List<PlanMeetingData> data = [];

    if (plans.isNotEmpty) {
      int lastMeeting = plans[0].meeting.id;
      PlanMeetingData currentPlanData =
          PlanMeetingData(meeting: plans[0].meeting, person: {});

      for (Plan plan in plans) {
        if (plan.meeting.id != lastMeeting) {
          data.add(currentPlanData);
          currentPlanData = PlanMeetingData(meeting: plan.meeting, person: {});
        }
        currentPlanData.person[plan.taskDetail] =
            PersonWithPlanId(person: plan.person, planId: plan.id);
        lastMeeting = plan.meeting.id;
      }
      data.add(currentPlanData);
    }

    this.data = data;
  }
}
