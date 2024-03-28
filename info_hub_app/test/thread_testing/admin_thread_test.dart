import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/view/thread_view/thread_replies.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/controller/thread_controllers/thread_controller.dart';
import 'package:info_hub_app/view/thread_view/admin_view_threads.dart';

import '../test_helpers/mock.dart';

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
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  late FakeFirebaseFirestore firestore;
  late FirebaseAuth mockAuth;
  late Widget viewWidget;
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    setupFirebaseAuthMocks();
     viewWidget = MaterialApp(
      home: (ViewThreads(firestore: firestore, auth: mockAuth)),
      );
    
  

    await firestore.collection('thread').add({
      'id': 'threadId',
      'title': 'Test Thread Title',
      'description': 'Test Thread Description',
      'creator': 'creatorId',
      'timestamp': Timestamp.now(),
      'topicId': 'topicId',
      'roleType': 'RoleType',
    });
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

    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });

  testWidgets('Switching between Threads and Replies view',
      (WidgetTester tester) async {
    await tester.pumpWidget(viewWidget);

    // Verify initial state is Threads view
    expect(find.text("Threads"), findsOneWidget);
    expect(find.text("Replies"), findsOneWidget);

    // Switch to Replies view
    await tester.tap(find.text("Replies"));
    await tester.pumpAndSettle();

    expect(find.text("View Replies"), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text("Threads"));
    await tester.pumpAndSettle();

    // Verify it's back to the Threads view
    expect(find.text("View Threads"), findsOneWidget);
  });

  testWidgets('Triggering and canceling thread deletion',
      (WidgetTester tester) async {
    await tester.pumpWidget(viewWidget);

    expect(find.text("Threads"), findsOneWidget);
    expect(find.text("Replies"), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Deleting a thread dismisses the dialog and calls deleteThread',
      (WidgetTester tester) async {
    await tester.pumpWidget(viewWidget);

    await tester.pumpAndSettle();

    // Find and tap the delete icon button to open the dialog
    final deleteButton = find.byIcon(Icons.delete_outline).first;
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify the dialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    // Tap on the 'Delete' button in the dialog
    final deleteConfirmButton = find.text('Delete');
    expect(deleteConfirmButton, findsOneWidget);
    await tester.tap(deleteConfirmButton);
    await tester.pumpAndSettle();

    // Verify the dialog is dismissed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Deleting a reply dismisses the dialog and calls deleteReply',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
        createTestWidget(ViewThreads(firestore: firestore, auth: mockAuth)));

    // Wait for the mock data to load
    await tester.pumpAndSettle();
    expect(find.text("Replies"), findsOneWidget);

    // Switch to Replies view
    await tester.tap(find.text("Replies"));
    await tester.pumpAndSettle();

    // Now the app bar title should change to "View Replies"
    expect(find.text("View Replies"), findsOneWidget);
    await tester.pumpAndSettle();

    final deleteButton = find.byIcon(Icons.delete_outline).first;
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Verify the dialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    // Tap on the 'Delete' button in the dialog
    final deleteConfirmButton = find.widgetWithText(TextButton, 'Delete');
    expect(deleteConfirmButton, findsOneWidget);
    await tester.tap(deleteConfirmButton);
    await tester.pumpAndSettle();

    // Verify the dialog is dismissed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Tapping on visibility icon navigates to ThreadReplies',
      (WidgetTester tester) async {
    await tester.pumpWidget(viewWidget);

    await tester.pumpAndSettle();
    expect(find.text("Replies"), findsOneWidget);

    // Switch to Replies view
    await tester.tap(find.text("Replies"));
    await tester.pumpAndSettle();

    // Now the app bar title should change to "View Replies"
    expect(find.text("View Replies"), findsOneWidget);
    await tester.pumpAndSettle();

    final visibilityIconButtonFinder = find.byIcon(Icons.visibility).first;
    expect(visibilityIconButtonFinder, findsOneWidget);

    // Tap the visibility icon button
    await tester.tap(visibilityIconButtonFinder);

    await tester.pumpAndSettle();

    expect(find.byType(ThreadReplies), findsOneWidget);
  });
}
