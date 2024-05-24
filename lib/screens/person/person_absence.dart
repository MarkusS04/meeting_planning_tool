import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/services/api_service.dart';
import 'package:meeting_planning_tool/models/meeting/meeting.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/models/plan/load_plan.dart';
import 'package:meeting_planning_tool/screens/person/person_absence_edit.dart';
import 'package:meeting_planning_tool/widgets/absence/recurring_absence_widget.dart';
import 'package:meeting_planning_tool/widgets/date_text.dart';
import 'package:meeting_planning_tool/widgets/month_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PersonAbsenceWidget extends StatefulWidget {
  final Person person;
  const PersonAbsenceWidget({super.key, required this.person});

  @override
  State<PersonAbsenceWidget> createState() => _PersonAbsenceWidgetState();
}

class _PersonAbsenceWidgetState extends State<PersonAbsenceWidget> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late Future<List<Meeting>> _meetings;

  @override
  void initState() {
    super.initState();
    _meetings = _fetchAbsence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context).absence2} ${widget.person.givenName} ${widget.person.lastName}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    var widgets = [
      Flexible(
        child: Column(
          children: [
            Text(AppLocalizations.of(context).recurringAbsence),
            Expanded(
              child: RecurringAbsenceWidget(
                person: widget.person,
              ),
            ),
          ],
        ),
      ),
      const VerticalDivider(),
      const Divider(),
      Expanded(child: _buildAbsenceView())
    ];
    if (MediaQuery.of(context).size.height > 600) {
      return Column(children: widgets);
    }
    return Row(children: widgets);
  }

  Widget _buildAbsenceView() {
    return Column(
      children: [
        _buildMonthPickerAndEditButton(),
        Expanded(
          child: FutureBuilder<List<Meeting>>(
            future: _meetings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        '${AppLocalizations.of(context).error}: ${snapshot.error}'));
              } else {
                final meetings = snapshot.data;
                if (meetings != null && meetings.isNotEmpty) {
                  return _buildMeetingList(meetings);
                }
                return Center(child: Text(AppLocalizations.of(context).noData));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthPickerAndEditButton() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: MonthPicker(
              month: _month,
              onDateChanged: (p0) {
                setState(() {
                  _month = p0;
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () async {
                final List<int> selected =
                    (await _meetings).map((e) => e.id).toList();
                final meetings = await _fetchMeetings();
                if (context.mounted) {
                  List<List<int>>? peopleAbsence =
                      await showDialog<List<List<int>>>(
                    context: context,
                    builder: (context) {
                      return PersonAbsenceEdit(
                          meetings: meetings, meetingsSelected: selected);
                    },
                  );
                  if (peopleAbsence != null &&
                      peopleAbsence.isNotEmpty &&
                      mounted) {
                    if (peopleAbsence[0].isNotEmpty) {
                      ApiService.postData(
                          context,
                          'person/${widget.person.id}/absence',
                          peopleAbsence[0],
                          {},
                          (p0) => null);
                    }
                    if (peopleAbsence[1].isNotEmpty) {
                      ApiService.deleteData(
                          context,
                          'person/${widget.person.id}/absence',
                          peopleAbsence[1]);
                    }
                    setState(() {
                      _meetings = _fetchAbsence();
                    });
                  }
                }
              },
              child: Text(AppLocalizations.of(context).editAbsence),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingList(List<Meeting> meetings) {
    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ShowDateWidget(
            date: DateTime.parse(meetings[index].date),
          ),
        );
      },
    );
  }

  Future<List<Meeting>> _fetchAbsence() {
    return ApiService.fetchData(
        context, 'person/${widget.person.id}/absence', queryParam(_month),
        (data) {
      if (data == null) {
        return <Meeting>[];
      }
      return (data as List).map((json) => Meeting.fromJson(json)).toList();
    });
  }

  Future<List<Meeting>> _fetchMeetings() {
    return ApiService.fetchData(context, 'meeting', queryParam(_month), (data) {
      if (data == null) {
        return <Meeting>[];
      }
      return (data as List).map((json) => Meeting.fromJson(json)).toList();
    });
  }
}
