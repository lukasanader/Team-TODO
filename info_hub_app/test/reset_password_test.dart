import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/reset_password/reset_password.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';


void main() {
  testWidgets('Test if Email TextField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ResetPassword(firestore: firestore, auth: auth)));
      final emailField = find.ancestor(
        of: find.text('Email'),
        matching: find.byType(TextField),
      );
      await tester.enterText(emailField, 'john@gmail.com');
      expect(find.text('john@gmail.com'), findsOneWidget);
    });
  });
  
testWidgets('Test if valid email input does not display error message', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(home: ResetPassword(firestore: firestore, auth: auth)));

    // Find the email TextField and enter a valid email address
    final emailField = find.widgetWithText(TextField, 'Email');
    await tester.enterText(emailField, 'valid_email@gmail.com');

    // Trigger validation action (e.g., pressing a button)
    // In this case, let's find and tap the "Send Email" button
    await tester.tap(find.text('Send Email'));

    // Wait for the UI to update
    await tester.pump();

    // Verify that no error message is displayed
    expect(find.text('Invalid email address'), findsNothing);
  });
});


testWidgets('Test if error message is displayed for invalid email', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();

  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(home: ResetPassword(firestore: firestore, auth: auth)));

    // Find the email TextField and enter an invalid email address
    final emailField = find.widgetWithText(TextField, 'Email');
    await tester.enterText(emailField, 'invalid_email_address');

    // Tap the "Send Password Reset Email" button to trigger validation
    await tester.tap(find.text('Send Email'));

    // Wait for the UI to update
    await tester.pump();

    // Verify that the error message is displayed
    expect(find.text('Invalid email address'), findsOneWidget);
  });
});

testWidgets('Test if "Email does not exist" error message is displayed', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();

  // Add a fake document to simulate a non-existent email
  await firestore.collection('Users').add({'email': 'existing_email@gmail.com'});

  final auth = MockFirebaseAuth();

  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(home: ResetPassword(firestore: firestore, auth: auth)));

    // Find the email TextField and enter a valid email address
    final emailField = find.widgetWithText(TextField, 'Email');
    await tester.enterText(emailField, 'nonexistent_email@gmail.com');

    // Tap the "Send Email" button to trigger validation
    await tester.tap(find.text('Send Email'));

    // Wait for the UI to update
    await tester.pump();

    // Verify that the "Email does not exist" error message is displayed
    expect(find.text('Email does not exist'), findsOneWidget);
  });
});

  testWidgets('Test if Send Email button is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ResetPassword(firestore: firestore, auth: auth)));
      final resetPasswordButton = find.ancestor(
        of: find.text('Send Email'),
        matching: find.byType(ElevatedButton),
      );
      expect(resetPasswordButton, findsOneWidget);
    });
  });


testWidgets('Test if "Email sent" green notification is displayed', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();

    // Add a document to the fake database with the email
    await firestore.collection('Users').add({'email': 'john.doe@example.org'});

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ResetPassword(firestore: firestore, auth: auth)));

      // Find the email TextField and enter a valid email address
      final emailField = find.widgetWithText(TextField, 'Email');
      await tester.enterText(emailField, 'john.doe@example.org');

      // Tap the "Send Email" button to trigger sending the email
      await tester.tap(find.text('Send Email'));

      // Wait for the UI to update
      await tester.pumpAndSettle();

      // Verify that the "Email sent" green notification is displayed
      expect(find.text('Email sent'), findsWidgets);
    });
  });

}



