/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/threads/thread_replies.dart';

import 'package:info_hub_app/main.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'uniqueUserId';
  @override
  String? get email => 'user@example.com';
  @override
  String? get displayName => 'Test User';
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseAuth mockAuth;
  final String testThreadId = "testThreadId";

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();

    await firestore.collection('thread').doc(testThreadId).set({
      'title': 'Test Thread Title',
      'description': 'Test Thread Description',
      'creator': 'uniqueUserId',
      'timestamp': Timestamp.now(),
    });
    firestore.collection('Users').doc('uniqueUserId').set({
      'name': 'Test User',
      'selectedProfilePhoto': 'default_profile_photo.png',
      'roleType': 'Test Role',
    });

    // Optionally, add initial replies to the thread
    await firestore.collection('replies').add({
      'content': 'Initial reply content',
      'creator': 'uniqueUserId',
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
}

*/
