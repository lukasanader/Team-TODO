/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/threads/custom_card.dart';
import 'package:info_hub_app/threads/thread_replies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/threads.dart';
import 'package:mockito/mockito.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  late MockFirebaseAuth mockAuth;
  final String testTopicId = "testTopicId";
  final String testTopicTitle = "testTopicTitle";

  setUp(() {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('CustomCard Cancel button clears input and closes the dialog',
      (WidgetTester tester) async {
    await firestore.collection('thread').add({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'topicTitle': testTopicTitle,
    });

    final snapshot = await firestore.collection('thread').get();

    await tester.pumpWidget(createTestWidget(CustomCard(
      snapshot: snapshot,
      index: 0,
      firestore: firestore,
      auth: mockAuth,
    )));

    await tester.pumpAndSettle();

    // Open the edit dialog
    await tester.tap(find.byIcon(FontAwesomeIcons.edit));
    await tester.pumpAndSettle();

    // Cancel the edit
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Ensure the dialog is closed
    expect(find.text('Cancel'), findsNothing);
  });

  testWidgets('CustomCard deletion process with batch delete',
      (WidgetTester tester) async {
    // Prepare test data
    final threadId = await firestore.collection('thread').add({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
    }).then((doc) => doc.id);

    // Add some replies to the thread
    await firestore.collection('replies').add({
      'content': 'Reply 1',
      'threadId': threadId,
    });

    await firestore.collection('replies').add({
      'content': 'Reply 2',
      'threadId': threadId,
    });

    final snapshot = await firestore.collection('thread').get();

    await tester.pumpWidget(createTestWidget(CustomCard(
      snapshot: snapshot,
      index: 0,
      firestore: firestore,
      auth: mockAuth,
    )));

    await tester.pumpAndSettle();

    // Delete the thread and its replies
    await tester.tap(find.byIcon(FontAwesomeIcons.trashAlt));
    await tester.pumpAndSettle();

    // Verify the thread and its replies are deleted
    final threadSnapshot =
        await firestore.collection('thread').doc(threadId).get();
    final repliesSnapshot = await firestore
        .collection('replies')
        .where('threadId', isEqualTo: threadId)
        .get();

    expect(threadSnapshot.exists, isFalse);
    expect(repliesSnapshot.docs.length, 0);
  });

  testWidgets('CustomCard InkWell navigation to ThreadReplies',
      (WidgetTester tester) async {
    await firestore.collection('thread').add({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
    });

    final snapshot = await firestore.collection('thread').get();

    await tester.pumpWidget(createTestWidget(CustomCard(
      snapshot: snapshot,
      index: 0,
      firestore: firestore,
      auth: mockAuth,
    )));

    await tester.pumpAndSettle();

    // Tap on InkWell to navigate to ThreadReplies
    await tester.tap(find.byKey(Key('navigateToThreadReplies_0')));
    await tester.pumpAndSettle();

    // Verify navigation to ThreadReplies
    expect(find.byType(ThreadReplies), findsOneWidget);
  });

  testWidgets('ThreadApp displays the correct AppBar title',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    expect(find.text(testTopicTitle), findsOneWidget);
  });

  testWidgets('ThreadApp opens a dialog when FAB is pressed',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('ThreadApp closes dialog on cancel', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('ThreadApp adds a thread on submit', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('Title')), 'New Thread Title');
    await tester.enterText(
        find.byKey(const Key('Description')), 'New Thread Description');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Assert that a new thread was added
    // Note: You'll need to mock Firestore's response to simulate adding a thread
  });

  testWidgets('ThreadApp shows error when submitting an incomplete thread',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
  });
}

*/