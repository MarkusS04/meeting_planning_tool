import 'package:flutter/material.dart';
import 'package:meeting_planning_tool/api_service.dart';
import 'package:meeting_planning_tool/data/result_api.dart';
import 'package:meeting_planning_tool/widgets/pw_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late AppLocalizations _local;

  @override
  void didChangeDependencies() {
    _local = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_local.changepw),
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
          child: Text(_local.cancel),
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
                              title: Text(_local.status),
                              content: Text(r.result),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(_local.ok))
                              ]);
                        });
                  }
                }
              : null,
          child: Text(_local.change),
        ),
      ],
    );
  }

  String _buttonText() {
    if (!_minLengthUsed) {
      return _local.passwordMinLength(_minLength);
    }
    return _passwordsMatch ? "" : _local.passwordDontMatch;
  }
}
