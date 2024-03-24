import 'package:flutter/material.dart';

void unauthorizedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Not Authenticated'),
        content: const Text('You have to log in again.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
