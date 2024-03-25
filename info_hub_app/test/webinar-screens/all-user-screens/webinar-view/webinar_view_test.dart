import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/webinar_view.dart';
import 'package:integration_test/integration_test.dart';
import '../../mock.dart';
import 'webinar_view_helper.dart';

void main() {
  late UserModel testUser;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockFirebaseStorage;
  late WebinarService webinarService;
  late WebinarViewHelper helper;
  late Widget webinarViewScreen;
  final MockWebViewDependencies mockWebViewDependencies =
      MockWebViewDependencies();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    helper = WebinarViewHelper(fakeFirestore: fakeFirestore);
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
      'Test padding is visible when two live webinars are displayed on the screen',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      await tester.pumpWidget(webinarViewScreen);
      helper.addLiveFirestoreDocument();
      await fakeFirestore.collection('Webinar').doc('id_2').set({
        'id': 'id_2',
        'title': 'Test Title 2',
        'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
        'thumbnail': 'https://picsum.photos/250?image=9',
        'webinarleadname': 'John Doe 2',
        'startTime': DateTime.now().toString(),
        'views': 5,
        'dateStarted': DateTime.now().toString(),
        'status': 'Live',
        'chatenabled': true,
        'selectedtags': ['admin'],
      });
      await tester.pumpAndSettle();
      expect(find.byType(Padding), findsWidgets);
    });
  });

  testWidgets(
      'Test padding is visible when two upcoming webinars are displayed on the screen',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      await tester.pumpWidget(webinarViewScreen);
      helper.addUpcomingFirestoreDocument();
      await fakeFirestore.collection('Webinar').doc('id_2').set({
        'id': 'id_2',
        'title': 'Test Title 2',
        'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
        'thumbnail': 'https://picsum.photos/250?image=9',
        'webinarleadname': 'John Doe 2',
        'startTime': DateTime.now().toString(),
        'views': 5,
        'dateStarted': DateTime.now().toString(),
        'status': 'Upcoming',
        'chatenabled': true,
        'selectedtags': ['admin'],
      });
      await tester.pumpAndSettle();
      expect(find.byType(Padding), findsWidgets);
    });
  });

  testWidgets(
      'Test padding is visible when two archived webinars are displayed on the screen',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      await tester.pumpWidget(webinarViewScreen);
      helper.addArchiveFirestoreDocument();
      await fakeFirestore.collection('Webinar').doc('id_2').set({
        'id': 'id_2',
        'title': 'Test Title 2',
        'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
        'thumbnail': 'https://picsum.photos/250?image=9',
        'webinarleadname': 'John Doe 2',
        'startTime': DateTime.now().toString(),
        'views': 5,
        'dateStarted': DateTime.now().toString(),
        'status': 'Archived',
        'chatenabled': true,
        'selectedtags': ['admin'],
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archived Webinars'));
      await tester.pumpAndSettle();
      expect(find.byType(Padding), findsWidgets);
    });
  });

  testWidgets(
      'Test adding a live webinar displays correctly and removes placeholder text',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      helper.addLiveFirestoreDocument();
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
      helper.addUpcomingFirestoreDocument();
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


  testWidgets('Test pressing card leads to showing webinar screen',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      helper.addLiveFirestoreDocument();
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



}
