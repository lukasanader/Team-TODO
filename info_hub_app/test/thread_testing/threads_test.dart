import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/threads/custom_card.dart';
import 'package:info_hub_app/threads/thread_replies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/threads.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/threads/name_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'dummyUid';
  @override
  String? get email => 'dummyemail@test.com';
  @override
  String? get displayName => 'Dummy User';
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseAuth mockAuth;
  final String testTopicId = "testTopicId";
  final String testTopicTitle = "testTopicTitle";

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();

    await firestore.collection('thread').add({
      'title': 'Test Title 1',
      'description': 'Test Description 1',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Patient',
    });

    await firestore.collection('thread').add({
      'title': 'Test Title 2',
      'description': 'Test Description 2',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Patient',
    });

    await firestore.collection('thread').add({
      'title': 'Test Title 3',
      'description': 'Test Description 3',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Healthcare Professional',
    });

    await firestore.collection('thread').add({
      'title': 'Test Title 4',
      'description': 'Test Description 4',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Unknown',
    });

    await firestore.collection('thread').add({
      'title': 'Test Title 5',
      'description': 'Test Description 5',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Patient',
    });

    // Initialize allNouns and allAdjectives before each test
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('ThreadApp and CustomCard Tests', () {
    testWidgets('CustomCard displays thread data', (WidgetTester tester) async {
      await firestore.collection('thread').add({
        'title': 'Test Title',
        'description': 'Test Description',
        'creator': 'dummyUid',
        'timestamp': Timestamp.now(),
        'topicId': testTopicId,
        'roleType': 'Admin',
      });

      final snapshot = await firestore.collection('thread').get();

      await tester.pumpWidget(createTestWidget(CustomCard(
        snapshot: snapshot,
        //indexKey: Key('customCard_0'),
        index: 0,
        firestore: firestore,
        auth: mockAuth,
        userProfilePhoto: 'default_profile_photo.png',
        onEditCompleted: () {},
        roleType: 'Patient',
      )));

      await tester.pumpAndSettle();
      final navigateToThreadRepliesKey =
          find.byKey(Key('navigateToThreadReplies_0'));

      expect(navigateToThreadRepliesKey, findsOneWidget);
    });

    testWidgets('ThreadApp AppBar title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(ThreadApp(
        firestore: firestore,
        auth: mockAuth,
        topicId: testTopicId,
        topicTitle: testTopicTitle,
      )));

      expect(find.text(testTopicTitle), findsOneWidget);
    });

    // Additional tests can be added here
  });

  testWidgets('ThreadApp FloatingActionButton interaction',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    await tester.pumpAndSettle();

    // Find the FloatingActionButton and tap it.
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pump();

    // After tapping, you can verify if the dialog is shown or some state is changed.
    // Adjust the expectation based on the actual behavior of your app.
  });

  GlobalKey<State<ThreadApp>> threadAppStateKey = GlobalKey<State<ThreadApp>>();

  testWidgets('ThreadApp refreshData functionality',
      (WidgetTester tester) async {
    // Create the ThreadApp widget with its key
    final threadApp = ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    );

    // Pump the widget
    await tester.pumpWidget(createTestWidget(threadApp));

    // Use the public interface to trigger refreshData
    threadApp.refreshDataForTesting();
    await tester.pump();

    // Add assertions to verify the state is updated as expected.
  });

  testWidgets('StreamBuilder receives data', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: 'testTopicId',
      topicTitle: 'Test Topic',
    )));

    // Wait for async data to be loaded
    await tester.pumpAndSettle();

    // Find widgets by key or other identifiers
    expect(find.text('Test Title 1'), findsOneWidget);
    //expect(find.text('Test Description'), findsOneWidget);
    //expect(find.text('Test Topic'), findsOneWidget);

    // Perform more assertions as needed
  });

  testWidgets('ThreadApp ListView builder with ObjectKey',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    await tester.pumpAndSettle();

    // Fetch the threads directly from the mock Firestore to know their IDs.
    final snapshot = await firestore.collection('thread').get();

    expect(find.byType(ListView), findsOneWidget);

    // Manually check each CustomCard widget corresponding to each document.
    final docId0 = snapshot.docs[0].id;
    expect(find.byKey(ObjectKey(docId0)), findsOneWidget);
    expect(find.text('Test Title 1'), findsOneWidget);

    final docId1 = snapshot.docs[1].id;
    expect(find.byKey(ObjectKey(docId1)), findsOneWidget);
    expect(find.text('Test Title 2'), findsOneWidget);

    final docId2 = snapshot.docs[2].id;
    expect(find.byKey(ObjectKey(docId2)), findsOneWidget);

    final docId3 = snapshot.docs[3].id;
    expect(find.byKey(ObjectKey(docId3)), findsOneWidget);

    final docId4 = snapshot.docs[4].id;
    expect(find.byKey(ObjectKey(docId4)), findsOneWidget);
  });

  testWidgets('Dialog appears when FloatingActionButton is tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: 'testTopicId',
      topicTitle: 'testTopicTitle',
    )));

    // Tap the floating action button to trigger the dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(); // Rebuild the widget with the new state

    // Check if the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Error messages appear for empty inputs',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: 'testTopicId',
      topicTitle: 'testTopicTitle',
    )));

    // Trigger the dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // Attempt to submit without filling the fields
    await tester.tap(find.widgetWithText(TextButton, 'Submit'));
    await tester.pump();

    // Check for error messages
    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
  });

  testWidgets('Dialog closes when Cancel is pressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: 'testTopicId',
      topicTitle: 'testTopicTitle',
    )));

    // Trigger the dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // Press the Cancel button
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pump();

    // Check if the dialog is closed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Ensure ThreadApp are rendered', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();

    await firestore.collection('Users').doc('dummyUid').set({
      'selectedProfilePhoto': 'profile_photo_1.png',
    });

    await tester.pumpWidget(MaterialApp(
      home: ThreadApp(
        firestore: firestore,
        auth: auth,
        topicId: 'testTopicId',
        topicTitle: 'testTopicTitle',
      ),
    ));

    await tester.pumpAndSettle();

    // Check if the ThreadApp is rendered
    expect(find.byType(ThreadApp), findsOneWidget);
  });

  testWidgets('Profile photo is displayed correctly in CircleAvatar',
      (WidgetTester tester) async {
    // Set up your test data

    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: 'testTopicId',
      topicTitle: 'testTopicTitle',
    )));
    await tester.pumpAndSettle();

    expect(find.byType(CustomCard), findsWidgets);

    if (find.byType(CustomCard).evaluate().isNotEmpty) {
      expect(find.byType(CircleAvatar), findsWidgets);
    } else {
      print('CustomCard widgets not found in the widget tree');
    }
  });

  testWidgets('Create thread when title and description are provided',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    // Open the dialog to create a new thread
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter 'Test Title' into the title TextField.
    await tester.enterText(find.byKey(const Key('Title')), 'Test Title');

    // Enter 'Test Description' into the description TextField.
    await tester.enterText(
        find.byKey(const Key('Description')), 'Test Description');

    // Tap the 'Submit' button to trigger the creation of the thread.
    await tester.tap(find.widgetWithText(TextButton, 'Submit'));
    await tester.pump();

    // Here you should ideally check if the document has been added to Firestore.
    // Since we're using a FakeFirebaseFirestore instance, we simulate this check.
    final snapshot = await firestore
        .collection('thread')
        .where('title', isEqualTo: 'Test Title')
        .get();

    // Verify that the thread has been added to Firestore.
    expect(snapshot.docs.length, equals(1));
    expect(snapshot.docs.first.get('description'), 'Test Description');
  });

  testWidgets('Create thread checks roleType from user data',
      (WidgetTester tester) async {
    // Add a user document with a specified roleType
    await firestore.collection('Users').doc('dummyUid').set({
      'roleType': 'Test Role',
    });

    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    // Trigger the dialog to create a new thread
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill in the title and description fields
    await tester.enterText(
        find.byKey(const Key('Title')), 'Test Title with Role');
    await tester.enterText(
        find.byKey(const Key('Description')), 'Test Description with Role');

    // Submit the form
    await tester.tap(find.widgetWithText(TextButton, 'Submit'));
    await tester.pump();

    // Check if the thread has the correct roleType from the user's data
    final snapshotWithRole = await firestore
        .collection('thread')
        .where('title', isEqualTo: 'Test Title with Role')
        .get();
    expect(snapshotWithRole.docs.first.get('roleType'), equals('Test Role'));

    // Now test the fallback to 'Missing Role'
    await firestore.collection('Users').doc('dummyUid').update({
      'roleType': FieldValue.delete(),
    });

    // Trigger the dialog again
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill in new title and description
    await tester.enterText(
        find.byKey(const Key('Title')), 'Test Title Missing Role');
    await tester.enterText(
        find.byKey(const Key('Description')), 'Test Description Missing Role');

    // Submit the form
    await tester.tap(find.widgetWithText(TextButton, 'Submit'));
    await tester.pump();

    // Check if the thread has the fallback roleType
    final snapshotMissingRole = await firestore
        .collection('thread')
        .where('title', isEqualTo: 'Test Title Missing Role')
        .get();
    expect(
        snapshotMissingRole.docs.first.get('roleType'), equals('Missing Role'));
  });

  testWidgets('Tapping InkWell navigates to ThreadReplies',
      (WidgetTester tester) async {
    await firestore.collection('thread').add({
      'title': 'Navigable Title',
      'description': 'Navigable Description',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Admin',
      'isEdited': false,
    });

    final snapshot = await firestore.collection('thread').get();

    await tester.pumpWidget(createTestWidget(CustomCard(
      snapshot: snapshot,
      index: 0,
      firestore: firestore,
      auth: mockAuth,
      userProfilePhoto: 'default_profile_photo.png',
      onEditCompleted: () {},
      roleType: 'Patient',
    )));

    await tester.pumpAndSettle();

    final inkWellFinder = find.byKey(Key('navigateToThreadReplies_0'));
    expect(inkWellFinder, findsOneWidget);

    await tester.tap(inkWellFinder);
    await tester.pumpAndSettle();

    expect(find.byType(ThreadReplies), findsOneWidget);
  });
  testWidgets('CustomCard _showDialog interaction and reopening',
      (WidgetTester tester) async {
    String dummyDocId = 'dummyDocId';
    await firestore.collection('thread').doc(dummyDocId).set({
      'title': 'Original Title',
      'description': 'Original Description',
    });

    final snapshot = await firestore
        .collection('thread')
        .where('creator', isEqualTo: 'dummyUid')
        .get();

    // Initialize CustomCard with the necessary parameters
    await tester.pumpWidget(createTestWidget(CustomCard(
      snapshot: snapshot,
      index: 0, // Assuming the document is at index 0
      firestore: firestore,
      auth: mockAuth,
      userProfilePhoto: 'default_profile_photo.png',
      onEditCompleted: () {},
      roleType: 'Patient',
    )));

    // Expand the card
    final expansionTriggerFinder = find.byKey(Key('authorText_0'));
    await tester.tap(expansionTriggerFinder);
    await tester.pumpAndSettle();

    // Open the edit dialog
    final editButtonFinder = find.byKey(Key('editIcon_0'));
    await tester.tap(editButtonFinder);
    await tester.pumpAndSettle();

    // Update the content
    await tester.enterText(find.byKey(Key('Title')), 'Updated Title');
    await tester.enterText(
        find.byKey(Key('Description')), 'Updated Description');
    final updateButtonFinder = find.byKey(Key('updateButtonText'));
    await tester.tap(updateButtonFinder);
    await tester.pumpAndSettle();

    // Collapse the card before re-expanding
    await tester.tap(expansionTriggerFinder);
    await tester.pumpAndSettle();

    // Re-expand the card to access the edit dialog again
    await tester.tap(expansionTriggerFinder);
    await tester.pumpAndSettle();

    // Reopen the edit dialog
    await tester.tap(editButtonFinder);
    await tester.pumpAndSettle();

    // Check the text fields for the updated values
    final titleTextField = find.byKey(Key('Title'));
    final descriptionTextField = find.byKey(Key('Description'));

    expect(find.text('Updated Title'), findsOneWidget);
    expect(find.text('Updated Description'), findsOneWidget);

    // Optional: Close the dialog after checking
    final cancelButtonFinder = find.text('Cancel');
    await tester.tap(cancelButtonFinder);
    await tester.pumpAndSettle();
  });
}

// Create a helper function to wrap your widget in a MaterialApp
Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
