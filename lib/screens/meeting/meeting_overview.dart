import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/services/api_service.dart';
import 'package:meeting_planning_tool/models/meeting/meeting.dart';
import 'package:meeting_planning_tool/models/person/person.dart';
import 'package:meeting_planning_tool/screens/meeting/meeting_absence.dart';
import 'package:meeting_planning_tool/screens/meeting/meeting_absence_edit.dart';
import 'package:meeting_planning_tool/widgets/navbar.dart';
import 'package:meeting_planning_tool/widgets/dialog_utils.dart';
import 'package:meeting_planning_tool/widgets/date_text.dart';
import 'package:meeting_planning_tool/widgets/edit_menu.dart';
import 'package:meeting_planning_tool/widgets/meeting/multi_select.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  late Future<List<Meeting>> _meetings;
  late AppLocalizations _locale;
  late String? _localString;

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context);
    _localString = Localizations.localeOf(context).languageCode;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _startDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
    _endDate = DateTime(_startDate.year, _startDate.month + 1, 0);
    _meetings = _fetchMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_locale.meeting),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [..._dateController(), _meetingOverview()],
        ),
      ),
      floatingActionButton: _addMenu(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  List<Widget> _dateController() {
    return [
      InkWell(
        onTap: () {
          _selectStartDate(context);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _locale.beginning,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(DateFormat.yMMMd(_localString).format(_startDate)),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16.0),
      InkWell(
        onTap: () {
          _selectEndDate(context);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _locale.ending,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(DateFormat.yMMMd(_localString).format(_endDate)),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16.0)
    ];
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _meetings = _fetchMeetings();
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _meetings = _fetchMeetings();
      });
    }
  }

  Widget _meetingOverview() {
    return Expanded(
      child: FutureBuilder<List<Meeting>>(
        key: ValueKey(_meetings),
        future: _meetings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${_locale.error}: ${snapshot.error}'));
          } else {
            List<Meeting>? meetings = snapshot.data;
            if (meetings == null || meetings.isEmpty) {
              return Center(child: Text(_locale.noData));
            }
            return ListView.builder(
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                Meeting meeting = meetings[index];
                return Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.grey), // Set border color here
                    borderRadius:
                        BorderRadius.circular(5), // Set border radius here
                  ),
                  padding: const EdgeInsets.all(8), // Set padding here
                  margin: const EdgeInsets.symmetric(
                      vertical: 4), // Set margin here
                  child: ExpansionTile(
                    title: ShowDateWidget(
                      date: DateTime.parse(meeting.date),
                      child: meeting.tag != null
                          ? Text(meeting.tag!.descr)
                          : Container(),
                    ),
                    trailing: _meetingMenu(meeting),
                    children: [
                      MeetingAbsenceView(people: _fetchAbsence(meeting.id))
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  PopupMenuButton<String> _meetingMenu(Meeting meeting) {
    return PopupMenuButton<String>(onSelected: (value) async {
      switch (value) {
        case 'Delete':
          await ApiService.deleteData(context, "meeting/${meeting.id}", null);
          setState(() {
            _meetings = _fetchMeetings();
          });
          break;
        case 'Absence':
          final absence = await _fetchAbsence(meeting.id);
          final peopleSelected = absence.map((e) {
            return e.id;
          }).toList();
          final people = await _fetchPersons();

          if (mounted) {
            List<List<int>>? peopleAbsence = await showDialog<List<List<int>>>(
                context: context,
                builder: (context) {
                  return MeetingAbseneEdit(
                      people: people, peopleSelected: peopleSelected);
                });
            if (peopleAbsence != null && peopleAbsence.isNotEmpty && mounted) {
              if (peopleAbsence[0].isNotEmpty) {
                ApiService.postData(context, 'meeting/${meeting.id}/absence',
                    peopleAbsence[0], {}, (p0) => null);
              }
              if (peopleAbsence[1].isNotEmpty) {
                ApiService.deleteData(
                    context, 'meeting/${meeting.id}/absence', peopleAbsence[1]);
              }
            }
          }
          break;
        case 'TagAdd':
          final TextEditingController descrController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context).addTag),
              content: TextField(
                controller: descrController,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child:
                      Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                TextButton(
                  onPressed: () async {
                    await ApiService.postData(
                        context,
                        'meeting/${meeting.id}/tag',
                        {"descr": descrController.text},
                        {},
                        (p0) => null);
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close dialog
                    }
                    setState(() {
                      _meetings = _fetchMeetings();
                    });
                  },
                  child:
                      Text(MaterialLocalizations.of(context).saveButtonLabel),
                ),
              ],
            ),
          );
          break;
        case 'TagDelete':
          await ApiService.deleteData(
              context, "meeting/${meeting.id}/tag", null);
          setState(() {
            _meetings = _fetchMeetings();
          });
          break;
      }
    }, itemBuilder: (context) {
      List<PopupMenuEntry<String>> edit = editItems(context);
      edit.add(PopupMenuItem(
        value: 'Absence',
        child: Row(
          children: [
            const Icon(Icons.event_available),
            Text(_locale.editAbsence),
          ],
        ),
      ));
      if (meeting.tag == null) {
        edit.add(PopupMenuItem(
          value: 'TagAdd',
          child: Row(
            children: [
              const Icon(Icons.tag),
              Text(_locale.addTag),
            ],
          ),
        ));
      } else {
        edit.add(PopupMenuItem(
          value: 'TagDelete',
          child: Row(
            children: [
              const Icon(Icons.tag),
              Text(_locale.deleteTag),
            ],
          ),
        ));
      }
      return edit;
    });
  }

  Widget _addMenu() {
    return SpeedDial(
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      icon: Icons.add,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.create_rounded),
            label: _locale.addOne,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null && mounted) {
                List<Map<String, dynamic>> data = [
                  {"Date": DateFormat("yyyy-MM-dd").format(picked)}
                ];
                ApiService.postData<void>(
                    context, "meeting", data, {}, (p0) => {});
                setState(() {
                  _meetings = _fetchMeetings();
                });
              }
            }),
        SpeedDialChild(
          child: const Icon(Icons.edit_calendar),
          label: _locale.addMultiple,
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => const MultiDateSelector(),
            );
            setState(() {
              _meetings = _fetchMeetings();
            });
          },
        )
      ],
    );
  }

  Future<List<Meeting>> _fetchMeetings() async {
    try {
      List<Meeting> meeting = await ApiService.fetchData(
        context,
        "meeting",
        {
          "StartDate": DateFormat('yyyy-MM-dd').format(_startDate),
          "EndDate": DateFormat('yyyy-MM-dd').format(_endDate),
        },
        (data) => (data as List).map((json) => Meeting.fromJson(json)).toList(),
      );
      return meeting;
    } catch (e) {
      if (mounted) {
        unauthorizedDialog(context);
      }
      return List.empty();
    }
  }

  Future<List<Person>> _fetchAbsence(int meetingId) async {
    try {
      dynamic data = await ApiService.fetchData(
        context,
        'meeting/$meetingId/absence',
        {},
        (data) => data,
      );

      if (data != null && data is List) {
        return data.map((json) => Person.fromJson(json)).toList();
      } else {
        // Handle null or unexpected data format
        return [];
      }
    } catch (e) {
      Logger().e(e);
      return [];
    }
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
}
