import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController pwController;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;
  final void Function(String)? onChanged;
  const PasswordInputField({
    super.key,
    required this.pwController,
    this.textInputAction,
    this.onEditingComplete,
    this.onChanged,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _showAsterisk = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.pwController,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).password,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_showAsterisk ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _showAsterisk = !_showAsterisk;
            });
          },
        ),
      ),
      obscureText: _showAsterisk,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      onChanged: widget.onChanged,
    );
  }
}
