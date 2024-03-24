import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
          return Text('Error: ${snapshot.error}');
        } else {
          return ListTile(
            title: Text(
              'Version: ${snapshot.data != null ? snapshot.data!.version : 'not available'}',
            ),
          );
        }
      },
    );
  }
}
