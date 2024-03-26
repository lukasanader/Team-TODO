import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/profile_view/profile_view_controller.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
import 'package:info_hub_app/profile_view/profile_view.dart';

void main() {
  setUp(() async {
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });
  test('Test light theme colors', () {
    expect(COLOR_PRIMARY_LIGHT, Colors.red.shade700);
    expect(COLOR_SECONDARY_GREY_LIGHT, Colors.grey.shade300);
    expect(COLOR_SECONDARY_GREY_LIGHT_DARKER, Colors.grey.shade600);
    expect(COLOR_PRIMARY_OFF_WHITE_LIGHT,
        const Color.fromARGB(240, 255, 255, 255));
  });

  test('Test dark theme colors', () {
    expect(COLOR_PRIMARY_DARK, Colors.red.shade400);
    expect(COLOR_SECONDARY_GREY_DARK, Colors.grey.shade800);
    expect(COLOR_SECONDARY_GREY_DARK_LIGHTER, Colors.grey.shade400);
    expect(
        COLOR_PRIMARY_OFF_BLACK_DARK, const Color.fromARGB(15, 255, 255, 255));
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
            title: const Text('Test'),
          ),
        ),
      ),
    );

    final ThemeData theme = Theme.of(tester.element(find.byType(AppBar)));

    expect(theme.brightness, Brightness.light);
    expect(theme.primaryColor, COLOR_PRIMARY_LIGHT);
  });

  testWidgets('Test messageCard light theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Builder(
          builder: (context) => messageCard('Test', 'test', context),
        ),
      ),
    );

    final ThemeData theme = Theme.of(tester.element(find.byType(Card)));

    expect(theme.brightness, Brightness.light);
    expect(theme.primaryColor, COLOR_PRIMARY_LIGHT);
  });

  testWidgets('Test messageCard dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: Builder(
          builder: (context) => messageCard('Test', 'test', context),
        ),
      ),
    );

    final ThemeData theme = Theme.of(tester.element(find.byType(Card)));

    expect(theme.brightness, Brightness.dark);
    expect(theme.primaryColor, COLOR_PRIMARY_DARK);
  });

  testWidgets('Test buildInfoTile light theme', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    auth.createUserWithEmailAndPassword(
        email: 'profileview@example.org', password: 'Password123!');
    final fakeUserId = auth.currentUser!.uid;
    final fakeUser = {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'profileview@example.org',
      'roleType': 'Patient',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

    await tester.pumpWidget(MaterialApp(
        theme: lightTheme,
        home: ProfileView(
            controller:
                ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle();

    final ThemeData theme =
        Theme.of(tester.element(find.byType(Container).first));

    expect(theme.brightness, Brightness.light);
    expect(theme.primaryColor, COLOR_PRIMARY_LIGHT);
  });

  testWidgets('Test buildInfoTile light theme', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    auth.createUserWithEmailAndPassword(
        email: 'profileview@example.org', password: 'Password123!');
    final fakeUserId = auth.currentUser!.uid;
    final fakeUser = {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'profileview@example.org',
      'roleType': 'Patient',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

    await tester.pumpWidget(MaterialApp(
        theme: darkTheme,
        home: ProfileView(
            controller:
                ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle();

    final ThemeData theme =
        Theme.of(tester.element(find.byType(Container).first));

    expect(theme.brightness, Brightness.dark);
    expect(theme.primaryColor, COLOR_PRIMARY_DARK);
  });
}
