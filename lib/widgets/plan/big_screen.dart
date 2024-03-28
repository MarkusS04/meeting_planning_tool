import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meeting_planning_tool/data/plan/plan.dart';
import 'package:meeting_planning_tool/data/task/task.dart';
import 'package:meeting_planning_tool/widgets/plan/person_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BigPlanView extends StatelessWidget {
  final TransformedPlan data;
  BigPlanView({super.key, required this.data});

  final _containerHeight = 50.0;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    int c = data.tasks.fold(0, (prev, t) => prev + t.taskDetails.length);
    double colSize = MediaQuery.of(context).size.width / (2 + c);
    colSize = colSize < 200 ? 200 : colSize;
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrimHeader(data.tasks, colSize, context),
              _buildSecHeader(data.tasks, colSize, context),
              ..._buildTableBody(data.data, data.tasks, colSize, context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimHeader(
      List<Task> tasks, double colWidth, BuildContext context) {
    return Row(children: [
      Container(
        decoration: BoxDecoration(border: Border.all()),
        width: colWidth * 2,
        height: _containerHeight,
        child: Text(AppLocalizations.of(context).date),
      ),
      ...tasks.map((t) => Container(
            decoration: BoxDecoration(border: Border.all()),
            width: colWidth * t.taskDetails.length,
            height: _containerHeight,
            child: Text(t.descr),
          ))
    ]);
  }

  Widget _buildSecHeader(
      List<Task> tasks, double colWidth, BuildContext context) {
    List<Widget> secHeader = [
      Container(
          decoration: BoxDecoration(border: Border.all()),
          width: colWidth,
          height: _containerHeight,
          child: Text(AppLocalizations.of(context).day)),
      Container(
          decoration: BoxDecoration(border: Border.all()),
          width: colWidth,
          height: _containerHeight,
          child: Text(AppLocalizations.of(context).date))
    ];
    for (var task in tasks) {
      for (var detail in task.taskDetails) {
        secHeader.add(Container(
            decoration: BoxDecoration(border: Border.all()),
            width: colWidth,
            height: _containerHeight,
            child: Text(detail.descr)));
      }
    }
    return (Row(
      children: secHeader,
    ));
  }

  List<Widget> _buildTableBody(List<PlanMeetingData> data, List<Task> tasks,
      double colWidth, BuildContext context) {
    List<Widget> rows = [];
    final locale = Localizations.localeOf(context).languageCode;
    for (var meeting in data) {
      List<Widget> col = [
        Container(
            width: colWidth,
            height: _containerHeight,
            decoration: BoxDecoration(border: Border.all()),
            child: ListTile(
                title: Text(DateFormat.EEEE(locale)
                    .format(DateTime.parse(meeting.meeting.date))))),
        Container(
          width: colWidth,
          height: _containerHeight,
          decoration: BoxDecoration(border: Border.all()),
          child: ListTile(
            title: Text(
              DateFormat.yMMMd(locale).format(
                DateTime.parse(meeting.meeting.date),
              ),
            ),
          ),
        ),
      ];
      for (var task in tasks) {
        for (var detail in task.taskDetails) {
          PersonWithPlanId? person;
          for (var entry in meeting.person.entries) {
            if (entry.key.id == detail.id) {
              person = entry.value;
              break;
            }
          }
          col.add(Container(
              width: colWidth,
              height: _containerHeight,
              decoration: BoxDecoration(border: Border.all()),
              child: PlanPersonTile(
                person: person,
              )));
        }
      }

      rows.add(Row(children: col));
    }

    return rows;
  }
}
