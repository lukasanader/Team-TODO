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
  late WebinarController webinarController;
  late WebinarViewHelper helper;
  late MockFirebaseAuth auth;
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
        firestore: fakeFirestore, storage: mockFirebaseStorage, auth: auth);
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
      'Test pressing upcoming webinar should prompt dialog about when it will be available',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      helper.addUpcomingFirestoreDocument();
      await tester.pumpWidget(webinarViewScreen);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Test Title'));
      await tester.tap(find.text('Test Title'));
      await tester.pumpAndSettle();
      expect(find.text('Webinar Not Available Yet'), findsOneWidget);
      expect(
          find.text(
              'Please come back at the scheduled time to join the webinar.'),
          findsOneWidget);
    });
  });

  testWidgets('Test Admin can delete webinar', (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      helper.addLiveFirestoreDocument();
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
      DocumentSnapshot result =
          await fakeFirestore.collection('Webinar').doc('id').get();
      expect(result.exists, equals(false));
      QuerySnapshot chatResult = await fakeFirestore
          .collection('Webinar')
          .doc('id')
          .collection('comments')
          .get();
      expect(chatResult.docs.length, equals(0));
    });
  });

  testWidgets(
      'Test pressing button on upcoming webinar dialog should remove dialog from screen',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      helper.addUpcomingFirestoreDocument();
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

  testWidgets(
      'Test Admin can not change webinar from live to archive using no link or invalid link',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      helper.addLiveFirestoreDocument();

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

  testWidgets('Test Admin can cancel delete webinar operation',
      (WidgetTester tester) async {
    helper.addLiveFirestoreDocument();

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

  testWidgets('Test Admin can change webinar from upcoming to live',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      helper.addUpcomingFirestoreDocument();

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
      helper.addUpcomingFirestoreDocument();

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
      helper.addLiveFirestoreDocument();

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
          urlField, "https://youtu.be/HZQOdtxlim4?si=nV-AXQTcplvKreyH");
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
      helper.addLiveFirestoreDocument();
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
      helper.addLiveFirestoreDocument();
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

  testWidgets('Test Admin can delete webinar', (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      helper.addLiveFirestoreDocument();
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
      DocumentSnapshot result =
          await fakeFirestore.collection('Webinar').doc('id').get();
      expect(result.exists, equals(false));
      QuerySnapshot chatResult = await fakeFirestore
          .collection('Webinar')
          .doc('id')
          .collection('comments')
          .get();
      expect(chatResult.docs.length, equals(0));
    });
  });

  testWidgets('Test Admin can cancel delete webinar operation',
      (WidgetTester tester) async {
    helper.addLiveFirestoreDocument();

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
