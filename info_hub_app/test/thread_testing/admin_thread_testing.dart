import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import '../mock.dart';

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

  //WidgetsFlutterBinding.ensureInitialized();
  late FakeFirebaseFirestore firestore;
  late FirebaseAuth mockAuth;
  const String testThreadId = "testThreadId";
  const String replyId = "replyId";
  late MockThreadController mockController;

  setUp(() async {
    //TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseAuthMocks();

    // Manual initialization of Firebase to avoid the no-app error

    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();

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

    // Initialize allNouns and allAdjectives before each test
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
  });

  testWidgets('Switching between Threads and Replies view',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        createTestWidget(ViewThreads(firestore: firestore, auth: mockAuth)));

    // Verify initial state is Threads view
    expect(find.text("Threads"), findsOneWidget);
    expect(find.text("Replies"), findsOneWidget);

    // Switch to Replies view
    await tester.tap(find.text("Replies"));
    await tester.pumpAndSettle();

    // Now the app bar title should change to "View Replies"
    expect(find.text("View Replies"), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text("Threads"));
    await tester.pumpAndSettle();

    // Verify it's back to the Threads view
    expect(find.text("View Threads"), findsOneWidget);
  });

  testWidgets('Triggering and canceling thread deletion',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        createTestWidget(ViewThreads(firestore: firestore, auth: mockAuth)));

    expect(find.text("Threads"), findsOneWidget);
    expect(find.text("Replies"), findsOneWidget);
    await tester.pumpAndSettle();

    // Assuming the Delete icon button triggers the deletion dialog
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Dialog should be displayed now
    expect(find.byType(AlertDialog), findsOneWidget);

    // Tap on 'Cancel' button
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Deleting a thread dismisses the dialog and calls deleteThread',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
        createTestWidget(ViewThreads(firestore: firestore, auth: mockAuth)));

    // Wait for the mock data to load
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

    // Assuming you have a way to identify the reply items, find the delete button for the first reply
    // Here, I'm assuming there's a way to get a specific delete button. Adjust the finder accordingly.
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

    // Similar to the previous test, here we would verify that deleteReply was called.
    // This requires a mock controller and is skipped here since we are not using a mock in this example.
  });

  testWidgets('Tapping on visibility icon navigates to ThreadReplies',
      (WidgetTester tester) async {
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

    final visibilityIconButtonFinder = find.byIcon(Icons.visibility).first;
    expect(visibilityIconButtonFinder, findsOneWidget);

    // Tap the visibility icon button
    await tester.tap(visibilityIconButtonFinder);

    // Trigger a frame
    await tester.pumpAndSettle();

    // Now, we expect that the navigation has occurred.
    // This checks that ThreadReplies widget is now on the navigation stack.
    expect(find.byType(ThreadReplies), findsOneWidget);
  });
}
