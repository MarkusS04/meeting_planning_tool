import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/models/meeting/meeting.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meeting_planning_tool/widgets/date_text.dart';

class PersonAbsenceEdit extends StatefulWidget {
  final List<Meeting> meetings;
  final List<int> meetingsSelected;

  const PersonAbsenceEdit({
    super.key,
    required this.meetings,
    required this.meetingsSelected,
  });

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
      title: Text(AppLocalizations.of(context).editAbsence),
      content: SingleChildScrollView(
        child: _buildContent(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: Text(MaterialLocalizations.of(context).saveButtonLabel),
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
              _buildSectionTitle(AppLocalizations.of(context).available),
              ..._buildAvailableMeetings(),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(AppLocalizations.of(context).absence),
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
        _buildSectionTitle(AppLocalizations.of(context).available),
        ..._buildAvailableMeetings(),
        _buildSectionTitle(AppLocalizations.of(context).absence),
        ..._buildAbsentMeetings(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
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
          title: ShowDateWidget(date: DateTime.parse(meeting.date)),
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
