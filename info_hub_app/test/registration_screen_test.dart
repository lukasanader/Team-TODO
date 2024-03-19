import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/legal_agreements/privacy_policy.dart';
import 'package:info_hub_app/legal_agreements/terms_of_services.dart';
import 'package:info_hub_app/registration/registration_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/welcome_message/welcome_message.dart';

void main() {
  late Widget registrationWidget;

  // Custom method to find onTap within RichText widget
  void findOnTapInRichText(Finder finder, String text) {
    final Element element = finder.evaluate().single;
    final RenderParagraph paragraph = element.renderObject as RenderParagraph;
    // The children are the individual TextSpans which have GestureRecognizers
    paragraph.text.visitChildren((dynamic span) {
      if (span.text != text) return true; // continue iterating.

      (span.recognizer as TapGestureRecognizer).onTap!();
      return false; // stop iterating, we found the one.
    });
  }

  setUp(() {
    // Set up registration Widget for testing
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    registrationWidget = MaterialApp(
      home: RegistrationScreen(
        firestore: firestore,
        auth: auth,
        storage: storage,
      ),
    );
  });

  testWidgets('Test if please register text is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    expect(
        find.text('Please fill in the registration details.'), findsOneWidget);
  });

  testWidgets('Test if first name TextFormField is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final firstNameField = find.ancestor(
      of: find.text('First Name'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(firstNameField, "testing");
    expect(find.text('testing'), findsOneWidget);
  });

  testWidgets('Test if last name TextFormField is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final lastNameField = find.ancestor(
      of: find.text('Last Name'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(lastNameField, "testing");
    expect(find.text('testing'), findsOneWidget);
  });

  testWidgets('Test if email TextFormField is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(emailField, "testing");
    expect(find.text('testing'), findsOneWidget);
  });

  testWidgets('Test if password TextFormField is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(passwordField, "testing");
    expect(find.text('testing'), findsOneWidget);
  });

  testWidgets('Test if confirm password TextFormField is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final confirmPasswordField = find.ancestor(
      of: find.text('Confirm Password'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(confirmPasswordField, "testing");
    expect(find.text('testing'), findsOneWidget);
  });

  testWidgets('Test if DropdownButtonFormField for user types is present',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    await tester.tap(find.text('I am a...'));
    await tester.pumpAndSettle();
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Parent'), findsOneWidget);
    expect(find.text('Healthcare Professional'), findsOneWidget);
  });

  testWidgets(
      'Test if first name TextFormField validation works for invalid input',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final firstNameField = find.ancestor(
      of: find.text('First Name'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(firstNameField, "!@#");
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter only letters'), findsOneWidget);
  });

  testWidgets('Test if last name TextFormField validation works',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final lastNameField = find.ancestor(
      of: find.text('Last Name'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(lastNameField, "!@#");
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter only letters'), findsOneWidget);
  });

  testWidgets('Test if email TextFormField validation works',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(emailField, "!#");
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('Test if password TextFormField validation works',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(passwordField, "!#");
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(
        find.text('Password must contain:\n'
            '- At least one lowercase letter\n'
            '- One uppercase letter\n'
            '- One number\n'
            '- One special character'),
        findsOneWidget);
  });

  testWidgets('Test if confirm password TextFormField validation works',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final confirmPasswordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(confirmPasswordField, "!#");
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(
        find.text('Password must contain:\n'
            '- At least one lowercase letter\n'
            '- One uppercase letter\n'
            '- One number\n'
            '- One special character'),
        findsOneWidget);
  });

  testWidgets(
      'Test if confirm password TextFormField validation works to match to other password field',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(passwordField, "!#");
    final confirmPasswordField = find.ancestor(
      of: find.text('Confirm Password'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(confirmPasswordField, "!#2");
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Test if NHS email validation works',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);
    await tester.tap(find.text('I am a...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Healthcare Professional'));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(emailField, "abcd@123.com");
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid healthcare professional email.'),
        findsOneWidget);
  });

  testWidgets('Test successful registration redirects to Welcome Page',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(signedIn: true);
    final storage = MockFirebaseStorage();
    await tester.pumpWidget(MaterialApp(
        home: RegistrationScreen(
            firestore: firestore, storage: storage, auth: auth)));

    final firstNameField = find.ancestor(
      of: find.text('First Name'),
      matching: find.byType(TextFormField),
    );
    final lastNameField = find.ancestor(
      of: find.text('Last Name'),
      matching: find.byType(TextFormField),
    );
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    final confirmPasswordField = find.ancestor(
      of: find.text('Confirm Password'),
      matching: find.byType(TextFormField),
    );

    // Enter valid registration details
    await tester.enterText(firstNameField, 'John');
    await tester.enterText(lastNameField, 'Doe');
    await tester.enterText(emailField, 'john.doe@example.org');
    await tester.enterText(passwordField, 'Password123!');
    await tester.enterText(confirmPasswordField, 'Password123!');

    // Select a role type
    await tester.tap(find.text('I am a...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patient'));
    await tester.pumpAndSettle();

    // Trigger registration
    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Expect to find HomeScreen
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('Test if Agreement text is visible on Register widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);

    // Expect the agreement text to be present
    expect(
        find.text(
            'By clicking "Register", you agree to our Terms of Service and Privacy Policy.',
            findRichText: true),
        findsOneWidget);
  });

  testWidgets('Test Registration Screen to Terms of Services Screen navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);

    // RichText widget variable that should contain the agreement text
    final finalRichTextWidget = find.byKey(const Key('legal_agreements')).first;
    findOnTapInRichText(finalRichTextWidget, "Terms of Service");
    await tester.pumpAndSettle();

    expect(find.byType(TermsOfServicesPage), findsOneWidget);
  });

  testWidgets('Test Registration Screen to Privacy Policy Screen navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(registrationWidget);

    // RichText widget variable that should contain the agreement text
    final finalRichTextWidget = find.byKey(const Key('legal_agreements')).first;
    findOnTapInRichText(finalRichTextWidget, "Privacy Policy");
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyPage), findsOneWidget);
  });
}
