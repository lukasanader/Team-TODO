import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/services/auth.dart';
import 'package:info_hub_app/email_verification/email_verification_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/helpers/base.dart';

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
  late FirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockFirebaseStorage mockStorage = MockFirebaseStorage();
  late Widget verificationwidget;

  setUp(() async {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    verificationwidget = MaterialApp(
      home: EmailVerificationScreen(
        firestore: firestore,
        auth: auth,
        storage: mockStorage,
        messaging: FakeFirebaseMessaging(),
        localnotificationsplugin: MockFlutterLocalNotificationsPlugin(),
      ),
    );
  });
  testWidgets('test if verification screen exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(verificationwidget);
    await tester.pumpAndSettle();
    expect(find.text('Email Verification'), findsOneWidget);
  });

  testWidgets('test if resend email button exists', (WidgetTester test) async {
    await test.pumpWidget(verificationwidget);
    await test.pumpAndSettle();
    expect(find.text('Resend Verification Email'), findsOneWidget);
  });

  testWidgets('test if I have verified email button exists',
      (WidgetTester test) async {
    await test.pumpWidget(verificationwidget);
    await test.pumpAndSettle();
    expect(find.text('I have verified my email'), findsOneWidget);
  });

  testWidgets(
      'test if email is verified when button is pressed you go to main page',
      (WidgetTester test) async {
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient',
      'emailVerified': true,
    });
    await test.pumpWidget(verificationwidget);
    await test.pumpAndSettle();
    await test.tap(find.text('I have verified my email'));
    await test.pumpAndSettle();
    expect(find.byType(Base), findsOneWidget);
  });
}
