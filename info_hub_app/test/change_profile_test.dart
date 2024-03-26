import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/change_profile/change_profile_view.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:info_hub_app/change_profile/change_profile_controller.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/profile_view/profile_view.dart';
import 'package:info_hub_app/profile_view/profile_view_controller.dart';

void main() {
  setUp(() async {
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });
  testWidgets('Test if first name TextField is present',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget((MaterialApp(
          home: ChangeProfile(
              controller:
                  ChangeProfileController(firestore: firestore, auth: auth)))));
      final firstNameField = find.ancestor(
        of: find.text('First Name'),
        matching: find.byType(TextField),
      );
      await tester.enterText(firstNameField, 'John');
      expect(find.text('John'), findsOneWidget);
    });
  });

  testWidgets('Test if last name TextFormField is present',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget((MaterialApp(
          home: ChangeProfile(
              controller:
                  ChangeProfileController(firestore: firestore, auth: auth)))));
      final lastNameField = find.ancestor(
        of: find.text('Last Name'),
        matching: find.byType(TextField),
      );
      await tester.enterText(lastNameField, 'Doe');
      expect(find.text('Doe'), findsOneWidget);
    });
  });

  testWidgets('Test if new password TextField is present',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget((MaterialApp(
          home: ChangeProfile(
              controller:
                  ChangeProfileController(firestore: firestore, auth: auth)))));
      final newPasswordField = find.ancestor(
        of: find.text('New Password'),
        matching: find.byType(TextField),
      );
      await tester.enterText(newPasswordField, 'newPassword');
      expect(find.text('newPassword'), findsOneWidget);
    });
  });

  testWidgets('Test if confirm password TextField is present',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.runAsync(() async {
      await tester.pumpWidget((MaterialApp(
          home: ChangeProfile(
              controller:
                  ChangeProfileController(firestore: firestore, auth: auth)))));
      final confirmPasswordField = find.ancestor(
        of: find.text('Confirm Password'),
        matching: find.byType(TextField),
      );
      await tester.enterText(confirmPasswordField, 'newPassword');
      expect(find.text('newPassword'), findsOneWidget);
    });
  });

  testWidgets('Test if first name contains only letters',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget((MaterialApp(
        home: ChangeProfile(
            controller:
                ChangeProfileController(firestore: firestore, auth: auth)))));
    final firstNameField = find.widgetWithText(TextField, 'First Name');
    await tester.enterText(firstNameField, '123');
    await tester
        .tap(find.text('Save Changes')); // Trigger the onPressed callback
    await tester.pumpAndSettle(); // Wait for all animations to complete
    expect(
        find.text('First name must consist of letters only'), findsOneWidget);
  });

  testWidgets('Test if last name contains only letters',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget((MaterialApp(
        home: ChangeProfile(
            controller:
                ChangeProfileController(firestore: firestore, auth: auth)))));
    final lastNameField = find.widgetWithText(TextField, 'Last Name');
    expect(lastNameField, findsOneWidget); // Check if last name field is found
    await tester.enterText(
        lastNameField, '1234'); // Enter non-alphabetic characters
    await tester.tap(find.text('Save Changes')); // Trigger onPressed event
    await tester.pumpAndSettle(); // Wait for all animations to complete
    expect(find.text('Last name must consist of letters only'),
        findsOneWidget); // Verify error message
  });

  testWidgets('Test if password meets the criteria',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget((MaterialApp(
        home: ChangeProfile(
            controller:
                ChangeProfileController(firestore: firestore, auth: auth)))));
    final newPasswordField = find.widgetWithText(TextField, 'New Password');
    await tester.enterText(newPasswordField, 'weakpassword');
    await tester
        .tap(find.text('Save Changes')); // Trigger the onPressed callback
    await tester.pumpAndSettle(); // Wait for all animations to complete
    expect(
        find.text(
            'Password must contain:\n- At least one lowercase letter\n- One uppercase letter\n- One number\n- One special character'),
        findsOneWidget);
  });

  testWidgets('Test if passwords match', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget((MaterialApp(
        home: ChangeProfile(
            controller:
                ChangeProfileController(firestore: firestore, auth: auth)))));
    final newPasswordField = find.widgetWithText(TextField, 'New Password');
    final confirmPasswordField =
        find.widgetWithText(TextField, 'Confirm Password');
    await tester.enterText(newPasswordField, 'Password@123');
    await tester.enterText(confirmPasswordField, 'Password@456');
    await tester
        .tap(find.text('Save Changes')); // Trigger the onPressed callback
    await tester.pumpAndSettle(); // Wait for all animations to complete
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Test if first name and last name are updated in Firestore',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    auth.createUserWithEmailAndPassword(
        email: 'testcaseemail@example.org', password: 'Password123!');

    // Create a fake user document with old first name
    final fakeUserId = auth.currentUser?.uid;
    final fakeUser = {
      'email': 'testcaseemail@example.org',
      'roleType': 'Patient',
      'firstName': 'OldFirstName',
      'lastName': 'OldLastName',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

    // Mock FirebaseAuth to return the expected current user

    await tester.pumpWidget((MaterialApp(
        home: ChangeProfile(
            controller:
                ChangeProfileController(firestore: firestore, auth: auth)))));

    // Enter new first name and last name and passwords
    final firstNameField = find.widgetWithText(TextField, 'First Name');
    await tester.enterText(firstNameField, 'NewFirstName');
    final lastNameField = find.widgetWithText(TextField, 'Last Name');
    await tester.enterText(lastNameField, 'NewLastName');
    final newPasswordField = find.widgetWithText(TextField, 'New Password');
    await tester.enterText(newPasswordField, 'Password@123');
    final confirmPasswordField =
        find.widgetWithText(TextField, 'Confirm Password');
    await tester.enterText(confirmPasswordField, 'Password@123');

    // Trigger the save changes button
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Check if the user document in Firestore has been updated
    final updatedUserDoc =
        await firestore.collection('Users').doc(fakeUserId).get();
    // Ensure that the updated user document refers to the same user as the one with the old last name
    expect(updatedUserDoc['firstName'], 'NewFirstName');
    expect(updatedUserDoc['lastName'], 'NewLastName');
  });

  testWidgets('Test that profile view is updated after changes are saved',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    auth.createUserWithEmailAndPassword(
        email: 'testcaseemail@example.org', password: 'Password123!');

    // Create a fake user document with old first name
    final fakeUserId = auth.currentUser?.uid;
    final fakeUser = {
      'email': 'testcaseemail@example.org',
      'roleType': 'Patient',
      'firstName': 'OldFirstName',
      'lastName': 'OldLastName',
    };
    await firestore.collection('Users').doc(fakeUserId).set(fakeUser);

    // Mock FirebaseAuth to return the expected current user

    await tester.pumpWidget(MaterialApp(
        home: ProfileView(
            controller:
                ProfileViewController(firestore: firestore, auth: auth))));
    await tester.pumpAndSettle();
    expect(find.text('Change Profile'), findsOneWidget);

    await tester.ensureVisible(find.text('Change Profile'));
    await tester.tap(find.text('Change Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangeProfile), findsOneWidget);

    // Enter new first name and last name and passwords
    final firstNameField = find.widgetWithText(TextField, 'First Name');
    await tester.enterText(firstNameField, 'NewFirstName');
    final lastNameField = find.widgetWithText(TextField, 'Last Name');
    await tester.enterText(lastNameField, 'NewLastName');
    final newPasswordField = find.widgetWithText(TextField, 'New Password');
    await tester.enterText(newPasswordField, 'Password@123');
    final confirmPasswordField =
        find.widgetWithText(TextField, 'Confirm Password');
    await tester.enterText(confirmPasswordField, 'Password@123');

    // Trigger the save changes button
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
  });

  testWidgets('test if show/hide password switches between both options',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget((MaterialApp(
        home: ChangeProfile(
            controller:
                ChangeProfileController(firestore: firestore, auth: auth)))));
    await tester.pumpAndSettle();

    final newPasswordField = find.ancestor(
      of: find.text('New Password'),
      matching: find.byType(TextField),
    );

    final confirmPasswordField = find.ancestor(
      of: find.text('Confirm Password'),
      matching: find.byType(TextField),
    );

    // Tap on the show/hide password button for the first password field
    await tester.tap(find.descendant(
        of: newPasswordField, matching: find.byIcon(Icons.visibility)));
    await tester.pumpAndSettle();

    // Verify that the password visibility icon has changed for the first field
    expect(
        find.descendant(
            of: newPasswordField, matching: find.byIcon(Icons.visibility_off)),
        findsOneWidget);

    // Tap on the show/hide password button for the second password field
    await tester.tap(find.descendant(
        of: confirmPasswordField, matching: find.byIcon(Icons.visibility)));
    await tester.pumpAndSettle();

    // Verify that the password visibility icon has changed for the second field
    expect(
        find.descendant(
            of: confirmPasswordField,
            matching: find.byIcon(Icons.visibility_off)),
        findsOneWidget);
  });
}
