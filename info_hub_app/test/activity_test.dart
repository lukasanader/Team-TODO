import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/screens/activity_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/threads/threads.dart';
import 'package:info_hub_app/model/topic_model.dart';
import 'package:info_hub_app/topics/view_topic/view/topic_view.dart';

void main() {
  late MockFirebaseStorage storage = MockFirebaseStorage();
  late FirebaseFirestore firestore;
  late MockFirebaseAuth auth = MockFirebaseAuth();

  setUp(() async {
    // Setup FakeFirestore and MockFirebaseAuth
    firestore = FakeFirebaseFirestore();
    auth.createUserWithEmailAndPassword(
        email: 'test@email.com',
        password: 'Password123!'); //Signs in automatically

    // Add user data to firestore
    await firestore.collection('Users').doc(auth.currentUser!.uid).set({
      'email': 'test@email.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient',
      'likedTopics': [],
      'dislikedTopics': [],
      'savedTopics': [],
      'hasOptedOutOfUserExpierence': false,
    });

    // Add topics to firestore
    CollectionReference topicCollectionRef = firestore.collection('topics');
    topicCollectionRef.doc('1').set({
      'title': 'test 1',
      'description': 'Test Description',
      'articleLink': '',
      'media': [],
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'date': DateTime.now(),
      'categories': [],
      'quizID': '',
    });
    topicCollectionRef.add({
      'title': 'test 2',
      'description': 'Test Description',
      'articleLink': '',
      'media': [],
      'likes': 0,
      'views': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'date': DateTime.now(),
      'categories': [],
      'quizID': '',
    });
    // Initialize allNouns and allAdjectives before each test
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });

  testWidgets('Test topic likes and history tracker',
      (WidgetTester tester) async {
    // Pump the HomePage widget and navigate to a topic
    await tester.pumpWidget(MaterialApp(
      home: HomePage(
        firestore: firestore,
        auth: auth,
        storage: storage,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('test 1'));
    await tester.pumpAndSettle();

    // Like the topic and navigate back
    await tester.tap(find.byIcon(Icons.thumb_up));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('test 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('test 1'));
    await tester.pumpAndSettle();

    // Check if activity is recorded
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("activity").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;
    expect(
      documents.any(
        (doc) => doc.data()?['type'] == 'topics',
      ),
      isTrue,
    );

    // Navigate to ActivityView and verify the presence of test 1 topic
    await tester.pumpWidget(MaterialApp(
        home: ActivityView(
      firestore: firestore,
      auth: auth,
      storage: storage,
    )));
    await tester.pumpAndSettle();
    expect(find.text('test 1'), findsOneWidget);
  });

  testWidgets('Test thread history tracker', (WidgetTester tester) async {
    // Create thread data in firestore
    final threadId = await firestore.collection('thread').add({
      'title': 'Thread 1',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': '1',
      'roleType': 'Patient',
    }).then((doc) => doc.id);

    // Add replies to the thread
    await firestore.collection('replies').add({
      'content': 'Reply 1',
      'threadId': threadId,
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
    });

    final newThreadId = await firestore.collection('thread').add({
      'title': 'Thread 2',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
      'topicId': '1',
      'roleType': 'Patient',
    }).then((doc) => doc.id);

    await firestore.collection('replies').add({
      'content': 'Reply 1',
      'threadId': newThreadId,
      'creator': 'dummyUid',
      'timestamp': Timestamp.now(),
    });

    // Add thread activity
    await firestore.collection('activity').add({
      'type': 'thread',
      'aid': threadId,
      'uid': auth.currentUser!.uid,
      'date': DateTime.now()
    });

    await firestore.collection('activity').add({
      'type': 'thread',
      'aid': newThreadId,
      'uid': auth.currentUser!.uid,
      'date': DateTime.now()
    });

    // Navigate to ActivityView and verify threads are displayed
    await tester.pumpWidget(MaterialApp(
        home: ActivityView(
      firestore: firestore,
      auth: auth,
      storage: storage,
    )));
    await tester.pumpAndSettle();

    expect(find.textContaining('Thread 1'), findsOne);
    expect(find.textContaining('Thread 2'), findsOne);

    // Tap on Thread 1 and verify navigation to ThreadApp
    await tester.ensureVisible(find.textContaining('Thread 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Thread 1'));
    await tester.pumpAndSettle();
    expect(find.byType(ThreadApp), findsOne);
  });

  testWidgets('Test delete topic', (WidgetTester tester) async {
    firestore.collection('activity').add({
      'type': 'topics',
      'aid': '1',
      'uid': 'adminUser',
      'date': DateTime.now()
    });
    // create the activity
    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });

    Topic topic = Topic(
        title: 'Test Topic',
        description: 'Test Description',
        articleLink: 'https://www.example.com',
        media: [],
        likes: 0,
        views: 0,
        quizID: "",
        tags: ['Patient'],
        dislikes: 0,
        categories: ['Sports'],
        date: DateTime.now());
    topic.id = '1';
    Widget deleteView = MaterialApp(
      home: TopicView(
        firestore: firestore,
        storage: storage,
        topic: topic,
        auth: MockFirebaseAuth(
            signedIn: true, mockUser: MockUser(uid: 'adminUser')),
        themeManager: themeManager,
      ),
    );

    await tester.pumpWidget(deleteView);

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete Topic'));
    await tester.tap(find.text('Delete Topic'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    final querySnapshot = await firestore.collection("activity").get();
    expect(querySnapshot.docs.isEmpty, true);
  });
}
