import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meeting_planning_tool/data/meeting/meeting.dart';

class PersonAbsenceEdit extends StatefulWidget {
  final List<Meeting> meetings;
  final List<int> meetingsSelected;

  const PersonAbsenceEdit({
    Key? key,
    required this.meetings,
    required this.meetingsSelected,
  }) : super(key: key);

  @override
  State<PersonAbsenceEdit> createState() => _PersonAbsenceEditState();
}

class _PersonAbsenceEditState extends State<PersonAbsenceEdit> {
  late List<int> meetingsSelected;
  late List<int> previouSelected;
  List<int> meetingsDeselected = [];

  @override
  void initState() {
    super.initState();
    meetingsSelected = List.from(widget.meetingsSelected);
    previouSelected = List.from(widget.meetingsSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Absence'),
      content: SingleChildScrollView(
        child: _buildContent(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return MediaQuery.of(context).size.width > 600
        ? _buildLargeScreenContent()
        : _buildSmallScreenContent();
  }

  Widget _buildLargeScreenContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Available'),
              ..._buildAvailableMeetings(),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Absence'),
              ..._buildAbsentMeetings(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenContent() {
    return Column(
      children: [
        _buildSectionTitle('Available'),
        ..._buildAvailableMeetings(),
        _buildSectionTitle('Absence'),
        ..._buildAbsentMeetings(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),
    );
  }

  List<Widget> _buildAvailableMeetings() {
    return _buildMeetingList(widget.meetings
        .where((meeting) => !meetingsSelected.contains(meeting.id)));
  }

  List<Widget> _buildAbsentMeetings() {
    return _buildMeetingList(widget.meetings
        .where((meeting) => meetingsSelected.contains(meeting.id)));
  }

  List<Widget> _buildMeetingList(Iterable<Meeting> meetings) {
    return meetings.map((meeting) {
      return InkWell(
        onTap: () {
          setState(() {
            if (meetingsSelected.contains(meeting.id)) {
              meetingsSelected.remove(meeting.id);
              if (previouSelected.contains(meeting.id)) {
                meetingsDeselected.add(meeting.id);
              }
            } else {
              meetingsDeselected.remove(meeting.id);
              meetingsSelected.add(meeting.id);
            }
          });
        },
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat("EEEE").format(DateTime.parse(meeting.date))),
              Text(DateFormat("yyyy-MM-dd")
                  .format(DateTime.parse(meeting.date))),
              const SizedBox(width: 5),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _saveChanges() {
    for (var i in previouSelected) {
      meetingsSelected.remove(i);
    }
    Navigator.of(context).pop([meetingsSelected, meetingsDeselected]);
  }
}
