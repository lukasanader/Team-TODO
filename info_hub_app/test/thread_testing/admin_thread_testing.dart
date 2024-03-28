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
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockController = MockThreadController();
    when(() => mockController.getAllThreadsStream()).thenAnswer(
      (_) => Stream.value([
        Thread(
          id: 'threadId',
          title: 'Test Thread',
          description: 'Test Description',
          creator: 'creatorId',
          timestamp: DateTime.now(),
          isEdited: false,
          roleType: 'Role',
          authorName: '',
          topicId: '',
          topicTitle: '',
        ),
      ]),
    );
    when(() => mockController.getAllRepliesStream()).thenAnswer(
      (_) => Stream.value([]), // Adjust as needed for your test scenario
    );

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
  });

  testWidgets('Confirming thread deletion calls deletion method',
      (WidgetTester tester) async {
    final mockController = MockThreadController();
    when(() => mockController.deleteThread(any())).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: ViewThreads(
        firestore: firestore,
        auth: mockAuth,
        controller: mockController, // Inject the mock controller
      ),
    ));

    // Find and tap the delete button on the first thread item
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();

    // Tap the 'Delete' button in the dialog
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    // Verify that deleteThread was called on the mock controller
    verify(() => mockController.deleteThread(any())).called(1);
  });
}
