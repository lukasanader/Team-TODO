import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/display_webinar.dart';
import '../mock.dart';


void main() {
  late UserModel testUser;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockFirebaseStorage;
  late WebinarService webinarService;
  late Widget webinarScreen;
  final MockWebViewDependencies mockWebViewDependencies = MockWebViewDependencies();
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    webinarService = WebinarService(firestore: fakeFirestore, storage: mockFirebaseStorage);

    await fakeFirestore.collection('Webinar').doc('id').set({
        'id' : 'id',
        'title' : 'Test',
        'url' :  'https://www.youtube.com/watch?v=tSXZ8hervyY',
        'thumbnail' : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYscfUBUbqwGd_DHVhG-ZjCOD7MUpxp4uhNe7toUg4ug&s',
        'webinarleadname' : 'John Doe',
        'startTime' : DateTime.now().toString(),
        'views' : 0,
        'dateStarted' : DateTime.now().toString(),
        'status' : 'Live',
        'chatenabled' : true,
    });
    await mockWebViewDependencies.init();
    
    testUser = UserModel(
      uid: 'mockUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'Healthcare Professional',
      email: 'testemail@email.com',
      likedTopics: [],
      dislikedTopics: [],
    );


    webinarScreen = MaterialApp(
      home: WebinarScreen(
        webinarID: 'id',
        youtubeURL: 'https://www.youtube.com/watch?v=tSXZ8hervyY',
        firestore: fakeFirestore,
        currentUser: testUser,
        title: 'Test',
        webinarService: webinarService,
        status: "Live",
        chatEnabled: true,
      ),
    );

  });

  testWidgets('Test Webinar Title appears', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      await tester.pumpWidget(webinarScreen);
      expect(find.text('Test'),findsOneWidget);
    });
  });

  testWidgets('Test Dialog appears successfully', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      await tester.pumpWidget(webinarScreen);
      await tester.ensureVisible(find.byIcon(Icons.help_outline));
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pump();
      expect(find.text('Webinar Guide and Expectations'), findsOneWidget);
    });
  });

  testWidgets('Test Dialog redirects back to main screen', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      await tester.pumpWidget(webinarScreen);
      await tester.ensureVisible(find.byIcon(Icons.help_outline));
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pump();
      expect(find.text('Webinar Guide and Expectations'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pump();
      expect(find.byWidget(webinarScreen), findsOneWidget);
    });

  });

  testWidgets('Test Live Viewers text appears', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      await tester.pumpWidget(webinarScreen);
      expect(find.text('1 watching'), findsOneWidget);
    });

  });
}

