import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/views/reply_card.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/threads/views/thread_replies.dart';

import 'package:info_hub_app/main.dart';

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
  const String testThreadId = "testThreadId";
  const String replyId = "replyId";

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();

    await firestore.collection('thread').doc(testThreadId).set({
      'title': 'Test Thread Title',
      'description': 'Test Thread Description',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
    });
    firestore.collection('Users').doc('dummyUid').set({
      'name': 'Dummy User',
      'selectedProfilePhoto': 'default_profile_photo.png',
      'roleType': 'Test Role',
    });

    await firestore.collection('replies').doc(replyId).set({
      'content': 'Initial reply content',
      'creator': 'dummyUid',
      'threadId': testThreadId,
      'timestamp': Timestamp.now(),
    });

    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('ThreadReplies Tests', () {
    testWidgets('Reply dialog interaction and addition to Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(ThreadReplies(
        firestore: firestore,
        auth: mockAuth,
        threadId: testThreadId,
      )));

      // Trigger the reply dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill the reply content and submit
      await tester.enterText(find.byKey(const Key('Content')), 'Test Reply');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Query for the newly added reply
      final snapshot = await firestore
          .collection('replies')
          .where('threadId', isEqualTo: testThreadId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Check if the new reply's content matches 'Test Reply'
      expect(snapshot.docs.isNotEmpty, true);
      expect(snapshot.docs.first.get('content'), 'Test Reply');
    });
  });
  group('ReplyCard Tests', () {
    testWidgets('Editing reply updates Firestore', (WidgetTester tester) async {
      // Render the ReplyCard widget within the test environment
      String dummyDocId = 'dummyDocId';
      await firestore.collection('replies').doc(dummyDocId).set({
        'content': 'Original content',
      });

      final snapshot = await firestore
          .collection('replies')
          .where('creator', isEqualTo: 'dummyUid')
          .get();

      await tester.pumpWidget(createTestWidget(ReplyCard(
        reply: {
          'index': 0,
          'id': replyId,
          'content': 'Initial reply content',
          'creator': 'dummyUid',
          'timestamp': Timestamp.fromMillisecondsSinceEpoch(1629900000000),
          'threadId': testThreadId,
        },
        firestore: firestore,
        auth: mockAuth,
        userProfilePhoto: 'default_profile_photo.png',
        authorName: 'Dummy User',
        roleType: 'Test Role',
      )));

      final expansionTriggerFinder = find.byKey(const Key('authorText_0'));
      await tester.tap(expansionTriggerFinder);
      await tester.pumpAndSettle();

      // Trigger the edit dialog by tapping the edit button
      final editButtonFinder = find.byKey(const Key('editButton_0'));
      expect(editButtonFinder, findsOneWidget);
      await tester.tap(editButtonFinder);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('Content')), 'Updated Reply');
      final updateButtonFinder = find.byKey(const Key('updateButtonText'));
      await tester.tap(updateButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(expansionTriggerFinder);
      await tester.pumpAndSettle();

      // Re-expand the card to access the edit dialog again
      await tester.tap(expansionTriggerFinder);
      await tester.pumpAndSettle();

      // Reopen the edit dialog
      await tester.tap(editButtonFinder);
      await tester.pumpAndSettle();

      final contentTextField = find.byKey(const Key('Content'));
      expect(find.text('Updated Reply'), findsOneWidget);

      final cancelButtonFinder = find.text('Cancel');
      await tester.tap(cancelButtonFinder);
      await tester.pumpAndSettle();
    });
  });
}
