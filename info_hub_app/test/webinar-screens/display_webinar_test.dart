import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/display_webinar.dart';
import 'package:mockito/mockito.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


void main() {
  late UserModel testUser;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockFirebaseStorage;
  late WebinarService webinarService;
  late Widget webinarScreen;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    webinarService = WebinarService(firestore: fakeFirestore,storage: mockFirebaseStorage);

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
        webinarID: '123',
        youtubeURL: 'https://www.youtube.com/watch?v=tSXZ8hervyY',
        currentUser: testUser,
        title: 'Test',
        webinarService: webinarService,
        firestore: FakeFirebaseFirestore(),
      ),
    );
  });

  testWidgets('Test Title Appears in navbar', (WidgetTester tester) async {
    await tester.pumpWidget(webinarScreen);
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('Test Dialog appears successfully', (WidgetTester tester) async {
    await tester.pumpWidget(webinarScreen);
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('Webinar Guide and Expectations'), findsOneWidget);
  });

  testWidgets('Test Dialog redirects back to main screen', (WidgetTester tester) async {
    await tester.pumpWidget(webinarScreen);
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('Webinar Guide and Expectations'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byWidget(webinarScreen), findsOneWidget);
  });

  testWidgets('Test Live Viewers text appears', (WidgetTester tester) async {
    await tester.pumpWidget(webinarScreen);
    expect(find.text('1 watching'), findsOneWidget);
  });
}
