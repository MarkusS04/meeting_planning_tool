import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_planning_tool/models/api.dart';
import 'package:meeting_planning_tool/screens/home.dart';
import 'package:meeting_planning_tool/screens/startup.dart';
import 'package:meeting_planning_tool/screens/user/login.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('StartPageScreen Widget Tests', () {
    testWidgets('StartPageScreen initializes with light theme',
        (WidgetTester tester) async {
      // Build the StartPageScreen widget
      await tester.pumpWidget(
        const StartPageScreen(initTheme: ThemeMode.light),
      );

      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      // Expect the initial theme mode to be light
      final MaterialApp materialApp = tester.widget(materialAppFinder);
      final ThemeMode? theme = materialApp.themeMode;
      expect(theme, equals(ThemeMode.light));
    });

    testWidgets('StartPageScreen initializes with system theme',
        (WidgetTester tester) async {
      // Build the StartPageScreen widget
      await tester.pumpWidget(
        const StartPageScreen(initTheme: ThemeMode.system),
      );

      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      // Expect the initial theme mode to be light
      final MaterialApp materialApp = tester.widget(materialAppFinder);
      final ThemeMode? theme = materialApp.themeMode;
      expect(theme, equals(ThemeMode.system));
    });

    testWidgets('StartPageScreen initializes with dark theme',
        (WidgetTester tester) async {
      // Build the StartPageScreen widget
      await tester.pumpWidget(const StartPageScreen(initTheme: ThemeMode.dark));

      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      // Expect the initial theme mode to be dark
      final MaterialApp materialApp = tester.widget(materialAppFinder);
      final ThemeMode? theme = materialApp.themeMode;
      expect(theme, equals(ThemeMode.dark));
    });

    testWidgets('Authentication Wrapper test when token is valid',
        (WidgetTester tester) async {
      // Mock authToken to be "valid"
      ApiData.authToken =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSIsImlhdCI6OTk1MTYyMzkwMjJ9.bqyjcJTvAqNT9g0CAjKo4fXRsJmvypXiHQI4c8WfI6g";

      // Build the AuthenticationWrapper widget
      await tester.pumpWidget(const MaterialApp(
        home: AuthenticationWrapper(),
      ));

      // Expect to navigate to HomePage since token is valid
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Authentication Wrapper test when token is not valid',
        (WidgetTester tester) async {
      // Mock authToken to be false
      ApiData.authToken = '';

      // Build the AuthenticationWrapper widget
      await tester.pumpWidget(const MaterialApp(
        home: AuthenticationWrapper(),
      ));

      // Expect to navigate to LoginPage since token is not valid
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
