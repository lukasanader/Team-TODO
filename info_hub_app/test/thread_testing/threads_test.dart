import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/view/thread_view/custom_card.dart';
import 'package:info_hub_app/view/thread_view/thread_replies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/view/thread_view/threads.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/model/thread_models/thread_model.dart';
import 'package:info_hub_app/controller/thread_controllers/thread_controller.dart';

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

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: child);
  }

  testWidgets('CustomCard displays thread data', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Add a thread directly to the Firestore collection
    await firestore.collection('thread').add({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': false,
      'roleType': 'Admin',
      'topicId': testTopicId,
      'topicTitle': testTopicTitle,
    });

    // Retrieve the added thread to pass to CustomCard
    final snapshot = await firestore.collection('thread').get();
    final threadData = snapshot.docs.first.data();
    final thread = Thread.fromMap(threadData, snapshot.docs.first.id);

    // Create a ThreadController instance
    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    await tester.pumpWidget(createTestWidget(CustomCard(
      index: 0,
      thread: thread,
      controller: controller,
      threadId: thread.id,
    )));

    await tester.pumpAndSettle();

    expect(find.text('Test Title'), findsOneWidget);
  });

  testWidgets('ThreadApp adds a new thread', (WidgetTester tester) async {
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
        find.byKey(const Key('Description')), 'New thread description');
    await tester.tap(find.widgetWithText(TextButton, 'Submit'));
    await tester.pump();

    // check if the new thread was added to Firestore.
    final threads = await firestore
        .collection('thread')
        .where('title', isEqualTo: 'New Thread Title')
        .get();
    expect(threads.docs.isNotEmpty, isTrue);
  });

  testWidgets('ThreadApp shows error messages for empty inputs',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    await tester.pumpAndSettle();

    // Tap the FloatingActionButton to open the new thread dialog.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Try to submit without entering any data.
    await tester.tap(find.widgetWithText(TextButton, 'Submit'));
    await tester.pump();

    // Check for error messages.
    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
  });

  testWidgets('ThreadApp disposes controllers without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: testTopicId,
      topicTitle: testTopicTitle,
    )));

    await tester.pumpAndSettle();

    // Open the dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Close the app
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomCard _showDialog interaction and reopening',
      (WidgetTester tester) async {
    // Adding a thread document to Firestore
    String dummyDocId = 'dummyDocId';
    await firestore.collection('thread').doc(dummyDocId).set({
      'title': 'Original Title',
      'description': 'Original Description',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': Timestamp.now(),
      'isEdited': false,
      'roleType': 'Patient',
      'topicId': 'testTopicId',
      'topicTitle': 'Test Topic Title',
    });

    // Retrieving the thread data to initialize the CustomCard
    final doc = await firestore.collection('thread').doc(dummyDocId).get();
    final thread = Thread.fromMap(doc.data()!, doc.id);

    // Initialize CustomCard with the necessary parameters
    await tester.pumpWidget(createTestWidget(CustomCard(
      index: 0,
      thread: thread,
      controller: ThreadController(firestore: firestore, auth: mockAuth),
      threadId: thread.id,
    )));

    // Expand the card
    final expansionTriggerFinder = find.byKey(const Key('authorText_0'));
    await tester.tap(expansionTriggerFinder);
    await tester.pumpAndSettle();

    // Open the edit dialog
    final editButtonFinder = find.byKey(const Key('editIcon_0'));
    await tester.tap(editButtonFinder);
    await tester.pumpAndSettle();

    // Update the content
    await tester.enterText(find.byKey(const Key('Title')), 'Updated Title');
    await tester.enterText(
        find.byKey(const Key('Description')), 'Updated Description');
    final updateButtonFinder = find.byKey(const Key('updateButtonText'));
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
    find.byKey(const Key('Title'));
    find.byKey(const Key('Description'));

    expect(find.text('Updated Title'), findsOneWidget);
    expect(find.text('Updated Description'), findsOneWidget);

    final cancelButtonFinder = find.text('Cancel');
    await tester.tap(cancelButtonFinder);
    await tester.pumpAndSettle();
  });
  testWidgets('CustomCard shows (edited) text when isEdited is true',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Create a thread with isEdited set to true
    await firestore.collection('thread').add({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': true,
      'roleType': 'Admin',
      'topicId': 'testTopicId',
      'topicTitle': 'Test Topic Title',
    });

    // Retrieve the added thread to pass to CustomCard
    final snapshot = await firestore.collection('thread').get();
    final threadData = snapshot.docs.first.data();
    final thread = Thread.fromMap(threadData, snapshot.docs.first.id);

    final mockAuth = MockFirebaseAuth();

    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    // Render the CustomCard with the thread
    await tester.pumpWidget(createTestWidget(CustomCard(
      index: 0,
      thread: thread,
      controller: controller,
      threadId: thread.id,
    )));

    await tester.pumpAndSettle();

    // Expand the card to reveal the (edited) text
    await tester.tap(find.byKey(const Key('authorText_0')));
    await tester.pumpAndSettle();

    // Check if the (edited) text is displayed
    expect(find.byKey(const Key('editedText_0')), findsOneWidget);
  });

  testWidgets('CustomCard delete thread interaction',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Create and add a thread to the Firestore collection
    String dummyThreadId = 'dummyThreadId';
    await firestore.collection('thread').add({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': false,
      'roleType': 'Admin',
      'topicId': 'testTopicId',
      'topicTitle': 'Test Topic Title',
    });

    // Retrieve the added thread to pass to CustomCard
    final snapshot =
        await firestore.collection('thread').doc(dummyThreadId).get();
    if (snapshot.exists && snapshot.data() != null) {
      final thread = Thread.fromMap(snapshot.data()!, snapshot.id);

      final controller =
          ThreadController(firestore: firestore, auth: FirebaseAuth.instance);

      // Render the CustomCard with the thread
      await tester.pumpWidget(createTestWidget(CustomCard(
        index: 0,
        thread: thread,
        controller: controller,
        threadId: thread.id,
      )));

      // Ensure the widget is built
      await tester.pumpAndSettle();

      // Tap on the delete button
      await tester.tap(find.byType(TextButton));
      await tester.pump(); // Rebuild the widget

      // Verify that the AlertDialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verify the content of the AlertDialog
      expect(find.text('Delete Thread'), findsOneWidget);
      expect(
          find.text(
              "Deleting your Thread will also delete all replies associated with it."),
          findsOneWidget);

      // Tap on the 'Delete Thread' button in the dialog
      await tester.tap(find.widgetWithText(TextButton, 'Delete Thread'));
      await tester.pump(); // Rebuild the widget

      await tester.pumpAndSettle();

      expect(find.byType(CustomCard), findsNothing);
    }
  });
  testWidgets('CustomCard calls deleteThread on delete button press',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Create a thread in Firestore
    const threadId = 'dummyThreadId';
    await firestore.collection('thread').doc(threadId).set({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': Timestamp.now(),
      'isEdited': false,
      'roleType': 'Admin',
      'topicId': 'testTopicId',
      'topicTitle': 'Test Topic Title',
    });

    final snapshot = await firestore.collection('thread').doc(threadId).get();
    final thread = Thread.fromMap(snapshot.data()!, snapshot.id);

    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    await tester.pumpWidget(createTestWidget(CustomCard(
      index: 0,
      thread: thread,
      controller: controller,
      threadId: thread.id,
    )));

    await tester.pumpAndSettle();

    // Find the delete button
    await tester.tap(find.byKey(const Key('authorText_0')));
    await tester.pumpAndSettle();

    // Tap on the delete button
    await tester.tap(find.byKey(const Key('deleteIcon_0')));
    await tester.pump();

    // Now, check if the AlertDialog is shown as a result of tapping the delete button
    expect(find.byType(AlertDialog), findsOneWidget);

    expect(find.text('Delete Thread'), findsOneWidget);
  });
  testWidgets('CustomCard navigates to ThreadReplies on tap',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Create a thread in Firestore
    const threadId = 'dummyThreadId';
    await firestore.collection('thread').doc(threadId).set({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': Timestamp.now(),
      'isEdited': false,
      'roleType': 'Admin',
      'topicId': 'testTopicId',
      'topicTitle': 'Test Topic Title',
    });

    final snapshot = await firestore.collection('thread').doc(threadId).get();
    final thread = Thread.fromMap(snapshot.data()!, snapshot.id);

    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    await tester.pumpWidget(createTestWidget(MaterialApp(
      home: CustomCard(
        index: 0,
        thread: thread,
        controller: controller,
        threadId: thread.id,
      ),
    )));

    await tester.pumpAndSettle();

    // Simulate a tap on the InkWell widget
    await tester.tap(find.byKey(const Key('navigateToThreadReplies_0')));
    await tester.pumpAndSettle(); // Wait for the navigation to complete

    // Check if ThreadReplies screen is pushed onto the navigation stack
    expect(find.byType(ThreadReplies), findsOneWidget);
  });

  testWidgets('CustomCard shows AlertDialog and handles actions',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Create a thread in Firestore
    const threadId = 'dummyThreadId';
    await firestore.collection('thread').doc(threadId).set({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': Timestamp.now(),
      'isEdited': false,
      'roleType': 'Admin',
      'topicId': 'testTopicId',
      'topicTitle': 'Test Topic Title',
    });

    final snapshot = await firestore.collection('thread').doc(threadId).get();
    final thread = Thread.fromMap(snapshot.data()!, snapshot.id);

    final controller = ThreadController(firestore: firestore, auth: mockAuth);

    await tester.pumpWidget(createTestWidget(MaterialApp(
      home: CustomCard(
        index: 0,
        thread: thread,
        controller: controller,
        threadId: thread.id,
      ),
    )));

    // Expand the card
    final expansionTriggerFinder = find.byKey(const Key('authorText_0'));
    await tester.tap(expansionTriggerFinder);
    await tester.pumpAndSettle();

    // Open the edit dialog
    final deleteButtonFinder = find.byKey(const Key('deleteIcon_0'));
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    // Verify the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Warning!'), findsOneWidget);
    expect(
        find.text(
            "Deleting your Thread will also delete all replies associated with it. Do you want to proceed?"),
        findsOneWidget);

    // Test the 'Close' button
    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    // Reopen the dialog to test the 'Delete Thread' button
    await tester.tap(expansionTriggerFinder);

    await tester.tap(find.byKey(const Key('deleteIcon_0')));
    await tester.pumpAndSettle();

    // Tap 'Delete Thread' and verify the dialog closes and the deleteThread method is called
    await tester.tap(find.widgetWithText(TextButton, 'Delete Thread'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing); // Dialog should be closed
  });
  test('getUserRoleType returns correct role type', () async {
    final firestore = FakeFirebaseFirestore();
    const userId = 'testUserId';
    const expectedRoleType = 'Admin';

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
    const threadId = 'testThreadId';

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
    const userId = 'testUserId';
    final expectedUserData = {'name': 'Test User', 'email': 'test@example.com'};

    await firestore.collection('Users').doc(userId).set(expectedUserData);

    final controller = ThreadController(firestore: firestore, auth: mockAuth);
    final userData = await controller.getUserData(userId);

    expect(userData, equals(expectedUserData));
  });

  test('getThreads returns a stream of threads for a specific topic', () async {
    final firestore = FakeFirebaseFirestore();
    const topicId = 'testTopicId';

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
}

Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
