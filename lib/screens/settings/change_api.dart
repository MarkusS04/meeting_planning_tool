import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/data/api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateApiUrlDialog extends StatefulWidget {
  const UpdateApiUrlDialog({super.key});

  @override
  State<UpdateApiUrlDialog> createState() => _UpdateApiUrlDialogState();
}

class _UpdateApiUrlDialogState extends State<UpdateApiUrlDialog> {
  final TextEditingController _apiURLController =
      TextEditingController(text: ApiData.apiUrl);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).changeApi),
      content: TextField(
        controller: _apiURLController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            if (ApiData.apiUrl == _apiURLController.text) {
              Navigator.of(context).pop();
            } else {
              ApiData.apiUrl = _apiURLController.text;
              ApiData.authToken = null;
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          child: Text(MaterialLocalizations.of(context).saveButtonLabel),
        ),
      ],
    );
  }
}
