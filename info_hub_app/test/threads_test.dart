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

    await firestore.collection('threads').add({
      'title': 'Test Title 1',
      'description': 'Test Description 1',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Patient',
    });

    await firestore.collection('threads').add({
      'title': 'Test Title 2',
      'description': 'Test Description 2',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Patient',
    });

    await firestore.collection('threads').add({
      'title': 'Test Title 3',
      'description': 'Test Description 3',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Healthcare Professional',
    });

    await firestore.collection('threads').add({
      'title': 'Test Title 4',
      'description': 'Test Description 4',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': testTopicId,
      'roleType': 'Unknown',
    });

    await firestore.collection('threads').add({
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
      await firestore.collection('threads').add({
        'title': 'Test Title',
        'description': 'Test Description',
        'creator': 'dummyUid',
        'timestamp': Timestamp.now(),
        'topicId': testTopicId,
        'roleType': 'Admin',
      });

      final snapshot = await firestore.collection('threads').get();

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
    final snapshot = await firestore.collection('threads').get();

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
}

// Create a helper function to wrap your widget in a MaterialApp
Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
