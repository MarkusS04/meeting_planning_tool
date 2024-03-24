import 'package:flutter/material.dart';

class ApiURLTextField extends StatelessWidget {
  final TextEditingController controller;

  const ApiURLTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('API URL'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
