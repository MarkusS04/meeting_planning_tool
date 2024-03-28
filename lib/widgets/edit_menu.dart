import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<PopupMenuEntry<String>> editItems(BuildContext context) {
  return [
    PopupMenuItem(
      value: 'Update',
      child: Row(
        children: [
          const Icon(Icons.update),
          Text(AppLocalizations.of(context).update),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'Delete',
      child: Row(
        children: [
          const Icon(Icons.delete),
          Text(MaterialLocalizations.of(context).deleteButtonTooltip),
        ],
      ),
    )
  ];
}
