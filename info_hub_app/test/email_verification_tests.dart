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
  final firestore = FakeFirebaseFirestore();
  final auth = MockFirebaseAuth();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      MockFlutterLocalNotificationsPlugin();
  final FirebaseMessaging firebaseMessaging = FakeFirebaseMessaging();
  final storage = MockFirebaseStorage();

  testWidgets('test if verification screen exists', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EmailVerificationScreen(
        auth: auth,
        themeManager: ThemeManager(),
        messaging: firebaseMessaging,
        localnotificationsplugin: flutterLocalNotificationsPlugin,
        firestore: firestore,
        storage: storage,
      )));
    expect(find.byType(EmailVerificationScreen), findsOneWidget);
  });
}