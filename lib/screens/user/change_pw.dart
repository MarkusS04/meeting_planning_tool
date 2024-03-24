import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/result_api.dart';
import 'package:meeting_planning_tool/widgets/pw_text_field.dart';

class PasswordChangeDialog extends StatefulWidget {
  const PasswordChangeDialog({super.key});

  @override
  State<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  final int _minLength = 5;

  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  bool _passwordsMatch = false;
  bool _minLengthUsed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PasswordInputField(
            pwController: _passwordController1,
            onChanged: (value) {
              setState(() {
                _passwordsMatch =
                    _passwordController1.text == _passwordController2.text;
                _minLengthUsed = _passwordController1.text.length >= _minLength;
              });
            },
          ),
          const SizedBox(height: 10),
          PasswordInputField(
            pwController: _passwordController2,
            onChanged: (value) {
              setState(() {
                _passwordsMatch =
                    _passwordController1.text == _passwordController2.text;
              });
            },
          ),
          const SizedBox(height: 10),
          Text(
            _buttonText(),
            style: const TextStyle(
              color: Colors.red,
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _passwordsMatch
              ? () async {
                  ApiResult? r = await ApiService.postData<ApiResult>(
                      context,
                      "user/password",
                      {"password": _passwordController1.text},
                      {},
                      (json) => ApiResult.fromJson(json));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: const Text("Status"),
                              content: Text(r.result),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'))
                              ]);
                        });
                  }
                }
              : null,
          child: const Text('Change'),
        ),
      ],
    );
  }

  String _buttonText() {
    if (!_minLengthUsed) {
      return "Password must have at least $_minLength character";
    }
    return _passwordsMatch ? "" : "Passwords don't match";
  }
}
