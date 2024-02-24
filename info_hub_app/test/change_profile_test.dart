import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/change_profile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  testWidgets('Test if first name TextField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ChangeProfile(firestore: firestore, auth: auth)));
      final firstNameField = find.ancestor(
        of: find.text('First Name'),
        matching: find.byType(TextField),
      );
      await tester.enterText(firstNameField, 'John');
      expect(find.text('John'), findsOneWidget);
    });
  });

  testWidgets('Test if last name TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ChangeProfile(firestore: firestore, auth: auth)));
      final lastNameField = find.ancestor(
        of: find.text('Last Name'),
        matching: find.byType(TextField),
      );
      await tester.enterText(lastNameField, 'Doe');
      expect(find.text('Doe'), findsOneWidget);
    });
  });

  testWidgets('Test if new password TextField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ChangeProfile(firestore: firestore, auth: auth)));
      final newPasswordField = find.ancestor(
        of: find.text('New Password'),
        matching: find.byType(TextField),
      );
      await tester.enterText(newPasswordField, 'newPassword');
      expect(find.text('newPassword'), findsOneWidget);
    });
  });

  testWidgets('Test if confirm password TextField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ChangeProfile(firestore: firestore, auth: auth)));
      final confirmPasswordField = find.ancestor(
        of: find.text('Confirm Password'),
        matching: find.byType(TextField),
      );
      await tester.enterText(confirmPasswordField, 'newPassword');
      expect(find.text('newPassword'), findsOneWidget);
    });
  });

testWidgets('Test if first name contains only letters', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  await tester.pumpWidget(MaterialApp(home: ChangeProfile(firestore: firestore, auth: auth)));
  final firstNameField = find.widgetWithText(TextField, 'First Name');
  await tester.enterText(firstNameField, '123');
  await tester.tap(find.text('Save Changes')); // Trigger the onPressed callback
  await tester.pumpAndSettle(); // Wait for all animations to complete
  expect(find.text('First name must consist of letters only'), findsWidgets);
});


testWidgets('Test if last name contains only letters', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  await tester.pumpWidget(MaterialApp(home: ChangeProfile(firestore: firestore, auth: auth)));
  final lastNameField = find.widgetWithText(TextField, 'Last Name');
  expect(lastNameField, findsOneWidget); // Check if last name field is found
  await tester.enterText(lastNameField, '1234'); // Enter non-alphabetic characters
  await tester.tap(find.text('Save Changes')); // Trigger onPressed event
  await tester.pumpAndSettle(); // Wait for all animations to complete
  expect(find.text('Last name must consist of letters only'), findsOneWidget); // Verify error message
});


// test if the password meets the criteria

// test if the passwords match

// test if updateProfile is called when the form is valid

  // Add more test cases here...

}










