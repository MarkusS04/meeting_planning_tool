import 'package:flutter/material.dart';

List<PopupMenuEntry<String>> editItems() {
  return [
    const PopupMenuItem(
      value: 'Update',
      child: Row(
        children: [
          Icon(Icons.update),
          Text('Update'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'Delete',
      child: Row(
        children: [
          Icon(Icons.delete),
          Text('Delete'),
        ],
      ),
    )
  ];
}
