import 'package:flutter/material.dart';

class SettingGroup extends StatelessWidget {
  const SettingGroup({
    super.key,
    required this.title,
    required this.settingItems,
    this.showDivider = true,
  });

  final String title;
  final List<Widget> settingItems;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 4.0,
        ),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(
          height: 4.0,
        ),
        ...settingItems,
        showDivider ? const Divider() : const SizedBox.shrink(),
      ],
    );
  }
}
