import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:info_hub_app/screens/registration_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  testWidgets('Test if please register text is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    expect(find.text('Please fill in the registration details.'), findsOneWidget);
  });


  testWidgets('Test if first name TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    final firstNameField = find.ancestor(
      of: find.text('First Name'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(firstNameField, "testing");
    expect(find.text('testing') , findsOneWidget);
  });

  testWidgets('Test if last name TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    final firstNameField = find.ancestor(
      of: find.text('Last Name'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(firstNameField, "testing");
    expect(find.text('testing') , findsOneWidget);
  });

  testWidgets('Test if email TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    final firstNameField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(firstNameField, "testing");
    expect(find.text('testing') , findsOneWidget);
  });

  testWidgets('Test if password TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    final firstNameField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(firstNameField, "testing");
    expect(find.text('testing') , findsOneWidget);
  });

  testWidgets('Test if confirm password TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    final firstNameField = find.ancestor(
      of: find.text('Confirm Password'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(firstNameField, "testing");
    expect(find.text('testing') , findsOneWidget);
  });

  testWidgets('Test if DropdownButtonFormField for user types is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    await tester.tap(find.text('I am a...'));
    await tester.pumpAndSettle();
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Parent'), findsOneWidget);
    expect(find.text('Healthcare Professional'), findsOneWidget);
  });

}
