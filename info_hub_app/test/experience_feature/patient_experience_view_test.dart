import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';
import 'package:info_hub_app/patient_experience/patient_experience_view.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late CollectionReference userCollectionRef;
  late CollectionReference topicsCollectionRef;
  late Widget experienceViewWidget;
  late Widget experienceViewWidgetWithFieldAsTrue;
  late Widget experienceViewWidgetWithFieldAsFalse;
  late Widget experienceViewWidgetWithFieldAsNull;
  late Widget experienceViewWidgetWithoutField;

  setUp(() {
    final MockUser mockUser = MockUser(
      isAnonymous: false,
      uid: 'patientWithOptedOutExperienceFieldAsTrue',
      email: 'john@example.com',
    );

    auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    firestore = FakeFirebaseFirestore();
    userCollectionRef = firestore.collection('Users');
    topicsCollectionRef = firestore.collection('experiences');

    userCollectionRef.doc('patientWithOptedOutExperienceFieldAsTrue').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'Patient',
      'hasOptedOutOfExperienceExpectations': true,
    });

    userCollectionRef.doc('patientWithOptedOutExperienceFieldAsFalse').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'Patient',
      'hasOptedOutOfExperienceExpectations': false,
    });

    userCollectionRef.doc('patientWithOptedOutExperienceFieldAsNull').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'Patient',
      'hasOptedOutOfExperienceExpectations': null,
    });

    userCollectionRef.doc('patientWithoutOptedOutExperienceField').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'Patient',
    });

    topicsCollectionRef.add({
      'title': 'Example 1',
      'description': 'Example experience',
      'verified': true
    });
    topicsCollectionRef.add({
      'title': 'Example 2',
      'description': 'Example experience',
      'verified': false
    });

    experienceViewWidget = MaterialApp(
      home: ExperienceView(
        firestore: firestore,
        auth: auth,
      ),
    );

    experienceViewWidgetWithFieldAsTrue = MaterialApp(
      home: ExperienceView(
        firestore: firestore,
        auth: MockFirebaseAuth(
            mockUser: MockUser(
              isAnonymous: false,
              uid: 'patientWithOptedOutExperienceFieldAsTrue',
              email: 'john@example.com',
            ),
            signedIn: true),
      ),
    );

    experienceViewWidgetWithFieldAsFalse = MaterialApp(
      home: ExperienceView(
        firestore: firestore,
        auth: MockFirebaseAuth(
            mockUser: MockUser(
              isAnonymous: false,
              uid: 'patientWithOptedOutExperienceFieldAsFalse',
              email: 'john@example.com',
            ),
            signedIn: true),
      ),
    );

    experienceViewWidgetWithFieldAsNull = MaterialApp(
      home: ExperienceView(
        firestore: firestore,
        auth: MockFirebaseAuth(
            mockUser: MockUser(
              isAnonymous: false,
              uid: 'patientWithOptedOutExperienceFieldAsNull',
              email: 'john@example.com',
            ),
            signedIn: true),
      ),
    );

    experienceViewWidgetWithoutField = MaterialApp(
      home: ExperienceView(
        firestore: firestore,
        auth: MockFirebaseAuth(
            mockUser: MockUser(
              isAnonymous: false,
              uid: 'patientWithoutOptedOutExperienceField',
              email: 'john@example.com',
            ),
            signedIn: true),
      ),
    );
  });

  testWidgets('The verified experiences are being displayed',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(1));

    expect(find.text('Example 1'), findsOneWidget);
  });

  testWidgets('The unverified experiences are being not displayed',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    expect(find.text('Example 2'), findsNothing);
  });

  testWidgets('Share experience button is present',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    expect(find.text('Share your experience!'), findsOneWidget);
  });

  testWidgets(
      'Share experience button directs you to share experience dialog if user\'s hasOptedOutOfExperienceExpectations is set to true',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithFieldAsTrue);
    await tester.pumpAndSettle();

    // Confirming that the user has the field in their document set to true
    DocumentSnapshot userSnapshot = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsTrue')
        .get();
    expect(userSnapshot.exists, true);
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    expect(userData, isNotNull);
    expect(userData?['hasOptedOutOfExperienceExpectations'], isTrue);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets(
      'Share experience button directs you to experience expectations dialog if hasOptedOutOfExperienceExpectations is false',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithFieldAsFalse);
    await tester.pumpAndSettle();

    // Confirming that the user has the field in their document set to false
    DocumentSnapshot userSnapshot = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsFalse')
        .get();
    expect(userSnapshot.exists, true);
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    expect(userData, isNotNull);
    expect(userData?['hasOptedOutOfExperienceExpectations'], isFalse);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Patient Experience Expectations'), findsOneWidget);
  });

  testWidgets(
      'Share experience button directs you to experience expectations dialog if hasOptedOutOfExperienceExpectations is null',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithFieldAsNull);
    await tester.pumpAndSettle();

    // Confirming that the user has the field in their document set to null
    DocumentSnapshot userSnapshot = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsNull')
        .get();
    expect(userSnapshot.exists, true);
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    expect(userData, isNotNull);
    expect(userData?['hasOptedOutOfExperienceExpectations'], isNull);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Patient Experience Expectations'), findsOneWidget);
  });

  testWidgets(
      'Share experience button directs you to experience expectations dialog if hasOptedOutOfExperienceExpectations is not a field',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithoutField);
    await tester.pumpAndSettle();

    // Confirming that the user does not have the field in their document
    DocumentSnapshot userSnapshot = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsNull')
        .get();
    expect(userSnapshot.exists, true);
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    expect(userData, isNotNull);
    expect(userData?['hasOptedOutOfExperienceExpectations'], isNull);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Patient Experience Expectations'), findsOneWidget);
  });

  testWidgets(
      'Share experience expectations has a checkbox to opt out of experience expectations as a user who has the field in their document as false',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithFieldAsFalse);
    await tester.pumpAndSettle();

    // Confirming that the user has the field in their document set to false
    DocumentSnapshot userSnapshotBefore = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsFalse')
        .get();
    expect(userSnapshotBefore.exists, true);
    Map<String, dynamic>? userDataBefore =
        userSnapshotBefore.data() as Map<String, dynamic>?;
    expect(userDataBefore, isNotNull);
    expect(userDataBefore?['hasOptedOutOfExperienceExpectations'], isNotNull);
    expect(userDataBefore?['hasOptedOutOfExperienceExpectations'], false);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Takes you to the experience expectations dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'By sharing your experience, you agree to the following terms:'),
        findsOneWidget);

    // Checkbox to opt out of experience expectations
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false);

    // Checkbox to opt out of experience expectations is ticked
    await tester.ensureVisible(find.text('Don\'t show this again'));
    await tester.tap(find.text('Don\'t show this again'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        true);

    // Confirms that you agree to the terms
    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();

    // Checking if the user has opted out of experience expectations
    DocumentSnapshot userSnapshotAfter = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsFalse')
        .get();

    expect(userSnapshotAfter.exists, true);
    Map<String, dynamic>? userDataAfter =
        userSnapshotAfter.data() as Map<String, dynamic>?;
    expect(userDataAfter, isNotNull);
    expect(userDataAfter?['hasOptedOutOfExperienceExpectations'], isNotNull);
    expect(userDataAfter?['hasOptedOutOfExperienceExpectations'], true);

    // Takes you to the share experience dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets(
      'Share experience expectations has a checkbox to opt out of experience expectations as a user who has the field in their document as null',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithFieldAsNull);
    await tester.pumpAndSettle();

    // Confirming that the user doesn't have the field in their document
    DocumentSnapshot userSnapshotBefore = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsNull')
        .get();
    expect(userSnapshotBefore.exists, true);
    Map<String, dynamic>? userDataBefore =
        userSnapshotBefore.data() as Map<String, dynamic>?;
    expect(userDataBefore, isNotNull);
    expect(userDataBefore?['hasOptedOutOfExperienceExpectations'], isNull);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Takes you to the experience expectations dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'By sharing your experience, you agree to the following terms:'),
        findsOneWidget);

    // Checkbox to opt out of experience expectations
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false);

    // Checkbox to opt out of experience expectations is ticked
    await tester.ensureVisible(find.text('Don\'t show this again'));
    await tester.tap(find.text('Don\'t show this again'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        true);

    // Confirms that you agree to the terms
    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();

    // Checking if the user has opted out of experience expectations
    DocumentSnapshot userSnapshot = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsNull')
        .get();

    expect(userSnapshot.exists, true);
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    expect(userData, isNotNull);
    expect(userData?['hasOptedOutOfExperienceExpectations'], isNotNull);
    expect(userData?['hasOptedOutOfExperienceExpectations'], true);

    // Takes you to the share experience dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets(
      'Share experience expectations has a checkbox to opt out of experience expectations as a user who doesn\'t have the field in their document',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithoutField);
    await tester.pumpAndSettle();

    // Confirming that the user doesn't have the field in their document
    DocumentSnapshot userSnapshotBefore = await userCollectionRef
        .doc('patientWithoutOptedOutExperienceField')
        .get();
    expect(userSnapshotBefore.exists, true);
    Map<String, dynamic>? userDataBefore =
        userSnapshotBefore.data() as Map<String, dynamic>?;
    expect(userDataBefore, isNotNull);
    expect(userDataBefore?['hasOptedOutOfExperienceExpectations'], isNull);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Takes you to the experience expectations dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'By sharing your experience, you agree to the following terms:'),
        findsOneWidget);

    // Checkbox to opt out of experience expectations
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false);

    // Checkbox to opt out of experience expectations is ticked
    await tester.ensureVisible(find.text('Don\'t show this again'));
    await tester.tap(find.text('Don\'t show this again'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        true);

    // Confirms that you agree to the terms
    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();

    // Checking if the user has opted out of experience expectations
    DocumentSnapshot userSnapshot = await userCollectionRef
        .doc('patientWithoutOptedOutExperienceField')
        .get();

    expect(userSnapshot.exists, true);
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    expect(userData, isNotNull);
    expect(userData?['hasOptedOutOfExperienceExpectations'], isNotNull);
    expect(userData?['hasOptedOutOfExperienceExpectations'], true);

    // Takes you to the share experience dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets(
      'Share experience expectations redirects you back to the Patient\'s Experience page if you disagree to the terms',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Takes you to the experience expectations dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'By sharing your experience, you agree to the following terms:'),
        findsOneWidget);

    // Confirms that you disagree to the terms
    await tester.tap(find.text('I disagree'));
    await tester.pumpAndSettle();

    // Redirects you back to the Patient's Experience page
    expect(find.text('Share your experience!'), findsOneWidget);
  });

  testWidgets(
      'Share experience expectations does not change the hasOptedOutOfExperienceExpectations field if you disagree but the user still ticks the checkbox to opt out of experience expectations',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithFieldAsFalse);
    await tester.pumpAndSettle();

    // Confirming that the user doesn't have the field in their document
    DocumentSnapshot userSnapshotBefore = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsFalse')
        .get();
    expect(userSnapshotBefore.exists, true);
    Map<String, dynamic>? userDataBefore =
        userSnapshotBefore.data() as Map<String, dynamic>?;
    expect(userDataBefore, isNotNull);
    expect(userDataBefore?['hasOptedOutOfExperienceExpectations'], isFalse);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Takes you to the experience expectations dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'By sharing your experience, you agree to the following terms:'),
        findsOneWidget);

    // Checkbox to opt out of experience expectations
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false);

    // Checkbox to opt out of experience expectations is ticked
    await tester.ensureVisible(find.text('Don\'t show this again'));
    await tester.tap(find.text('Don\'t show this again'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        true);

    // Confirms that you disagree to the terms
    await tester.tap(find.text('I disagree'));
    await tester.pumpAndSettle();

    // Confirming that a hasOptedOutOfExperienceExpectations field is not made
    DocumentSnapshot userSnapshotAfter = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsFalse')
        .get();
    expect(userSnapshotAfter.exists, true);
    Map<String, dynamic>? userDataAfter =
        userSnapshotAfter.data() as Map<String, dynamic>?;
    expect(userDataAfter, isNotNull);
    expect(userDataAfter?['hasOptedOutOfExperienceExpectations'], isFalse);
  });

  testWidgets(
      'Share experience expectations does not make a hasOptedOutOfExperienceExpectations field if you disagree but the user still ticks the checkbox to opt out of experience expectations',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidgetWithFieldAsNull);
    await tester.pumpAndSettle();

    // Confirming that the user doesn't have the field in their document
    DocumentSnapshot userSnapshotBefore = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsNull')
        .get();
    expect(userSnapshotBefore.exists, true);
    Map<String, dynamic>? userDataBefore =
        userSnapshotBefore.data() as Map<String, dynamic>?;
    expect(userDataBefore, isNotNull);
    expect(userDataBefore?['hasOptedOutOfExperienceExpectations'], isNull);

    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Takes you to the experience expectations dialog
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'By sharing your experience, you agree to the following terms:'),
        findsOneWidget);

    // Checkbox to opt out of experience expectations
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false);

    // Checkbox to opt out of experience expectations is ticked
    await tester.ensureVisible(find.text('Don\'t show this again'));
    await tester.tap(find.text('Don\'t show this again'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        true);

    // Confirms that you disagree to the terms
    await tester.tap(find.text('I disagree'));
    await tester.pumpAndSettle();

    // Confirming that a hasOptedOutOfExperienceExpectations field is not made
    DocumentSnapshot userSnapshotAfter = await userCollectionRef
        .doc('patientWithOptedOutExperienceFieldAsNull')
        .get();
    expect(userSnapshotAfter.exists, true);
    Map<String, dynamic>? userDataAfter =
        userSnapshotAfter.data() as Map<String, dynamic>?;
    expect(userDataAfter, isNotNull);
    expect(userDataAfter?['hasOptedOutOfExperienceExpectations'], isNull);
  });

  testWidgets('Share experience works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();

    // Trigger the _showPostDialog method
    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Verify that the AlertDialog for sharing experience is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    // Enter text into the Title TextField
    await tester.enterText(find.byType(TextField).first, 'Test experience');
    await tester.enterText(find.byType(TextField).last,
        'This is an example of an experience description from a user');

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("experiences").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.any((doc) => doc.data()?['title'] == 'Test experience'),
        isTrue);

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Title of experience can be 70 characers',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showPostDialog method
    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Verify that the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    String longTitle = 'a' * 70;

    // Enter text into the TextField
    await tester.enterText(find.byType(TextField).first, longTitle);

    await tester.enterText(find.byType(TextField).last,
        'This is an example of an experience description from a user');

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("experiences").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(documents.any((doc) => doc.data()?['title'] == longTitle), isTrue);

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Title cannot be empty', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showPostDialog method
    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Verify that the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    // Enter text into the TextField
    await tester.enterText(find.byType(TextField).first, '');

    await tester.enterText(find.byType(TextField).last,
        'This is an example of an experience description from a user');

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(
        find.text('Please fill out the title and experience!'), findsOneWidget);
  });

  testWidgets('Experience descriptions cannot be empty',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showPostDialog method
    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Verify that the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    // Enter text into the TextField
    await tester.enterText(find.byType(TextField).first, 'Filler title');

    await tester.enterText(find.byType(TextField).last, '');

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(
        find.text('Please fill out the title and experience!'), findsOneWidget);
  });

  testWidgets('Experience can be 1000 characers', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(experienceViewWidget);
    await tester.pumpAndSettle();
    // Trigger the _showPostDialog method
    await tester.tap(find.text('Share your experience!'));
    await tester.pumpAndSettle();

    // Verify that the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    String longDescription = 'a' * 1000;

    // Enter text into the TextField
    await tester.enterText(find.byType(TextField).first, 'Filler title');

    await tester.enterText(find.byType(TextField).last, longDescription);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("experiences").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    expect(
        documents.any((doc) => doc.data()?['description'] == longDescription),
        isTrue);

    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
