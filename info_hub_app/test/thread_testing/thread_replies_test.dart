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

  group('ThreadReplies Tests', () {});
  group('ReplyCard Tests', () {});
}
