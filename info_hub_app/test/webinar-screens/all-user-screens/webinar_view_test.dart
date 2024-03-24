import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/webinar_view.dart';
import 'package:integration_test/integration_test.dart';
import '../mock.dart';

void main() {
  late UserModel testUser;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockFirebaseStorage;
  late WebinarService webinarService;
  late Widget webinarViewScreen;
  final MockWebViewDependencies mockWebViewDependencies =
      MockWebViewDependencies();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    webinarService =
        WebinarService(firestore: fakeFirestore, storage: mockFirebaseStorage);
    await mockWebViewDependencies.init();
    testUser = UserModel(
      uid: 'mockUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'admin',
      email: 'testemail@email.com',
      likedTopics: [],
      dislikedTopics: [],
    );

    webinarViewScreen = MaterialApp(
      home: WebinarView(
        firestore: fakeFirestore,
        user: testUser,
        webinarService: webinarService,
      ),
    );
  });

  addUpcomingFirestoreDocument() async {
    await fakeFirestore.collection('Webinar').doc('id').set({
      'id': 'id',
      'title': 'Test Title',
      'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail': 'https://picsum.photos/250?image=9',
      'webinarleadname': 'John Doe',
      'startTime': DateTime.now().toString(),
      'views': 0,
      'dateStarted': DateTime.now().toString(),
      'status': 'Upcoming',
      'chatenabled': true,
      'selectedtags': ['admin'],
    });
  }

  addLiveFirestoreDocument() async {
    await fakeFirestore.collection('Webinar').doc('id').set({
      'id': 'id',
      'title': 'Test Title',
      'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail': 'https://picsum.photos/250?image=9',
      'webinarleadname': 'John Doe',
      'startTime': DateTime.now().toString(),
      'views': 5,
      'dateStarted': DateTime.now().toString(),
      'status': 'Live',
      'chatenabled': true,
      'selectedtags': ['admin'],
    });
  }

  testWidgets(
      'Test all widgets appear as expected when nothing is found on the database',
      (WidgetTester tester) async {
    await tester.pumpWidget(webinarViewScreen);
    expect(find.text('Webinars'), findsOneWidget);
    expect(find.text('Currently Live'), findsOneWidget);
    expect(find.byKey(const Key('no_live_webinars')), findsOneWidget);
    expect(find.text('Upcoming Webinars'), findsOneWidget);
    expect(find.byKey(const Key('no_upcoming_webinars')), findsOneWidget);
    expect(find.text('Archived Webinars'), findsOneWidget);
    await tester.tap(find.text('Archived Webinars'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('no_archived_webinars')), findsOneWidget);
    expect(find.text('Show Live and Upcoming Webinars'), findsOneWidget);
  });

  testWidgets(
      'Test adding a live webinar displays correctly and removes placeholder text',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addLiveFirestoreDocument();
      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      expect(find.text('Webinars'), findsOneWidget);
      expect(find.text('Test Title'), findsOne);
      expect(find.text('John Doe'), findsOne);
      expect(find.text('5 watching'), findsOne);
      expect(
          find.text(
              'None of our trusted NHS doctors are live right now \nPlease check later!'),
          findsNothing);
    });
  });

  testWidgets(
      'Test adding an upcoming webinar displays correctly and removes placeholder text',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addUpcomingFirestoreDocument();
      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      expect(find.text('Webinars'), findsOneWidget);
      expect(find.text('Test Title'), findsOne);
      expect(find.text('John Doe'), findsOne);
      expect(find.text('0 watching'), findsOne);
      expect(
          find.text(
              'Seems like all of our trusted doctors are busy \nCheck regularly to see if there have been any changes'),
          findsNothing);
    });
  });

  testWidgets(
      'Test adding an archived webinar displays correctly and removes placeholder text',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      await fakeFirestore.collection('Webinar').doc('id').set({
        'id': 'id',
        'title': 'Test Title',
        'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
        'thumbnail': 'https://picsum.photos/250?image=9',
        'webinarleadname': 'John Doe',
        'startTime': DateTime.now().toString(),
        'views': 0,
        'dateStarted': DateTime.now().toString(),
        'status': 'Archived',
        'selectedtags': ['admin'],
      });
      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archived Webinars'));
      await tester.pumpAndSettle();
      expect(find.text('Webinars'), findsOneWidget);
      expect(find.text('Test Title'), findsOne);
      expect(find.text('John Doe'), findsOne);
      expect(find.text('0 watching'), findsOne);
      expect(
          find.text('Check back here to see any webinars you may have missed!'),
          findsNothing);
    });
  });

  testWidgets(
      'Test pressing upcoming webinar should prompt dialog about when it will be available',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addUpcomingFirestoreDocument();
      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Title'));
      await tester.pumpAndSettle();
      expect(find.text('Webinar Not Available Yet'), findsOneWidget);
      expect(
          find.text(
              'Please come back at the scheduled time to join the webinar.'),
          findsOneWidget);
    });
  });

  testWidgets(
      'Test pressing button on upcoming webinar dialog should remove dialog from screen',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addUpcomingFirestoreDocument();
      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Title'));
      await tester.pumpAndSettle();
      expect(find.text('Webinar Not Available Yet'), findsOneWidget);
      expect(
          find.text(
              'Please come back at the scheduled time to join the webinar.'),
          findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Webinar Not Available Yet'), findsNothing);
      expect(
          find.text(
              'Please come back at the scheduled time to join the webinar.'),
          findsNothing);
    });
  });

  testWidgets('Test Admin can change webinar from upcoming to live',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addUpcomingFirestoreDocument();

      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Move to Live'), findsOneWidget);

      await tester.tap(find.text('Move to Live'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to move this webinar to live?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      DocumentSnapshot result =
          await fakeFirestore.collection('Webinar').doc('id').get();
      Map<String, dynamic>? data = result.data() as Map<String, dynamic>?;
      String? status = data?['status'];

      expect(status, equals('Live'));
    });
  });

  testWidgets('Test Admin can cancel change webinar from upcoming to live',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addUpcomingFirestoreDocument();

      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton));

      await tester.pumpAndSettle();
      expect(find.text('Move to Live'), findsOneWidget);

      await tester.tap(find.text('Move to Live'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to move this webinar to live?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure you want to move this webinar to live?'),
          findsNothing);

      DocumentSnapshot result =
          await fakeFirestore.collection('Webinar').doc('id').get();
      Map<String, dynamic>? data = result.data() as Map<String, dynamic>?;
      String? status = data?['status'];

      expect(status, equals('Upcoming'));
    });
  });

  testWidgets('Test Admin can change webinar from live to archive',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addLiveFirestoreDocument();

      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Move to Archive'), findsOneWidget);

      await tester.tap(find.text('Move to Archive'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Are you sure you want to move this webinar to the archive?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      final urlField = find.ancestor(
        of: find.text('Enter new YouTube video URL'),
        matching: find.byType(TextField),
      );
      await tester.enterText(
          urlField, "https://www.youtube.com/watch?v=tSXZ8hervgY");
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Are you sure you want to move this webinar to the archive?'),
          findsNothing);

      DocumentSnapshot result =
          await fakeFirestore.collection('Webinar').doc('id').get();
      Map<String, dynamic>? data = result.data() as Map<String, dynamic>?;
      String? status = data?['status'];
      bool? chatEnabled = data?['chatenabled'];

      expect(status, equals('Archived'));
      expect(chatEnabled, equals(false));
    });
  });

  testWidgets(
      'Test Admin can not change webinar from live to archive using no link or invalid link',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addLiveFirestoreDocument();

      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Move to Archive'), findsOneWidget);

      await tester.tap(find.text('Move to Archive'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Are you sure you want to move this webinar to the archive?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      final urlField = find.ancestor(
        of: find.text('Enter new YouTube video URL'),
        matching: find.byType(TextField),
      );

      await tester.tap(find.text('Confirm'));
      await tester.enterText(urlField, "invalidtext");
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid URL format'), findsOneWidget);

      await tester.enterText(urlField, " ");
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid URL format'), findsOneWidget);

      await tester.enterText(urlField, "https://google.com");
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid URL format'), findsOneWidget);
    });
  });

  testWidgets(
      'Test Admin can not change webinar from live to archive using no link or invalid link',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addLiveFirestoreDocument();

      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Move to Archive'), findsOneWidget);

      await tester.tap(find.text('Move to Archive'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Are you sure you want to move this webinar to the archive?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Are you sure you want to move this webinar to the archive?'),
          findsNothing);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Confirm'), findsNothing);
    });
  });

  testWidgets('Test pressing card leads to showing webinar screen',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addLiveFirestoreDocument();
      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Title'));
      await tester.pump();

      DocumentSnapshot result =
          await fakeFirestore.collection('Webinar').doc('id').get();
      Map<String, dynamic>? data = result.data() as Map<String, dynamic>?;
      int? status = data?['views'];

      expect(status, greaterThan(5));
    });
  });

  testWidgets('Test Admin can delete webinar', (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      addLiveFirestoreDocument();
      await fakeFirestore
          .collection('Webinar')
          .doc('id')
          .collection('comments')
          .doc('hahah')
          .set({
        'message': 'test',
        'createdAt': DateTime.now(),
        'commentID': 'hahah',
        'roleType': 'admin',
        'uid': 'randomuid',
      });

      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Delete Webinar'), findsOneWidget);

      await tester.tap(find.text('Delete Webinar'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to delete this webinar?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to delete this webinar?'),
          findsNothing);
      DocumentSnapshot chatResult = await fakeFirestore
          .collection('Webinar')
          .doc('id')
          .collection('comments')
          .doc('1')
          .get();
      expect(chatResult.exists, equals(false));
      DocumentSnapshot result =
          await fakeFirestore.collection('Webinar').doc('id').get();
      expect(result.exists, equals(false));
    });
  });

  testWidgets('Test Admin can cancel delete webinar operation',
      (WidgetTester tester) async {
    addLiveFirestoreDocument();

    await tester.pumpWidget(webinarViewScreen);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text('Delete Webinar'), findsOneWidget);

    await tester.tap(find.text('Delete Webinar'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to delete this webinar?'),
        findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to delete this webinar?'),
        findsNothing);
    DocumentSnapshot result =
        await fakeFirestore.collection('Webinar').doc('id').get();
    expect(result.exists, equals(true));
  });
}
