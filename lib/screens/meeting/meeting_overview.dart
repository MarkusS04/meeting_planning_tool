import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/meeting/meeting.dart';
import 'package:meeting_planning_tool/data/person/person.dart';
import 'package:meeting_planning_tool/screens/meeting/meeting_absence.dart';
import 'package:meeting_planning_tool/screens/meeting/meeting_absence_edit.dart';
import 'package:meeting_planning_tool/screens/navbar.dart';
import 'package:meeting_planning_tool/utils/dialog_utils.dart';
import 'package:meeting_planning_tool/widgets/edit_menu.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  late Future<List<Meeting>> _meetings;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final firstDayOfNextMonth =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 1);
    final lastDayOfNextMonth =
        DateTime(firstDayOfNextMonth.year, firstDayOfNextMonth.month + 1, 0);
    _startDateController.text =
        DateFormat('yyyy-MM-dd').format(firstDayOfNextMonth);
    _endDateController.text =
        DateFormat('yyyy-MM-dd').format(lastDayOfNextMonth);
    _meetings = _fetchMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting List'),
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
          decoration: const InputDecoration(
            labelText: 'Start Date',
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(_startDateController.text),
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
          decoration: const InputDecoration(
            labelText: 'End Date',
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(_endDateController.text),
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _meetings = _fetchMeetings();
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Meeting>? meetings = snapshot.data;
            if (meetings == null || meetings.isEmpty) {
              return const Center(child: Text('No meetings found.'));
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
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat("EEEE")
                            .format(DateTime.parse(meeting.date))),
                        Text(DateFormat("yyyy-MM-dd")
                            .format(DateTime.parse(meeting.date))),
                        const SizedBox(width: 5),
                      ],
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
      if (value == 'Delete') {
        await ApiService.deleteData(context, "meeting/${meeting.id}", null);
        setState(() {
          _meetings = _fetchMeetings();
        });
      } else if (value == 'Absence') {
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
      }
    }, itemBuilder: (context) {
      List<PopupMenuEntry<String>> edit = editItems();
      edit.add(const PopupMenuItem(
        value: 'Absence',
        child: Row(
          children: [Icon(Icons.event_available), Text('Edit Absence')],
        ),
      ));
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
            label: "Add One",
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
            child: const Icon(Icons.edit_calendar), label: "Add Multiple")
      ],
    );
  }

  Future<List<Meeting>> _fetchMeetings() async {
    final startDate = _startDateController.text;
    final endDate = _endDateController.text;

    try {
      List<Meeting> meeting = await ApiService.fetchData(
        context,
        "meeting",
        {"StartDate": startDate, "EndDate": endDate},
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
