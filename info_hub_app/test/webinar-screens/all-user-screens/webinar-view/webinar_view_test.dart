import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/controllers/webinar_controller.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/webinar_view.dart';
import 'package:integration_test/integration_test.dart';
import '../../mock.dart';
import 'webinar_view_helper.dart';

void main() {
  late UserModel testUser;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockFirebaseStorage;
  late MockFirebaseAuth auth;
  late WebinarController webinarController;
  late WebinarViewHelper helper;
  late Widget webinarViewScreen;
  final MockWebViewDependencies mockWebViewDependencies =
      MockWebViewDependencies();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    auth = MockFirebaseAuth(signedIn: true);
    helper = WebinarViewHelper(fakeFirestore: fakeFirestore);
    webinarController = WebinarController(
        firestore: fakeFirestore, storage: mockFirebaseStorage);
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
        auth: auth,
        firestore: fakeFirestore,
        user: testUser,
        webinarController: webinarController,
      ),
    );
  });

  testWidgets(
      'Test all widgets appear as expected when nothing is found on the database',
      (WidgetTester tester) async {
    await tester.pumpWidget(webinarViewScreen);
    expect(find.text('Webinars'), findsOneWidget);
    expect(find.text('Currently Live'), findsOneWidget);
    expect(find.text('Upcoming Webinars'), findsOneWidget);
    expect(find.text('Archived Webinars'), findsOneWidget);
    await tester.tap(find.text('Archived Webinars'));
    await tester.pumpAndSettle();
    expect(find.text('Show Live and Upcoming Webinars'), findsOneWidget);
  });

  testWidgets('Test dropdown appears with all user types to select on admin screen',(WidgetTester tester) async {
    await tester.pumpWidget(webinarViewScreen);
    expect(find.text('Patient'),findsOneWidget);
    await tester.tap(find.text('Patient'));
    await tester.pumpAndSettle();
    expect(find.text('Parent'),findsOneWidget);
    expect(find.text('Healthcare Professional'),findsOneWidget);
  });
  
  testWidgets('Test changing dropdown value to different user role changes webinars on screen',(WidgetTester tester) async {
    helper.addLiveFirestoreDocument();
    await fakeFirestore.collection('Webinar').doc('id_2').set({
      'id': 'id_2',
      'title': 'Test Title 2',
      'url': 'https://youtu.be/HZQOdtxlim4?si=nV-AXQTcplvKreyH',
      'thumbnail': 'https://picsum.photos/250?image=9',
      'webinarleadname': 'John Doe 2',
      'startTime': DateTime.now().toString(),
      'views': 5,
      'dateStarted': DateTime.now().toString(),
      'status': 'Live',
      'chatenabled': true,
      'selectedtags': ['Parent'],
    });
    await tester.pumpWidget(webinarViewScreen);
    expect(find.text('Patient'),findsOneWidget);
    await tester.tap(find.text('Patient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    expect(find.text('Test Title'),findsNothing);
    expect(find.text('Test Title 2'),findsOneWidget);
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
        'url': 'https://youtu.be/HZQOdtxlim4?si=nV-AXQTcplvKreyH',
        'thumbnail': 'https://picsum.photos/250?image=9',
        'webinarleadname': 'John Doe 2',
        'startTime': DateTime.now().toString(),
        'views': 5,
        'dateStarted': DateTime.now().toString(),
        'status': 'Live',
        'chatenabled': true,
        'selectedtags': ['Patient'],
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
        'url': 'https://youtu.be/HZQOdtxlim4?si=nV-AXQTcplvKreyH',
        'thumbnail': 'https://picsum.photos/250?image=9',
        'webinarleadname': 'John Doe 2',
        'startTime': DateTime.now().toString(),
        'views': 5,
        'dateStarted': DateTime.now().toString(),
        'status': 'Upcoming',
        'chatenabled': true,
        'selectedtags': ['Patient'],
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
        'url': 'https://youtu.be/HZQOdtxlim4?si=nV-AXQTcplvKreyH',
        'thumbnail': 'https://picsum.photos/250?image=9',
        'webinarleadname': 'John Doe 2',
        'startTime': DateTime.now().toString(),
        'views': 5,
        'dateStarted': DateTime.now().toString(),
        'status': 'Archived',
        'chatenabled': true,
        'selectedtags': ['Patient'],
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
        'url': 'https://youtu.be/HZQOdtxlim4?si=nV-AXQTcplvKreyH',
        'thumbnail': 'https://picsum.photos/250?image=9',
        'webinarleadname': 'John Doe',
        'startTime': DateTime.now().toString(),
        'views': 0,
        'dateStarted': DateTime.now().toString(),
        'status': 'Archived',
        'selectedtags': ['Patient'],
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
