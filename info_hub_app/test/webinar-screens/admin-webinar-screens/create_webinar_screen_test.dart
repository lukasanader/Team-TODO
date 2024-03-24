import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/webinar/views/admin-webinar-screens/create_webinar_screen.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../mock.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late Widget createWebinarScreen;
  late UserModel testUser;
  late MockFirebaseStorage mockStorage;
  late WebinarService webinarService;
  final MockWebViewDependencies mockWebViewDependencies =
      MockWebViewDependencies();
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  mockFilePicker() {
    const MethodChannel channelFilePicker =
        MethodChannel('miguelruivo.flutter.plugins.filepicker');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channelFilePicker,
            (MethodCall methodCall) async {
      final ByteData data = await rootBundle.load('/assets/base_image.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final File file = await File(
        '${tempDir.path}/base_image.png',
      ).writeAsBytes(bytes);
      return [
        {
          'name': "base_image.png",
          'path': file.path,
          'bytes': bytes,
          'size': bytes.lengthInBytes,
        }
      ];
    });
  }

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

  testWidgets('Test all widgets are present', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    expect(find.text('Select a thumbnail'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Schedule Webinar'), findsOneWidget);    
    expect(find.text('Start Webinar'), findsOneWidget);
    expect(find.text('Patients'),findsOneWidget);
    expect(find.text('Parents'),findsOneWidget);
    expect(find.text('Healthcare Professionals'),findsOneWidget);
  });

  testWidgets('Test Admin requires input to proceed', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.ensureVisible(find.text('Start Webinar'));
    await tester.tap(find.text('Start Webinar'));
    await tester.pumpAndSettle();
    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('URL is required'), findsOneWidget);
  });

  testWidgets('Test Admin can not enter random text into YouTube url', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.ensureVisible(find.text('Start Webinar'));
    final urlField = find.ancestor(
      of: find.text('YouTube Video URL'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(urlField, 'randomtext');
    await tester.tap(find.text('Start Webinar'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid YouTube video URL'), findsOneWidget);
  });

  testWidgets('Test Help Guide Dialog appears when help icon is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.ensureVisible(find.byIcon(Icons.help_outline));
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('How to Start a Livestream on YouTube'), findsOneWidget);
    expect(find.text('Sign in to your YouTube account on a web browser.'),
        findsOneWidget);
  });

  testWidgets('Test Help Guide Dialog redirects back to create webinar screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.ensureVisible(find.byIcon(Icons.help_outline));
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('How to Start a Livestream on YouTube'), findsOneWidget);
    expect(find.text('Sign in to your YouTube account on a web browser.'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byWidget(createWebinarScreen), findsOneWidget);
  });

  testWidgets('Test Valid YouTube URL is accepted', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.ensureVisible(find.text('Start Webinar'));
    final urlField = find.ancestor(
      of: find.text('YouTube Video URL'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(urlField, 'https://www.youtube.com/watch?v=tSXZ8hervyY');
    await tester.tap(find.text('Start Webinar'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid YouTube video URL'), findsNothing);
  });

  testWidgets('Test select scheduled date appears', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.ensureVisible(find.text('Schedule Webinar'));
    final titleField = find.ancestor(
      of: find.text('Title'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(titleField, 'test');
    final urlField = find.ancestor(
      of: find.text('YouTube Video URL'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(urlField, 'https://www.youtube.com/watch?v=tSXZ8hervyY');
    await tester.tap(find.text('Schedule Webinar'));
    await tester.pumpAndSettle();
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('Test admin can not schedule without image or tag', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.ensureVisible(find.text('Schedule Webinar'));
    await tester.tap(find.text('Schedule Webinar'));
    await tester.pump();
    expect(find.text('Please check if you have uploaded a thumbnail or selected a role.'),findsOneWidget);
  });

  testWidgets('Test admin can select date and time', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.ensureVisible(find.text('Schedule Webinar'));
    final titleField = find.ancestor(
      of: find.text('Title'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(titleField, 'test');
    final urlField = find.ancestor(
      of: find.text('YouTube Video URL'),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(urlField, 'https://www.youtube.com/watch?v=tSXZ8hervyY');
    await tester.tap(find.text('Schedule Webinar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('31'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    var centre = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(centre.dx - 10, centre.dy));
    await tester.pumpAndSettle();
    await tester.tapAt(Offset(centre.dx - 10, centre.dy));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('Test Schedule Webinar Redirects to Valid Screen when all data is valid', (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      mockFilePicker();
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
      await tester.enterText(urlField, 'https://www.youtube.com/watch?v=tSXZ8hervgY');
      await tester.pump();
      final titleField = find.ancestor(
        of: find.text('Title'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(titleField, 'test');
      await tester.pump();
      await tester.tap(find.text('Patients'));
      await tester.pump();
      await tester.tap(find.text('Schedule Webinar'));
      await tester.pump();
      await tester.tap(find.text('31'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      var centre = tester.getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
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
    mockFilePicker();
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

    testWidgets('Test Admin not uploading image or selecting tag leads to error prompt', (WidgetTester tester) async {
    await tester.pumpWidget(createWebinarScreen);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Webinar'));
    await tester.pump();
    expect(find.text('Please check if you have uploaded a thumbnail or selected a role.'),findsOneWidget);
  });


  testWidgets('Test Admin input all valid information with tags and chooses to start live webinar works', (WidgetTester tester) async {
    await provideMockedNetworkImages(() async {
      mockFilePicker();
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
      await tester.enterText(urlField, 'https://www.youtube.com/watch?v=tSXZ8hervgY');
      await tester.pump();
      final titleField = find.ancestor(
        of: find.text('Title'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(titleField, 'test');
      await tester.pump();
      await tester.tap(find.text('Patients'));
      await tester.pump();
      await tester.tap(find.text('Parents'));
      await tester.pump();
      await tester.tap(find.text('Healthcare Professionals'));
      await tester.pump();
      await tester.tap(find.text('Start Webinar'));
      await tester.pump();
      final querySnapshot = await firestore
          .collection('Webinar')
          .where('url', isEqualTo: 'https://www.youtube.com/watch?v=tSXZ8hervgY')
          .get();
      expect(querySnapshot.docs.length, greaterThan(0));
    });
  });


}
