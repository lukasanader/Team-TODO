import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/theme/theme_constants.dart';

void main() {
  test('Test light theme colors', () {
    expect(COLOR_PRIMARY_LIGHT, Colors.red.shade700);
    expect(COLOR_SECONDARY_LIGHT, Colors.grey.shade300);
  });

  test('Test dark theme colors', () {
    expect(COLOR_PRIMARY_DARK, Colors.red.shade500);
    expect(COLOR_SECONDARY_DARK, Colors.grey.shade700);
  });

  testWidgets('Test light theme properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Container(),
      ),
    );

    final ThemeData theme = Theme.of(tester.element(find.byType(Container)));

    expect(theme.brightness, Brightness.light);
    expect(theme.primaryColor, COLOR_PRIMARY_LIGHT);
  });

  testWidgets('Test dark theme properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: Container(),
      ),
    );

    final ThemeData theme = Theme.of(tester.element(find.byType(Container)));

    expect(theme.brightness, Brightness.dark);
    expect(theme.primaryColor, COLOR_PRIMARY_DARK);
  });

  testWidgets('Test navbar theme properties', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(
          appBar: AppBar(
            title: Text('Test'),
          ),
        ),
      ),
    );

    final ThemeData theme = Theme.of(tester.element(find.byType(AppBar)));

    expect(theme.brightness, Brightness.light);
    expect(theme.primaryColor, COLOR_PRIMARY_LIGHT);
  });
}
