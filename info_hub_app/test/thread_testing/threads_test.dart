import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/threads/views/custom_card.dart';
import 'package:info_hub_app/threads/views/thread_replies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/views/threads.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/threads/controllers/name_generator_controller.dart';
import 'package:info_hub_app/threads/models/thread_model.dart';
import 'package:info_hub_app/threads/models/thread_replies_model.dart';
import 'package:info_hub_app/threads/controllers/thread_controller.dart';
import 'package:info_hub_app/threads/views/reply_card.dart';
import 'package:info_hub_app/threads/views/admin_view_threads.dart';

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

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockThreadController extends Mock implements ThreadController {}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseAuth mockAuth;
  late FirebaseFirestore mockFirestore;
  late MockThreadController mockThreadController;
  const String testTopicId = "testTopicId";
  const String testTopicTitle = "testTopicTitle";

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirestore();
    mockThreadController = MockThreadController();

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

  testWidgets('ThreadApp initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ThreadApp(
        firestore: mockFirestore,
        auth: mockAuth,
        topicId: testTopicId,
        topicTitle: testTopicTitle,
      ),
    ));

    expect(find.text(testTopicTitle), findsOneWidget);
  });
}
