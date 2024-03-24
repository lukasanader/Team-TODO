//incomplete tests
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/threads/custom_card.dart';
import 'package:info_hub_app/threads/thread_replies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/threads.dart';
import 'package:info_hub_app/threads/reply_card.dart';
import 'package:mockito/mockito.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  late MockFirebaseAuth mockAuth;
  const String testTopicId = "testTopicId";
  const String testTopicTitle = "testTopicTitle";

  setUp(() {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('CustomCard Tests', () {
    testWidgets('CustomCard Cancel button clears input and closes the dialog',
        (WidgetTester tester) async {
      final threadId = await firestore.collection('thread').add({
        'title': 'Test Title',
        'description': 'Test Description',
        'creator': 'dummyUid',
        'timestamp': Timestamp.now(),
        'topicId': testTopicId,
        'topicTitle': testTopicTitle,
      }).then((doc) => doc.id);

      final snapshot = await firestore
          .collection('thread')
          .where('topicId', isEqualTo: testTopicId)
          .get();

      await tester.pumpWidget(createTestWidget(CustomCard(
        snapshot: snapshot,
        index: 0,
        firestore: firestore,
        auth: mockAuth,

      )));

      await tester.pumpAndSettle();

      // Open the edit dialog
      await tester.tap(find.byIcon(FontAwesomeIcons.edit).first);
      await tester.pumpAndSettle();

      // Cancel the edit
      await tester.tap(find.text('Cancel').first);
      await tester.pumpAndSettle();

      // Ensure the dialog is closed
      expect(find.text('Please fill out the form'), findsNothing);
    });

    testWidgets('CustomCard deletion process with batch delete',
        (WidgetTester tester) async {
      final threadId = await firestore.collection('thread').add({
        'title': 'Test Title',
        'description': 'Test Description',
        'creator': 'dummyUid',
        'timestamp': Timestamp.now(),
        'topicId': testTopicId,
      }).then((doc) => doc.id);

      // Add some replies to the thread
      await firestore.collection('replies').add({
        'content': 'Reply 1',
        'threadId': threadId,
      });

      await firestore.collection('replies').add({
        'content': 'Reply 2',
        'threadId': threadId,
      });

      final snapshot = await firestore
          .collection('thread')
          .where('topicId', isEqualTo: testTopicId)
          .get();

      await tester.pumpWidget(createTestWidget(CustomCard(
        snapshot: snapshot,
        index: 0,
        firestore: firestore,
        auth: mockAuth,
      )));

      await tester.pumpAndSettle();

      // Delete the thread and its replies
      await tester.tap(find.byIcon(FontAwesomeIcons.trashAlt).first);
      await tester.pumpAndSettle();

      // Verify the thread and its replies are deleted
      final threadSnapshot =
          await firestore.collection('thread').doc(threadId).get();
      final repliesSnapshot = await firestore
          .collection('replies')
          .where('threadId', isEqualTo: threadId)
          .get();

      expect(threadSnapshot.exists, isFalse);
      expect(repliesSnapshot.docs.length, 0);
    });

    testWidgets('CustomCard InkWell navigation to ThreadReplies',
        (WidgetTester tester) async {
      await firestore.collection('thread').add({
        'title': 'Test Title',
        'description': 'Test Description',
        'creator': 'dummyUid',
        'timestamp': Timestamp.now(),
        'topicId': testTopicId,
      });

      final snapshot = await firestore
          .collection('thread')
          .where('topicId', isEqualTo: testTopicId)
          .get();

      await tester.pumpWidget(createTestWidget(CustomCard(
        snapshot: snapshot,
        index: 0,
        firestore: firestore,
        auth: mockAuth,
      )));

      await tester.pumpAndSettle();

      // Tap on the specific InkWell using the key
      await tester.tap(find.byKey(Key('navigateToThreadReplies_0')));
      await tester.pumpAndSettle();

      // Verify navigation to ThreadReplies
      expect(find.byType(ThreadReplies), findsOneWidget);
    });

    testWidgets('ThreadApp updates thread on valid input',
        (WidgetTester tester) async {
      // Arrange: Prepare the widget and mock data
      final threadId = await firestore.collection('thread').add({
        'title': 'Test Title',
        'description': 'Test Description',
        'creator': 'dummyUid', // Matches MockUser's uid
        'timestamp': Timestamp.now(),
        'topicId': testTopicId,
        'topicTitle': testTopicTitle,
      }).then((doc) => doc.id);

      final snapshot = await firestore
          .collection('thread')
          .where('topicId', isEqualTo: testTopicId)
          .get();

      await tester.pumpWidget(createTestWidget(ThreadApp(
        firestore: firestore,
        auth: mockAuth,
        topicId: testTopicId,
        topicTitle: testTopicTitle,
      )));

      // Act: Simulate user interaction
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('editButton_$threadId')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('Title')), 'Updated Title');
      await tester.enterText(
          find.byKey(const Key('Description')), 'Updated Description');
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Assert: Check if the update operation is executed
      final updatedThread =
          await firestore.collection('thread').doc(threadId).get();
      expect(updatedThread.data()!['title'], equals('Updated Title'));
      expect(updatedThread.data()!['description'],
          contains('Updated Description (edited)'));
    });

    group('ThreadReplies Tests', () {
      testWidgets('ThreadReplies displays correct number of ReplyCards',
          (WidgetTester tester) async {
        // Add a thread and replies to Firestore
        final threadId = await firestore.collection('thread').add({
          'title': 'Test Thread',
          'description': 'Test Description',
          'creator': mockAuth.currentUser!.uid,
          'timestamp': Timestamp.now(),
        }).then((doc) => doc.id);

        await firestore.collection('replies').add({
          'content': 'Reply 1',
          'threadId': threadId,
        });

        await firestore.collection('replies').add({
          'content': 'Reply 2',
          'threadId': threadId,
        });

        // Render ThreadReplies
        await tester.pumpWidget(createTestWidget(ThreadReplies(
          threadId: threadId,
          firestore: firestore,
          auth: mockAuth,
        )));

        await tester.pumpAndSettle();

        // Verify two ReplyCard widgets are displayed
        expect(find.byType(ReplyCard), findsNWidgets(2));
      });

      testWidgets('Reply submission dialog interaction',
          (WidgetTester tester) async {
        final threadId = await firestore.collection('thread').add({
          'title': 'Test Thread',
          'description': 'Test Description',
          'creator': mockAuth.currentUser!.uid,
          'timestamp': Timestamp.now(),
        }).then((doc) => doc.id);

        // Render ThreadReplies
        await tester.pumpWidget(createTestWidget(ThreadReplies(
          threadId: threadId,
          firestore: firestore,
          auth: mockAuth,
        )));

        // Tap the floating action button to open the dialog
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Enter text into the TextField and submit
        await tester.enterText(find.byKey(const Key('Content')), 'Test Reply');
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // Verify dialog is closed
        expect(find.text('Please fill out the form'), findsNothing);

        // Verify that a reply was added to Firestore
        final replies = await firestore
            .collection('replies')
            .where('threadId', isEqualTo: threadId)
            .get();
        expect(replies.docs.length, greaterThanOrEqualTo(1));
      });

      testWidgets('Back navigation and FloatingActionButton in ThreadReplies',
          (WidgetTester tester) async {
        final threadId = await firestore.collection('thread').add({
          'title': 'Test Thread',
          'description': 'Test Description',
          'creator': mockAuth.currentUser!.uid,
          'timestamp': Timestamp.now(),
        }).then((doc) => doc.id);

        // Render ThreadReplies
        await tester.pumpWidget(createTestWidget(ThreadReplies(
          threadId: threadId,
          firestore: firestore,
          auth: mockAuth,
        )));

        await tester.pumpAndSettle();

        // Verify IconButton and FloatingActionButton are present
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Test back navigation (IconButton)
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        // Add additional verification as needed, e.g., checking navigation occurred
      });

      group('ReplyCard Tests', () {
        /*testWidgets('Error message shown when trying to submit empty content',
            (WidgetTester tester) async {
          // Setup test data and environment
          final threadId = await firestore.collection('thread').add({
            'title': 'Test Thread',
            'description': 'Test Description',
            'creator': mockAuth.currentUser!.uid,
            'timestamp': Timestamp.now(),
          }).then((doc) => doc.id);

          final docId = await firestore.collection('replies').add({
            'content': 'Reply 1',
            'threadId': threadId,
            'creator': mockAuth.currentUser!.uid,
            'timestamp': Timestamp.now(),
          }).then((doc) => doc.id);

          // Render ThreadReplies
          await tester.pumpWidget(createTestWidget(ThreadReplies(
            threadId: threadId,
            firestore: firestore,
            auth: mockAuth,
          )));

          await tester.pumpAndSettle();

          // Open the reply edit dialog
          await tester.tap(find.byKey(Key('editButton_$docId')));
          await tester.pumpAndSettle();

          // Try to submit without entering content
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Verify that error message is shown
          expect(find.text("Please enter content"), findsOneWidget);
        });

        testWidgets('Cancel button clears input and closes the dialog',
            (WidgetTester tester) async {
          // Setup test data and environment as in the previous test

          // Open the reply edit dialog as in the previous test

          // Tap on the cancel button
          await tester.tap(find.byKey(Key('cancelButton')));
          await tester.pumpAndSettle();

          // Verify that the dialog is closed
          expect(find.byType(AlertDialog), findsNothing);
        }); */

        testWidgets('Edit button opens the dialog and allows reply editing',
            (WidgetTester tester) async {
          final threadId = await firestore.collection('thread').add({
            'title': 'Test Thread',
            'description': 'Test Description',
            'creator': mockAuth.currentUser!.uid,
            'timestamp': Timestamp.now(),
          }).then((doc) => doc.id);

          final docId = await firestore.collection('replies').add({
            'content': 'Reply 1',
            'threadId': threadId,
            'creator': mockAuth.currentUser!.uid,
            'timestamp': Timestamp.now(),
          }).then((doc) => doc.id);

          await tester.pumpWidget(createTestWidget(ThreadReplies(
            threadId: threadId,
            firestore: firestore,
            auth: mockAuth,
          )));

          await tester.pumpAndSettle();

          // Tap on the edit button
          await tester.tap(find.byKey(Key('editButton_$docId')));
          await tester.pumpAndSettle();

          // Check if the dialog is shown
          expect(find.text('Edit your reply'), findsOneWidget);

          // Ensure the TextField is present before entering text
          expect(find.byKey(const Key('Content')), findsOneWidget);

          // Update the reply content and submit
          await tester.enterText(
              find.byKey(const Key('Content')), 'Updated Reply');
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          // Verify the reply is updated in Firestore
          final updatedReply =
              await firestore.collection('replies').doc(docId).get();
          expect(updatedReply.data()!['content'], equals('Updated Reply'));
        });

        testWidgets('Delete button removes the reply',
            (WidgetTester tester) async {
          final threadId = await firestore.collection('thread').add({
            'title': 'Test Thread',
            'description': 'Test Description',
            'creator': mockAuth.currentUser!.uid,
            'timestamp': Timestamp.now(),
          }).then((doc) => doc.id);

          final replyId = await firestore.collection('replies').add({
            'content': 'Reply 1',
            'threadId': threadId,
            'creator': mockAuth.currentUser!.uid,
            'timestamp': Timestamp.now(),
          }).then((doc) => doc.id);

          await tester.pumpWidget(createTestWidget(ThreadReplies(
            threadId: threadId,
            firestore: firestore,
            auth: mockAuth,
          )));

          await tester.pumpAndSettle();

          // Tap on the delete button
          await tester.tap(find.byIcon(FontAwesomeIcons.trash));
          await tester.pumpAndSettle();

          // Verify the reply is removed from Firestore
          final replySnapshot =
              await firestore.collection('replies').doc(replyId).get();
          expect(replySnapshot.exists, isFalse);
        });
      });
    });
  });
}

*/