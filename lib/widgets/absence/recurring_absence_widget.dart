import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/person/person.dart';
import 'package:meeting_planning_tool/data/person/recurring_absence.dart';

class RecurringAbsenceWidget extends StatefulWidget {
  final Person person;
  const RecurringAbsenceWidget({super.key, required this.person});

  @override
  State<RecurringAbsenceWidget> createState() => _RecurringAbsenceWidgetState();
}

class _RecurringAbsenceWidgetState extends State<RecurringAbsenceWidget> {
  final List<bool> _weekdaySelections = List.generate(7, (index) => false);
  final List<bool> _weekdaySelectionsPrev = List.generate(7, (index) => false);
  late Future<List<RecuringAbsence>?> _absence;
  void _saveWeekdaySelections() async {
    List<int> add = [];
    List<int> delete = [];

    for (int i = 0; i < _weekdaySelections.length; i++) {
      if (_weekdaySelections[i] != _weekdaySelectionsPrev[i]) {
        if (_weekdaySelectionsPrev[i]) {
          delete.add(i);
        } else {
          add.add(i);
        }
      }
    }
    if (add.isNotEmpty) {
      await ApiService.postData(
        context,
        'person/${widget.person.id}/absencerecurring',
        add,
        {},
        (p0) => null,
      );
    }
    if (delete.isNotEmpty && mounted) {
      await ApiService.deleteData(
          context, 'person/${widget.person.id}/absencerecurring', delete);
    }
    if (mounted) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Save'),
                content: const Text('Finished Saving'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ));
    }
  }

  Future<List<RecuringAbsence>?> _fetchRecurringAbsence() async {
    final data = await ApiService.fetchData(
      context,
      'person/${widget.person.id}/absencerecurring',
      {},
      (data) =>
          (data as List).map((json) => RecuringAbsence.fromJson(json)).toList(),
    );
    if (data.isNotEmpty) {
      setState(() {
        for (var day in data) {
          _weekdaySelections[day.weekday] = true;
          _weekdaySelectionsPrev[day.weekday] = true;
        }
      });
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    _absence = _fetchRecurringAbsence();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _absence,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: CheckboxListTile(
                title: Text(_getWeekdayName(1)),
                value: _weekdaySelections[1],
                onChanged: ((value) {
                  setState(() {
                    if (value != null) {
                      _weekdaySelections[1] = value;
                    }
                  });
                }),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ...List.generate(3, (index) {
                          int i = index * 2 + 2;
                          return CheckboxListTile(
                            title: Text(_getWeekdayName(i)),
                            value: _weekdaySelections[i],
                            onChanged: ((value) {
                              setState(() {
                                if (value != null) {
                                  _weekdaySelections[i] = value;
                                }
                              });
                            }),
                          );
                        })
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        ...List.generate(3, (index) {
                          int i = (index * 2 + 3) % 7;
                          return CheckboxListTile(
                            title: Text(_getWeekdayName(i)),
                            value: _weekdaySelections[i],
                            onChanged: ((value) {
                              setState(() {
                                if (value != null) {
                                  _weekdaySelections[i] = value;
                                }
                              });
                            }),
                          );
                        })
                      ],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
                onPressed: _saveWeekdaySelections, child: const Text('Save'))
          ],
        );
      }),
    );
  }

  String _getWeekdayName(int index) {
    switch (index) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }
}
