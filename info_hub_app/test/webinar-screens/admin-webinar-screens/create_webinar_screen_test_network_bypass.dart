import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/webinar/views/admin-webinar-screens/create_webinar_screen.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../mock.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late Widget createWebinarScreen;
  late UserModel testUser;
  late MockFirebaseStorage mockStorage;
  late WebinarService webinarService;
  final MockWebViewDependencies mockWebViewDependencies =
      MockWebViewDependencies();

  setUp(() async {
    await initializeDateFormatting();
    await mockWebViewDependencies.init();

    firestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();

    webinarService = WebinarService(firestore: firestore, storage: mockStorage);

    testUser = UserModel(
      uid: 'mockUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'Healthcare Professional',
      email: 'testemail@email.com',
      likedTopics: [],
      dislikedTopics: [],
    );

    createWebinarScreen = MaterialApp(
      home: CreateWebinarScreen(
          user: testUser, firestore: firestore, webinarService: webinarService),
    );
  });

  // This test has to be in a seperate file to the rest in order to pass, or else it will cause conflicts with the other tests
  testWidgets(
      'Test Admin attempts to input the same URL as an already existing record',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      await firestore.collection('Webinar').doc('id').set({
        'id': 'id',
        'title': 'Test',
        'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
        'thumbnail': "doesntmatter",
        'webinarleadname': 'John Doe',
        'startTime': DateTime.now().toString(),
        'views': 0,
        'dateStarted': DateTime.now().toString(),
        'status': 'Live',
      });

      await tester.pumpWidget(createWebinarScreen);

      // Interact with the widget to trigger file picker
      await tester.ensureVisible(find.text('Select a thumbnail'));
      await tester.tap(find.text('Select a thumbnail'));
      await tester.pump();

      bool dialogDismissed = false;
      final startTime = DateTime.now();
      while (!dialogDismissed) {
        await tester.pump();

        if (find.text('Select a thumbnail').evaluate().isEmpty) {
          dialogDismissed = true;
          break;
        }

        if (DateTime.now().difference(startTime).inSeconds > 30) {
          fail('Timed out waiting for the file picker dialog to disappear');
        }
      }

      await tester.ensureVisible(find.text('Start Webinar'));
      final urlField = find.ancestor(
        of: find.text('Enter your YouTube video URL here'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(
          urlField, 'https://www.youtube.com/watch?v=tSXZ8hervgY');
      await tester.pump();
      final titleField = find.ancestor(
        of: find.text('Enter your title'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(titleField, 'test');
      await tester.pump();
      await tester.tap(find.text('Start Webinar'));
      await tester.pump();

      expect(
          find.text(
              'A webinar with this URL may already exist. Please try again.'),
          findsOneWidget);
    });
  });
}
