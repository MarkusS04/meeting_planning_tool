import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meeting_planning_tool/api_service.dart';

class MultiDateSelector extends StatefulWidget {
  const MultiDateSelector({super.key});

  @override
  State<MultiDateSelector> createState() => _MultiDateSelectorState();
}

class _MultiDateSelectorState extends State<MultiDateSelector> {
  late List<DateTime?> _selectedDates = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Multiple Date Picker'),
      content: SizedBox(
        // Wrap the content with a Container
        width: double.maxFinite,
        height: 300, // Example height, adjust as needed
        child: CalendarDatePicker2(
          config: CalendarDatePicker2Config(
            calendarType: CalendarDatePicker2Type.multi,
            selectedDayHighlightColor: Colors.indigo,
          ),
          value: _selectedDates,
          onValueChanged: (dates) => setState(() => _selectedDates = dates),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            List<Map<String, dynamic>> data = [];
            for (var date in _selectedDates) {
              if (date != null) {
                data.add({"Date": DateFormat("yyyy-MM-dd").format(date)});
              }
            }
            ApiService.postData<void>(context, "meeting", data, {}, (p0) => {});
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
