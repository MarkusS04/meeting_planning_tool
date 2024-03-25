import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class MonthPicker extends StatefulWidget {
  final DateTime month;
  final Function(DateTime) onDateChanged;
  const MonthPicker(
      {super.key, required this.month, required this.onDateChanged});

  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  late DateTime _month;
  @override
  void initState() {
    super.initState();
    _month = widget.month;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showMonthPicker(
          context: context,
          initialDate: DateTime.now(),
        ).then((date) {
          if (date != null) {
            setState(() {
              _month = date;
              widget.onDateChanged(date);
            });
          }
        });
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Month',
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(DateFormat('MMMM yyyy').format(_month)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}
