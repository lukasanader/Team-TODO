import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/threads/models/thread_model.dart';
import 'package:info_hub_app/threads/models/thread_replies_model.dart';
import 'package:info_hub_app/threads/controllers/thread_controller.dart';

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
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  late FakeFirebaseFirestore firestore;
  late FirebaseAuth mockAuth;
  const String testTopicId = "testTopicId";
  const String testTopicTitle = "testTopicTitle";

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

    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });

  test('getUserRoleType returns correct role type', () async {
    final firestore = FakeFirebaseFirestore();
    final userId = 'testUserId';
    final expectedRoleType = 'Admin';

    await firestore
        .collection('Users')
        .doc(userId)
        .set({'roleType': expectedRoleType});

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final roleType = await controller.getUserRoleType(userId);

    expect(roleType, equals(expectedRoleType));
  });

  test('deleteThread deletes the thread and its replies', () async {
    final firestore = FakeFirebaseFirestore();
    final threadId = 'testThreadId';

    // Simulate existing replies associated with the thread
    await firestore.collection('replies').add({'threadId': threadId});

    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    await controller.deleteThread(threadId);

    final threadExists =
        (await firestore.collection('thread').doc(threadId).get()).exists;
    final repliesExist = (await firestore
            .collection('replies')
            .where('threadId', isEqualTo: threadId)
            .get())
        .docs
        .isNotEmpty;

    expect(threadExists, isFalse);
    expect(repliesExist, isFalse);
  });

  test('getUserData retrieves user data correctly', () async {
    final firestore = FakeFirebaseFirestore();
    final userId = 'testUserId';
    final expectedUserData = {'name': 'Test User', 'email': 'test@example.com'};

    await firestore.collection('Users').doc(userId).set(expectedUserData);

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final userData = await controller.getUserData(userId);

    expect(userData, equals(expectedUserData));
  });

  test('getThreads returns a stream of threads for a specific topic', () async {
    final firestore = FakeFirebaseFirestore();
    final topicId = 'testTopicId';

    // Adding threads for the specific topic
    await firestore
        .collection('thread')
        .add({'topicId': topicId, 'content': 'Thread 1'});
    await firestore
        .collection('thread')
        .add({'topicId': 'otherTopicId', 'content': 'Thread 2'});

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final stream = controller.getThreads(topicId);

    final QuerySnapshot querySnapshot = await stream.first;
    final List<QueryDocumentSnapshot> threads = querySnapshot.docs;

    final containsOnlySpecificTopic =
        threads.every((doc) => doc['topicId'] == topicId);

    expect(containsOnlySpecificTopic, isTrue);
  });

  test('getUserProfileImage returns correct AssetImage', () async {
    final firestore = FakeFirebaseFirestore();
    final userId = 'testUserId';
    final expectedImageFilename = 'profile_photo.png';

    await firestore
        .collection('Users')
        .doc(userId)
        .set({'selectedProfilePhoto': expectedImageFilename});

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final imageProvider = await controller.getUserProfileImage(userId);

    expect(imageProvider, isA<AssetImage>());
    expect((imageProvider as AssetImage).assetName,
        equals('assets/$expectedImageFilename'));
  });

  test('getUserProfilePhotoFilename returns the correct filename', () async {
    final firestore = FakeFirebaseFirestore();
    final userId = 'testUserId';
    final expectedFilename = 'user_profile.png';

    await firestore
        .collection('Users')
        .doc(userId)
        .set({'selectedProfilePhoto': expectedFilename});

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final filename = await controller.getUserProfilePhotoFilename(userId);

    expect(filename, equals(expectedFilename));
  });

  test('getThreadListStream returns a stream of threads for a specific topic',
      () async {
    final firestore = FakeFirebaseFirestore();
    final topicId = 'testTopicId';

    await firestore
        .collection('thread')
        .add({'topicId': topicId, 'content': 'Content 1'});
    await firestore
        .collection('thread')
        .add({'topicId': 'anotherTopic', 'content': 'Content 2'});

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final stream = controller.getThreadListStream(topicId);

    final List<Thread> threads = await stream.first;
    expect(threads.length, equals(1));
    expect(threads.first.topicId, equals(topicId));
  });

  test('getAllThreadsStream returns a stream of all threads', () async {
    final firestore = FakeFirebaseFirestore();

    await firestore
        .collection('thread')
        .add({'topicId': 'topic1', 'content': 'Content 1'});
    await firestore
        .collection('thread')
        .add({'topicId': 'topic2', 'content': 'Content 2'});

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final stream = controller.getAllThreadsStream();

    final List<Thread> threads = await stream.first;
    expect(threads.length, equals(2));
  });

  test('getThreadData returns data for a specific thread', () async {
    final firestore = FakeFirebaseFirestore();
    final threadId = 'testThreadId';

    await firestore
        .collection('thread')
        .doc(threadId)
        .set({'content': 'Content 1', 'topicId': 'topic1'});

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final Map<String, dynamic>? threadData =
        await controller.getThreadData(threadId);

    expect(threadData, isNotNull);
    expect(threadData!['content'], equals('Content 1'));
  });

  test('getThreadDocument retrieves the correct thread', () async {
    final firestore = FakeFirebaseFirestore();
    final threadId = 'testThreadId';

    // Create a thread
    await firestore.collection('thread').doc(threadId).set({
      'title': 'Test Title',
      'description': 'Test Description',
    });

    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Retrieve the thread
    final thread = await controller.getThreadDocument(threadId);

    expect(thread.title, 'Test Title');
    expect(thread.description, 'Test Description');
  });

  test('getAllRepliesStream returns all replies', () async {
    final firestore = FakeFirebaseFirestore();
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Add sample replies
    await firestore.collection('replies').add({'content': 'Reply 1'});
    await firestore.collection('replies').add({'content': 'Reply 2'});

    // Get the replies stream
    final stream = controller.getAllRepliesStream();
    final List<Reply> replies = await stream.first;

    expect(replies.length, 2);
  });

  test('getRepliesStream returns replies for a specific thread', () async {
    final firestore = FakeFirebaseFirestore();
    final threadId = 'testThreadId';
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Add replies for two different threads
    await firestore
        .collection('replies')
        .add({'threadId': threadId, 'content': 'Reply 1'});
    await firestore
        .collection('replies')
        .add({'threadId': 'anotherThreadId', 'content': 'Reply 2'});

    // Get replies for the specific thread
    final stream = controller.getRepliesStream(threadId);
    final List<Reply> replies = await stream.first;

    expect(replies.length, 1);
    expect(replies.first.content, 'Reply 1');
  });

  test('addThread adds a new thread correctly', () async {
    final firestore = FakeFirebaseFirestore();
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    final newThread = Thread(
      id: '',
      title: 'New Thread',
      description: 'Description',
      creator: 'Creator',
      authorName: 'Author',
      timestamp: DateTime.now(),
      isEdited: false,
      roleType: 'Role',
      topicId: 'TopicID',
      topicTitle: 'Topic Title',
    );

    // Add the thread
    await controller.addThread(newThread);

    // Verify the thread was added
    final querySnapshot = await firestore
        .collection('thread')
        .where('title', isEqualTo: 'New Thread')
        .get();
    expect(querySnapshot.docs.isNotEmpty, true);
  });

  test('updateThread updates the thread correctly', () async {
    final firestore = FakeFirebaseFirestore();
    final threadId = 'testThreadId';

    // Create a thread
    await firestore.collection('thread').doc(threadId).set({
      'title': 'Old Title',
      'description': 'Old Description',
    });

    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Update the thread
    await controller.updateThread(threadId, 'New Title', 'New Description');

    // Check if the thread was updated
    final updatedThread =
        await firestore.collection('thread').doc(threadId).get();
    final data = updatedThread.data();
    expect(data!['title'], 'New Title');
    expect(data['description'], 'New Description');
    expect(data['isEdited'], true);
  });

  test(
      'isUserCreator correctly compares the current user\'s UID with the creatorId',
      () {
    final mockAuth = MockFirebaseAuth();

    final controller =
        ThreadController(firestore: FakeFirebaseFirestore(), auth: mockAuth);

    expect(controller.isUserCreator('dummyUid'), true);
    expect(controller.isUserCreator('anotherUid'), false);
  });

  test('getCurrentUserId returns the current user\'s UID', () {
    final mockAuth = MockFirebaseAuth();

    final controller =
        ThreadController(firestore: FakeFirebaseFirestore(), auth: mockAuth);

    expect(controller.getCurrentUserId(), 'dummyUid');
  });

  test('formatDate formats timestamp correctly', () {
    final controller =
        ThreadController(firestore: FakeFirebaseFirestore(), auth: mockAuth);
    final dateTime = DateTime(2023, 1, 1, 12, 0); // January 1, 2023, at 12:00

    expect(controller.formatDate(dateTime), '01-Jan-2023 at 12:00');
    expect(controller.formatDate(null), 'Timestamp not available');
  });

  test('getRoleIcon returns correct icon for each role type', () {
    final controller =
        ThreadController(firestore: FakeFirebaseFirestore(), auth: mockAuth);

    expect(controller.getRoleIcon('Patient'), Icons.local_hospital);
    expect(controller.getRoleIcon('Healthcare Professional'),
        Icons.medical_services);
    expect(controller.getRoleIcon('Parent'), Icons.family_restroom);
    expect(controller.getRoleIcon('admin'), Icons.admin_panel_settings);
    expect(controller.getRoleIcon('unknown'), Icons.help_outline);
  });

  test('getThreadDocument returns fallback Thread when no document exists',
      () async {
    final firestore = FakeFirebaseFirestore();
    final threadId = 'nonexistentThreadId';
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    final thread = await controller.getThreadDocument(threadId);

    expect(thread.id, 'Missing ID');
    expect(thread.title, 'No Title');
    expect(thread.description, 'No Description');
    expect(thread.creator, 'Missing Creator');
  });

  test('addReply adds a new reply to Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    final reply = Reply(
      id: '',
      content: 'Test Reply',
      creator: 'User1',
      threadId: 'Thread1',
      timestamp: DateTime.now(),
      isEdited: false,
      authorName: '',
      threadTitle: '',
      roleType: '',
      userProfilePhoto: '',
    );

    final docRef = await controller.addReply(reply);

    // Check if the document is added
    final docSnapshot =
        await firestore.collection('replies').doc(docRef.id).get();
    expect(docSnapshot.exists, isTrue);
    expect(docSnapshot.data()?['content'], equals('Test Reply'));
  });

  test('getReplies returns a stream of replies for a specific thread',
      () async {
    final firestore = FakeFirebaseFirestore();
    final threadId = 'Thread1';
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Add sample replies for different threads
    await firestore
        .collection('replies')
        .add({'threadId': threadId, 'content': 'Reply 1'});
    await firestore
        .collection('replies')
        .add({'threadId': 'Thread2', 'content': 'Reply 2'});

    // Get the replies stream for the specific thread
    final stream = controller.getReplies(threadId);
    final querySnapshot = await stream.first;

    final replies = querySnapshot.docs.map((doc) => doc.data()).toList();
    expect(replies.isNotEmpty, isTrue);
    expect((replies.first as Map<String, dynamic>)['content'], 'Reply 1');
  });

  test('updateReply updates the specified reply', () async {
    final firestore = FakeFirebaseFirestore();
    final replyId = 'Reply1';
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Add a reply to update
    await firestore
        .collection('replies')
        .doc(replyId)
        .set({'content': 'Original Content'});

    // Update the reply
    await controller.updateReply(replyId, 'Updated Content');

    // Check the update
    final updatedReply =
        await firestore.collection('replies').doc(replyId).get();
    expect(updatedReply.data()?['content'], 'Updated Content');
    expect(updatedReply.data()?['isEdited'], isTrue);
  });

  test('deleteReply deletes the specified reply', () async {
    final firestore = FakeFirebaseFirestore();
    final replyId = 'Reply1';
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Add a reply to delete
    await firestore
        .collection('replies')
        .doc(replyId)
        .set({'content': 'Reply Content'});

    // Delete the reply
    await controller.deleteReply(replyId);

    // Check the deletion
    final replySnapshot =
        await firestore.collection('replies').doc(replyId).get();
    expect(replySnapshot.exists, isFalse);
  });

  test('getReplyData fetches the correct reply data', () async {
    final firestore = FakeFirebaseFirestore();
    final replyId = 'Reply1';
    final expectedData = {'content': 'Reply Content'};
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Add a reply
    await firestore.collection('replies').doc(replyId).set(expectedData);

    // Fetch the reply data
    final replyData = await controller.getReplyData(replyId);

    expect(replyData, equals(expectedData));
  });
}

Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
