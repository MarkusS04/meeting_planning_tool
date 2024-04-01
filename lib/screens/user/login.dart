import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';
import 'package:meeting_planning_tool/models/api.dart';
import 'package:meeting_planning_tool/models/user.dart';
import 'package:meeting_planning_tool/widgets/api_url_text_field.dart';
import 'package:meeting_planning_tool/widgets/pw_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).login),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _apiURLController =
      TextEditingController(text: ApiData.apiUrl);
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ApiURLTextField(controller: _apiURLController),
              const SizedBox(height: 20.0),
              TextField(
                autofillHints: const [AutofillHints.username],
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).username,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                autofocus: true,
              ),
              const SizedBox(height: 20.0),
              PasswordInputField(
                  pwController: _passwordController,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => _login),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _login,
                child: Text(
                  AppLocalizations.of(context).login,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    ApiData.apiUrl = _apiURLController.text.trim();
    User.username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    final Map<String, String> data = {
      'username': User.username,
      'password': password,
    };

    final Uri url = Uri.parse("${ApiData.apiUrl}/login");

    try {
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final String? authToken = response.headers['authorization'];
        ApiData.authToken = authToken;

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          showLoginFailedDialog();
        }
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  void showLoginFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content:
              const Text('Invalid username or password. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
