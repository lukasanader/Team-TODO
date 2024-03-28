import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/view/discovery_view/admin_dash_view.dart';
import 'package:info_hub_app/view/dashboard_view/home_page_view.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/view/registration_view/start_page.dart';
import 'package:info_hub_app/view/registration_view/registration_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import '../test_helpers/mock.dart';

class MockFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  bool initializeCalled = false;

  @override
  Future<bool?> initialize(InitializationSettings initializationSettings,
      {onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse}) async {
    initializeCalled = true;
    return initializeCalled;
  }

  bool showCalled = false;

  @override
  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    showCalled = true;
  }
}

class FakeFirebaseMessaging extends Fake implements FirebaseMessaging {
  Function(RemoteMessage)? onMessageOpenedAppHandler;

  void simulateMessageOpenedApp(RemoteMessage message) {
    if (onMessageOpenedAppHandler != null) {
      onMessageOpenedAppHandler!(message);
    }
  }

  @override
  Future<String?> getToken({String? vapidKey}) async {
    return 'fakeDeviceToken';
  }

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = false,
    bool announcement = false,
    bool badge = false,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = false,
  }) async {
    return const NotificationSettings(
      authorizationStatus: AuthorizationStatus.authorized,
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.enabled,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.enabled,
      criticalAlert: AppleNotificationSetting.enabled,
      sound: AppleNotificationSetting.enabled,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.enabled,
    );
  }
}

void main() {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  final themeManager = ThemeManager();

  testWidgets('Test start page is loaded', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    final storage = MockFirebaseStorage();
    await tester.pumpWidget(MaterialApp(
        home: MyApp(
      firestore: firestore,
      auth: MockFirebaseAuth(signedIn: false),
      storage: storage,
    )));
    await tester.pumpAndSettle();
    expect(find.byType(StartPage), findsOneWidget);
  });

  testWidgets('Test homepage is loaded when patient is logged in',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    firestore.collection('Users').doc('patientUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'Patient',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    final storage = MockFirebaseStorage();
    await tester.pumpWidget(MaterialApp(
        home: MyApp(
      firestore: firestore,
      auth: MockFirebaseAuth(
          signedIn: true, mockUser: MockUser(uid: 'patientUser')),
      storage: storage,
    )));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Test adminHomepage is loaded when admin is logged in',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    final storage = MockFirebaseStorage();
    await tester.pumpWidget(MaterialApp(
        home: MyApp(
      firestore: firestore,
      auth: MockFirebaseAuth(
          signedIn: true, mockUser: MockUser(uid: 'adminUser')),
      storage: storage,
    )));
    await tester.pumpAndSettle();
    expect(find.byType(AdminHomepage), findsOneWidget);
  });
  testWidgets('Register button is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    final firebaseMessaging = FakeFirebaseMessaging();
    final mockFlutterLocalNotificationsPlugin =
        MockFlutterLocalNotificationsPlugin();
    await tester.pumpWidget(MaterialApp(
        home: StartPage(
      firestore: firestore,
      auth: auth,
      storage: storage,
      messaging: firebaseMessaging,
      localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
      themeManager: themeManager,
    )));
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Login button is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    final firebaseMessaging = FakeFirebaseMessaging();
    final mockFlutterLocalNotificationsPlugin =
        MockFlutterLocalNotificationsPlugin();
    await tester.pumpWidget(MaterialApp(
        home: StartPage(
      firestore: firestore,
      auth: auth,
      storage: storage,
      messaging: firebaseMessaging,
      localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
      themeManager: themeManager,
    )));
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Image is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    final firebaseMessaging = FakeFirebaseMessaging();
    final mockFlutterLocalNotificationsPlugin =
        MockFlutterLocalNotificationsPlugin();
    await tester.pumpWidget(MaterialApp(
        home: StartPage(
      firestore: firestore,
      auth: auth,
      storage: storage,
      messaging: firebaseMessaging,
      localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
      themeManager: themeManager,
    )));
    expect(
        find.image(const AssetImage('assets/base_image.png')), findsOneWidget);
  });

  testWidgets('Team text is present', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    final firebaseMessaging = FakeFirebaseMessaging();
    final mockFlutterLocalNotificationsPlugin =
        MockFlutterLocalNotificationsPlugin();
    await tester.pumpWidget(MaterialApp(
        home: StartPage(
      firestore: firestore,
      auth: auth,
      storage: storage,
      messaging: firebaseMessaging,
      localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
      themeManager: themeManager,
    )));
    expect(find.text('Team TODO'), findsOneWidget);
  });

  testWidgets('Register button press leads to register screen',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    final firebaseMessaging = FakeFirebaseMessaging();
    final mockFlutterLocalNotificationsPlugin =
        MockFlutterLocalNotificationsPlugin();
    await tester.pumpWidget(
      MaterialApp(
        home: StartPage(
          firestore: firestore,
          auth: auth,
          storage: storage,
          messaging: firebaseMessaging,
          localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
          themeManager: themeManager,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Register'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.byType(RegistrationScreen), findsOneWidget);
  });

  testWidgets('Login button press leads to login screen',
      (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final storage = MockFirebaseStorage();
    final firebaseMessaging = FakeFirebaseMessaging();
    final mockFlutterLocalNotificationsPlugin =
        MockFlutterLocalNotificationsPlugin();

    await tester.pumpWidget(
      MaterialApp(
        home: StartPage(
          firestore: firestore,
          auth: auth,
          storage: storage,
          messaging: firebaseMessaging,
          localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
          themeManager: themeManager,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    //expect(find.byType(LoginScreen), findsOneWidget);
  });
}
