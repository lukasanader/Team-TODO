import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/helpers/base.dart';
import 'package:info_hub_app/registration/registration_screen.dart';
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
    final lastNameField = find.ancestor(
      of: find.text('Last Name'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(lastNameField, "testing");
    expect(find.text('testing') , findsOneWidget);
  });

  testWidgets('Test if email TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(emailField, "testing");
    expect(find.text('testing') , findsOneWidget);
  });

  testWidgets('Test if password TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(passwordField, "testing");
    expect(find.text('testing') , findsOneWidget);
  });

  testWidgets('Test if confirm password TextFormField is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore,auth:auth)));
    final confirmPasswordField = find.ancestor(
      of: find.text('Confirm Password'),
      matching: find.byType(TextFormField),
      );
    await tester.enterText(confirmPasswordField, "testing");
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


  testWidgets('Test if first name TextFormField validation works for invalid input', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore, auth: auth)));
    final firstNameField = find.ancestor(
      of: find.text('First Name'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(firstNameField, "!@#");
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter only letters'), findsOneWidget);
  });

  testWidgets('Test if last name TextFormField validation works', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore, auth: auth)));
    final lastNameField = find.ancestor(
      of: find.text('Last Name'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(lastNameField, "!@#");
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter only letters'), findsOneWidget);
  });

  testWidgets('Test if email TextFormField validation works', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore, auth: auth)));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(emailField, "!#");
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('Test if password TextFormField validation works', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore, auth: auth)));
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(passwordField, "!#");
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Password must contain:\n'
                        '- At least one lowercase letter\n'
                        '- One uppercase letter\n'
                        '- One number\n'
                        '- One special character'),findsOneWidget);
  });

  testWidgets('Test if confirm password TextFormField validation works', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore, auth: auth)));
    final confirmPasswordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(confirmPasswordField, "!#");
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Password must contain:\n'
                        '- At least one lowercase letter\n'
                        '- One uppercase letter\n'
                        '- One number\n'
                        '- One special character'),findsOneWidget);
  });

  testWidgets('Test if confirm password TextFormField validation works to match to other password field', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore, auth: auth)));
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
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'),findsOneWidget);
  });

  testWidgets('Test if NHS email validation works', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore, auth: auth)));
    await tester.tap(find.text('I am a...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Healthcare Professional'));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(emailField, "abcd@123.com");
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid healthcare professional email.'), findsOneWidget);
  });

  testWidgets('Test successful registration redirects to HomeScreen', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen(firestore: firestore, auth: auth)));

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
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Expect to find HomeScreen
    expect(find.byType(Base), findsOneWidget);
});

}
