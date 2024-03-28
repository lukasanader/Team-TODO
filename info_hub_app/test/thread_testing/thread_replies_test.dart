import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_hub_app/threads/views/thread_replies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/threads/models/thread_replies_model.dart';
import 'package:info_hub_app/threads/controllers/thread_controller.dart';
import 'package:info_hub_app/threads/views/reply_card.dart';

class MockThreadController extends Mock implements ThreadController {}

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

    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  test('Reply.fromMap creates a Reply object from Map data', () {
    final replyData = {
      'id': replyId,
      'content': 'Test Content',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': Timestamp.now(),
      'isEdited': false,
      'userProfilePhoto': 'photo.jpg',
      'threadId': testThreadId,
      'threadTitle': 'Thread Title',
      'roleType': 'Role Type',
    };

    final reply = Reply.fromMap(replyData, replyId);

    expect(reply.id, replyId);
    expect(reply.content, 'Test Content');
    expect(reply.creator, 'dummyUid');
  });
  testWidgets('Deleting a reply shows confirmation dialog in ReplyCard',
      (WidgetTester tester) async {
    final reply = Reply(
      id: 'replyId',
      content: 'Test Reply',
      creator: 'dummyUid',
      authorName: 'Author Name',
      timestamp: DateTime.now(),
      isEdited: false,
      userProfilePhoto: 'default_profile_photo.png',
      threadId: 'testThreadId',
      threadTitle: 'Test Thread Title',
      roleType: 'User',
    );

    await tester.pumpWidget(createTestWidget(ReplyCard(
      reply: reply,
      controller: ThreadController(firestore: firestore, auth: mockAuth),
    )));

    await tester.pumpAndSettle();

    // Expand the card
    final expansionTriggerFinder = find.byKey(const Key('authorText_0'));
    await tester.tap(expansionTriggerFinder);
    await tester.pumpAndSettle();

    // Tap the delete button and handle the confirmation dialog
    final deleteButtonFinder = find.byKey(const Key('deleteButton_0'));
    expect(deleteButtonFinder, findsOneWidget); // Ensure the button is found
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    // Verify the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Warning'), findsOneWidget);
    expect(find.text("Are you sure you want to delete your reply?"),
        findsOneWidget);

    // Interact with the AlertDialog
    await tester.tap(find.widgetWithText(TextButton, 'Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Editing a reply shows dialog in ReplyCard',
      (WidgetTester tester) async {
    final replyId = 'replyId';
    final threadId = 'testThreadId';
    final content = 'Test Reply';
    final creatorId = 'dummyUid';

    await firestore.collection('replies').doc(replyId).set({
      'content': content,
      'creator': creatorId,
      'threadId': threadId,
    });

    final reply = Reply(
      id: replyId,
      content: content,
      creator: creatorId,
      authorName: 'Author Name',
      timestamp: DateTime.now(),
      isEdited: false,
      userProfilePhoto: 'default_profile_photo.png',
      threadId: threadId,
      threadTitle: 'Test Thread Title',
      roleType: 'User',
    );

    await tester.pumpWidget(createTestWidget(ReplyCard(
      reply: reply,
      controller: ThreadController(firestore: firestore, auth: mockAuth),
    )));

    await tester.pumpAndSettle();

    // Expand the card
    final expansionTriggerFinder = find.byKey(const Key('authorText_0'));
    expect(expansionTriggerFinder, findsOneWidget);
    await tester.tap(expansionTriggerFinder);
    await tester.pumpAndSettle();

    // Simulate tapping the edit button
    final editButtonFinder = find.byKey(const Key('editButton_0'));
    expect(editButtonFinder, findsOneWidget);
    await tester.tap(editButtonFinder);
    await tester.pumpAndSettle();

    // Verify the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    // Test updating the content
    await tester.enterText(find.byKey(const Key('Content')), 'Updated Reply');
    await tester.tap(find.byKey(const Key('updateButtonText')));
    await tester.pumpAndSettle();

    // Verify the dialog is closed and check the updated content in Firestore
    expect(find.byType(AlertDialog), findsNothing);

    final updatedDoc = await firestore.collection('replies').doc(replyId).get();
    expect(updatedDoc.get('content'), 'Updated Reply');
  });

  testWidgets('Replies are displayed in ThreadReplies',
      (WidgetTester tester) async {
    await firestore.collection('replies').add({
      'content': 'Test Reply',
      'creator': 'dummyUid',
      'authorName': 'Author Name',
      'timestamp': Timestamp.now(),
      'threadId': 'testThreadId',
      'isEdited': false,
      'userProfilePhoto': 'default_profile_photo.png',
      'threadTitle': 'Test Thread Title',
      'roleType': 'User',
    });

    await tester.pumpWidget(createTestWidget(ThreadReplies(
      firestore: firestore,
      auth: mockAuth,
      threadId: 'testThreadId',
      threadTitle: 'Test Thread Title',
    )));

    await tester.pumpAndSettle();

    expect(find.byType(ReplyCard), findsOneWidget);
    expect(find.text('Test Reply'), findsOneWidget);
  });

  testWidgets('Add reply updates UI and Firestore',
      (WidgetTester tester) async {
    final mockFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(
      MaterialApp(
        home: ThreadReplies(
          threadId: 'testThreadId',
          threadTitle: 'Test Thread Title',
          firestore: mockFirestore,
          auth: mockAuth,
        ),
      ),
    );

    // Trigger the reply dialog
    await tester.tap(find.byIcon(FontAwesomeIcons.reply));
    await tester.pumpAndSettle();

    // Fill the reply content and submit
    await tester.enterText(find.byKey(const Key('Content')), 'Test Reply');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Test Reply'), findsOneWidget);

    // Check if the new reply is added to Firestore
    final docRef = await mockFirestore
        .collection('replies')
        .where('content', isEqualTo: 'Test Reply')
        .get();
    expect(docRef.docs.isNotEmpty, isTrue);
  });
  testWidgets('Add reply updates UI and Firestore',
      (WidgetTester tester) async {
    final mockFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(
      MaterialApp(
        home: ThreadReplies(
          threadId: 'testThreadId',
          threadTitle: 'Test Thread Title',
          firestore: mockFirestore,
          auth: mockAuth,
        ),
      ),
    );

    // Trigger the reply dialog
    await tester.tap(find.byIcon(FontAwesomeIcons.reply));
    await tester.pumpAndSettle();

    // Fill the reply content and submit
    await tester.enterText(find.byKey(const Key('Content')), 'Test Reply');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Test Reply'), findsOneWidget);

    // Check if the new reply is added to Firestore
    final docRef = await mockFirestore
        .collection('replies')
        .where('content', isEqualTo: 'Test Reply')
        .get();
    expect(docRef.docs.isNotEmpty, isTrue);
  });

  testWidgets('Reply ID is updated after adding to Firestore',
      (WidgetTester tester) async {
    final mockFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(createTestWidget(
      ThreadReplies(
          firestore: firestore,
          auth: mockAuth,
          threadId: 'testThreadId',
          threadTitle: 'Test Thread Title'),
    ));

    final String content = 'Test Reply';
    await tester.tap(find.byIcon(FontAwesomeIcons.reply));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('Content')), content);
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    final ThreadRepliesState state = tester.state(find.byType(ThreadReplies));
    final List<Reply> localReplies = state.localReplies;

    expect(localReplies, isNotEmpty);
    expect(localReplies.any((reply) => reply.content == content), isTrue);

    final String newReplyId = 'someGeneratedFirestoreDocId';

    // Simulate Firestore updating the document ID
    final Reply addedReply =
        localReplies.firstWhere((reply) => reply.content == content);
    final int addedReplyIndex = localReplies.indexOf(addedReply);

    // Update the reply ID with the simulated Firestore document ID
    localReplies[addedReplyIndex] = Reply(
      id: newReplyId,
      content: addedReply.content,
      creator: addedReply.creator,
      authorName: addedReply.authorName,
      timestamp: addedReply.timestamp,
      isEdited: addedReply.isEdited,
      userProfilePhoto: addedReply.userProfilePhoto,
      threadId: addedReply.threadId,
      threadTitle: addedReply.threadTitle,
      roleType: addedReply.roleType,
    );

    // Re-render the widget to apply state changes
    await tester.pumpAndSettle();

    // Verify the ID is updated in the local list
    expect(localReplies.any((reply) => reply.id == newReplyId), isTrue);
  });

  testWidgets('Reply ID state is modified after adding to Firestore',
      (WidgetTester tester) async {
    final mockFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(createTestWidget(
      ThreadReplies(
          firestore: mockFirestore,
          auth: mockAuth,
          threadId: 'testThreadId',
          threadTitle: 'Test Thread Title'),
    ));

    await tester.tap(find.byIcon(FontAwesomeIcons.reply));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('Content')), 'Test Reply');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    final ThreadRepliesState state = tester.state(find.byType(ThreadReplies));
    final List<Reply> localReplies = state.localReplies;

    expect(localReplies, isNotEmpty);
    expect(localReplies.any((reply) => reply.content == 'Test Reply'), isTrue);

    final String newReplyId = 'newFirestoreDocId';
    final Reply originalReply = localReplies.first;
    final Reply updatedReply = Reply(
      id: newReplyId,
      content: originalReply.content,
      creator: originalReply.creator,
      authorName: originalReply.authorName,
      timestamp: originalReply.timestamp,
      isEdited: originalReply.isEdited,
      userProfilePhoto: originalReply.userProfilePhoto,
      threadId: originalReply.threadId,
      threadTitle: originalReply.threadTitle,
      roleType: originalReply.roleType,
    );

    state.setState(() {
      final int replyIndex = localReplies.indexOf(originalReply);
      localReplies[replyIndex] = updatedReply;
    });

    await tester.pumpAndSettle();

    expect(localReplies.any((reply) => reply.id == newReplyId), isTrue);
  });

  testWidgets('Error state when reply content is empty',
      (WidgetTester tester) async {
    final mockFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(createTestWidget(
      ThreadReplies(
          firestore: firestore,
          auth: mockAuth,
          threadId: 'testThreadId',
          threadTitle: 'Test Thread Title'),
    ));

    await tester.tap(find.byIcon(FontAwesomeIcons.reply));
    await tester.pumpAndSettle();

    // Attempt to submit an empty reply
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Check if the error state is shown
    expect(find.text('Please enter a reply'), findsOneWidget);
  });

  testWidgets('Cancel button dismisses reply dialog',
      (WidgetTester tester) async {
    final mockFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(createTestWidget(
      ThreadReplies(
          firestore: firestore,
          auth: mockAuth,
          threadId: 'testThreadId',
          threadTitle: 'Test Thread Title'),
    ));

    // Open the dialog
    await tester.tap(find.byIcon(FontAwesomeIcons.reply));
    await tester.pumpAndSettle();

    // Tap the 'Cancel' button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Check if the dialog is dismissed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Error state when reply content is empty',
      (WidgetTester tester) async {
    final mockFirestore = FakeFirebaseFirestore();
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(createTestWidget(
      ThreadReplies(
          firestore: firestore,
          auth: mockAuth,
          threadId: 'testThreadId',
          threadTitle: 'Test Thread Title'),
    ));

    // Open the dialog
    await tester.tap(find.byIcon(FontAwesomeIcons.reply));
    await tester.pumpAndSettle();

    // Attempt to submit an empty reply
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Check if the error state is shown
    expect(find.text('Please enter a reply'), findsOneWidget);
  });

  testWidgets('Tapping back icon pops the current screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ThreadReplies(
                            threadId: 'testThreadId',
                            threadTitle: 'Test Thread Title',
                            firestore: FakeFirebaseFirestore(),
                            auth: MockFirebaseAuth(),
                          )));
                },
                child: const Text('Go to ThreadReplies'),
              ),
            );
          },
        ),
      ),
    ));

    // Simulate a tap to navigate to the ThreadReplies screen.
    await tester.tap(find.text('Go to ThreadReplies'));
    await tester.pumpAndSettle(); // Finish the animation

    // ThreadReplies screen is displayed
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(); // Finish the animation

    // Verify that popping the screen brings us back to the initial screen.
    expect(find.text('Go to ThreadReplies'), findsOneWidget);
  });

  testWidgets('Displays "(edited)" text for edited replies',
      (WidgetTester tester) async {
    final reply = Reply(
      id: 'replyId',
      content: 'Test Reply',
      creator: 'dummyUid',
      authorName: 'Author Name',
      timestamp: DateTime.now(),
      isEdited: true,
      userProfilePhoto: 'default_profile_photo.png',
      threadId: 'testThreadId',
      threadTitle: 'Test Thread Title',
      roleType: 'User',
    );

    await tester.pumpWidget(createTestWidget(ReplyCard(
      reply: reply,
      controller: ThreadController(
          firestore: FakeFirebaseFirestore(), auth: MockFirebaseAuth()),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ExpansionTileCard));

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editedText')), findsOneWidget);
  });

  testWidgets('Displays healthcare professional texts for respective role type',
      (WidgetTester tester) async {
    final reply = Reply(
      id: 'replyId',
      content: 'Test Reply',
      creator: 'dummyUid',
      authorName: 'Author Name',
      timestamp: DateTime.now(),
      isEdited: false,
      userProfilePhoto: 'default_profile_photo.png',
      threadId: 'testThreadId',
      threadTitle: 'Test Thread Title',
      roleType: 'Healthcare Professional',
    );

    await tester.pumpWidget(createTestWidget(ReplyCard(
      reply: reply,
      controller: ThreadController(
          firestore: FakeFirebaseFirestore(), auth: MockFirebaseAuth()),
    )));

    await tester.pumpAndSettle();
    await tester.tap(find.byType(ExpansionTileCard));
    await tester.pumpAndSettle();
    expect(find.text('Healthcare'), findsOneWidget);
    expect(find.text('Professional'), findsOneWidget);
  });

  testWidgets('Cancel button closes the edit dialog in ReplyCard',
      (WidgetTester tester) async {
    final reply = Reply(
      id: 'replyId',
      content: 'Test Reply',
      creator: 'dummyUid',
      authorName: 'Author Name',
      timestamp: DateTime.now(),
      isEdited: false,
      userProfilePhoto: 'default_profile_photo.png',
      threadId: 'testThreadId',
      threadTitle: 'Test Thread Title',
      roleType: 'User',
    );

    final threadController = ThreadController(
      firestore: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ReplyCard(
          reply: reply,
          controller: threadController,
        ),
      ),
    ));

    // Tap to expand the ExpansionTileCard to reveal the action buttons.
    await tester.tap(find.byType(ExpansionTileCard));
    await tester.pumpAndSettle();

    // Simulate tapping the edit button to open the dialog.
    await tester.tap(find.byKey(const Key('editButton_0')));
    await tester.pumpAndSettle();

    // Check that the dialog is displayed.
    expect(find.byType(AlertDialog), findsOneWidget);

    // Tap the "Cancel" button to close the dialog.
    await tester.tap(find.byKey(const Key('cancelButton')));
    await tester.pumpAndSettle();

    // Check that the dialog is no longer displayed.
    expect(find.byType(AlertDialog), findsNothing);
  });
}
