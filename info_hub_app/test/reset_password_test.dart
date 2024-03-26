import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/reset_password/reset_password_view.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:info_hub_app/reset_password/reset_password_controller.dart';


void main() {

    testWidgets('Test if Reset Password Header is visible', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ResetPassword(controller: ResetPasswordController(firestore: firestore, auth: auth))));
      expect(find.text('Reset Password'), findsOneWidget);
    });
  });
  
  testWidgets('Test if Email TextField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ResetPassword(controller: ResetPasswordController(firestore: firestore, auth: auth))));
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
    await tester.pumpWidget(MaterialApp(home: ResetPassword(controller: ResetPasswordController(firestore: firestore, auth: auth))));

    final emailField = find.widgetWithText(TextField, 'Email');
    await tester.enterText(emailField, 'valid_email@gmail.com');

    await tester.tap(find.text('Send Email'));

    await tester.pump();

    expect(find.text('Invalid email address'), findsNothing);
  });
});


testWidgets('Test if error message is displayed for invalid email', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();

  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(home: ResetPassword(controller: ResetPasswordController(firestore: firestore, auth: auth))));

    final emailField = find.widgetWithText(TextField, 'Email');
    await tester.enterText(emailField, 'invalid_email_address');

    await tester.tap(find.text('Send Email'));

    await tester.pump();

    expect(find.text('Invalid email address'), findsOneWidget);
  });
});

testWidgets('Test if "Email does not exist" error message is displayed', (WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();

  await firestore.collection('Users').add({'email': 'existing_email@gmail.com'});

  final auth = MockFirebaseAuth();

  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(home: ResetPassword(controller: ResetPasswordController(firestore: firestore, auth: auth))));

    final emailField = find.widgetWithText(TextField, 'Email');
    await tester.enterText(emailField, 'nonexistent_email@gmail.com');

    await tester.tap(find.text('Send Email'));

    await tester.pump();
    expect(find.text('Email does not exist'), findsOneWidget);
  });
});

  testWidgets('Test if Send Email button is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ResetPassword(controller: ResetPasswordController(firestore: firestore, auth: auth))));
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

    await firestore.collection('Users').add({'email': 'john.doe@example.org'});

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: ResetPassword(controller: ResetPasswordController(firestore: firestore, auth: auth))));

      final emailField = find.widgetWithText(TextField, 'Email');
      await tester.enterText(emailField, 'john.doe@example.org');
      await tester.ensureVisible(find.text('Send Email'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Email'));
      await tester.pump();
      expect(find.text('Email sent'), findsWidgets);
    });
  });

}




