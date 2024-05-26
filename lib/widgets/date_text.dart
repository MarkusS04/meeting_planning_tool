import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowDateWidget extends StatelessWidget {
  final DateTime date;
  final Widget? child;
  const ShowDateWidget({super.key, required this.date, this.child});

  @override
  Widget build(BuildContext context) {
    final local = Localizations.localeOf(context).languageCode;
    var widget = [
      Text(DateFormat.EEEE(local).format(date)),
      Text(DateFormat.yMMMMd(local).format(date)),
      const SizedBox(width: 5),
    ];
    if (child != null) {
      widget.add(child!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget,
    );
  }
}
