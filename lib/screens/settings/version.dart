import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VersionView extends StatelessWidget {
  const VersionView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text(
              '${AppLocalizations.of(context).error}: ${snapshot.error}');
        } else {
          return ListTile(
            title: Text(
              '${AppLocalizations.of(context).version}: ${snapshot.data != null ? snapshot.data!.version : 'not available'}',
            ),
          );
        }
      },
    );
  }
}
