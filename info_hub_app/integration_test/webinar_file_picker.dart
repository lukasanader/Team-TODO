import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/webinar/views/admin-webinar-screens/create_webinar_screen.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/controllers/webinar_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../test/mock_classes.dart';
import '../test/webinar-screens/mock.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late Widget createWebinarScreen;
  late UserModel testUser;
  late MockFirebaseStorage mockStorage;
  late WebinarController webinarController;
  final MockWebViewDependencies mockWebViewDependencies =
      MockWebViewDependencies();


  setUp(() async {
    await initializeDateFormatting();
    await mockWebViewDependencies.init();

    firestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();

    webinarController = WebinarController(firestore: firestore, storage: mockStorage);

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
          user: testUser, firestore: firestore, webinarController: webinarController),
    );
  });

  testWidgets(
      'Test Schedule Webinar Redirects to Valid Screen when all data is valid',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      mockFilePicker('base_image.png');
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
        of: find.text('YouTube Video URL'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(
          urlField, 'https://www.youtube.com/watch?v=tSXZ8hervgY');
      await tester.tap(find.byType(AppBar));
      await tester.pump();
      final titleField = find.ancestor(
        of: find.text('Title'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(titleField, 'test');

      await tester.tap(find.byType(AppBar));
      await tester.pump();
      await tester.ensureVisible(find.text('Patients'));
      await tester.tap(find.text('Patients'));
      await tester.pump();
      await tester.ensureVisible(find.text('Schedule Webinar'));
      await tester.tap(find.text('Schedule Webinar'));
      await tester.pump();
      await tester.tap(find.text('31'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      var centre = tester
          .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      await tester.tapAt(Offset(centre.dx - 10, centre.dy));
      await tester.pumpAndSettle();
      await tester.tapAt(Offset(centre.dx - 10, centre.dy));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final querySnapshot = await firestore
          .collection('Webinar')
          .where('status', isEqualTo: 'Upcoming')
          .get();
      expect(querySnapshot.docs.length, greaterThan(0));
    });
  });

  testWidgets('Test Admin can upload image', (WidgetTester tester) async {
    mockFilePicker('base_image.png');
    await tester.pumpWidget(createWebinarScreen);
    await tester.pumpAndSettle();

    // Interact with the widget to trigger file picker
    await tester.ensureVisible(find.text('Select a thumbnail'));
    await tester.tap(find.text('Select a thumbnail'));
    await tester.pumpAndSettle();

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

    expect(find.text('Select a thumbnail'), findsNothing);

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets(
      'Test Admin input all valid information with tags and chooses to start live webinar works',
      (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      mockFilePicker('base_image.png');
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
        of: find.text('YouTube Video URL'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(
          urlField, 'https://www.youtube.com/watch?v=tSXZ8hervgY');
      await tester.tap(find.byType(AppBar));
      await tester.pump();
      final titleField = find.ancestor(
        of: find.text('Title'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(titleField, 'test');
      await tester.tap(find.byType(AppBar));
      await tester.pump();
      await tester.ensureVisible(find.text('Patients'));
      await tester.tap(find.text('Patients'));
      await tester.pump();
      await tester.ensureVisible(find.text('Parents'));
      await tester.tap(find.text('Parents'));
      await tester.pump();
      await tester.ensureVisible(find.text('Healthcare Professionals'));
      await tester.tap(find.text('Healthcare Professionals'));
      await tester.pump();
      await tester.ensureVisible(find.text('Start Webinar'));
      await tester.tap(find.text('Start Webinar'));
      await tester.pump();
      final querySnapshot = await firestore
          .collection('Webinar')
          .where('url',
              isEqualTo: 'https://www.youtube.com/watch?v=tSXZ8hervgY')
          .get();
      expect(querySnapshot.docs.length, greaterThan(0));
    });
  });
}
