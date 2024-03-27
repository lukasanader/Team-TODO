import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/threads/views/custom_card.dart';
import 'package:info_hub_app/threads/views/thread_replies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/views/threads.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/main.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:info_hub_app/threads/controllers/name_generator_controller.dart';
import 'package:info_hub_app/threads/models/thread_model.dart';
import 'package:info_hub_app/threads/models/thread_replies_model.dart';
import 'package:info_hub_app/threads/controllers/thread_controller.dart';
import 'package:info_hub_app/threads/views/reply_card.dart';
import 'package:info_hub_app/threads/views/admin_view_threads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

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

    // Initialize allNouns and allAdjectives before each test
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: child);
  }

  /*
  
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
          find.byKey(const Key('navigateToThreadReplies_0'));

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
  });

  GlobalKey<State<ThreadApp>> threadAppStateKey = GlobalKey<State<ThreadApp>>();

  testWidgets('StreamBuilder receives data', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(ThreadApp(
      firestore: firestore,
      auth: mockAuth,
      topicId: 'testTopicId',
      topicTitle: 'Test Topic',
    )));

    await tester.pumpAndSettle();

    expect(find.text('Test Title 1'), findsOneWidget);
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

    final inkWellFinder = find.byKey(const Key('navigateToThreadReplies_0'));
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
    final titleTextField = find.byKey(const Key('Title'));
    final descriptionTextField = find.byKey(const Key('Description'));

    expect(find.text('Updated Title'), findsOneWidget);
    expect(find.text('Updated Description'), findsOneWidget);

    // Optional: Close the dialog after checking
    final cancelButtonFinder = find.text('Cancel');
    await tester.tap(cancelButtonFinder);
    await tester.pumpAndSettle();
  }); 
  */
  testWidgets('CustomCard displays thread data', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Add a thread directly to the Firestore collection
    await firestore.collection('thread').add({
      'title': 'Test Title',
      'description': 'Test Description',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': FieldValue.serverTimestamp(), // Simulate server timestamp
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

    // Here, check if the new thread was added to Firestore.
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

    // Since there's no direct way to check if dispose was called on the TextEditingController,
    // we ensure that there are no errors thrown by Flutter when the widget is disposed.
    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomCard _showDialog interaction and reopening',
      (WidgetTester tester) async {
    // Or your mock FirebaseAuth instance

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
    final titleTextField = find.byKey(const Key('Title'));
    final descriptionTextField = find.byKey(const Key('Description'));

    expect(find.text('Updated Title'), findsOneWidget);
    expect(find.text('Updated Description'), findsOneWidget);

    // Optional: Close the dialog after checking
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
      'isEdited': true, // Setting isEdited to true
      'roleType': 'Admin',
      'topicId': 'testTopicId',
      'topicTitle': 'Test Topic Title',
    });

    // Retrieve the added thread to pass to CustomCard
    final snapshot = await firestore.collection('thread').get();
    final threadData = snapshot.docs.first.data();
    final thread = Thread.fromMap(threadData, snapshot.docs.first.id);

    // Assume you have a MockFirebaseAuth for the test
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
    await tester.tap(find.byKey(Key('authorText_0')));
    await tester.pumpAndSettle();

    // Check if the (edited) text is displayed
    expect(find.byKey(Key('editedText_0')), findsOneWidget);
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

      // Now proceed with your test, knowing that thread is not null
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

      await tester
          .pumpAndSettle(); // Wait for any animations or state updates to complete

// You can check if the CustomCard widget is no longer displayed
// This assumes that the CustomCard would be removed from the UI upon successful deletion
      expect(find.byType(CustomCard), findsNothing);

// Or, if there's a specific success message or state change in the UI, check for that
// For example, if a snackbar message is shown upon successful deletion, you could check for it
// expect(find.byType(SnackBar), findsOneWidget);
// expect(find.text('Thread successfully deleted'), findsOneWidget);
    }
  });
  testWidgets('CustomCard calls deleteThread on delete button press',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    // Create a thread in Firestore
    final threadId = 'dummyThreadId';
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
    await tester.tap(find.byKey(Key('authorText_0')));
    await tester.pumpAndSettle();

    // Tap on the delete button identified by 'deleteIcon_0'
    await tester.tap(find.byKey(Key('deleteIcon_0')));
    await tester.pump(); // Trigger a frame

    // Now, check if the AlertDialog is shown as a result of tapping the delete button
    expect(find.byType(AlertDialog), findsOneWidget);

    // You can also check for specific text within the AlertDialog to ensure it's the correct one
    expect(find.text('Delete Thread'), findsOneWidget);
    expect(
        find.text(
            "Deleting your Thread will also delete all replies associated with it."),
        findsOneWidget);
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
