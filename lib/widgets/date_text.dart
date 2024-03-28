import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowDateWidget extends StatelessWidget {
  final DateTime date;
  const ShowDateWidget({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final local = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat.EEEE(local).format(date)),
        Text(DateFormat.yMMMMd(local).format(date)),
        const SizedBox(width: 5),
      ],
    );
  }
}
