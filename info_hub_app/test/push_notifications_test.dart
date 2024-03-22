import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;
import 'package:info_hub_app/notifications/notifications.dart';
import 'package:info_hub_app/notifications/preferences.dart';
import 'package:info_hub_app/push_notifications/push_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'mock.dart';

const UsersCollection = 'Users';

class MockClient extends Mock implements http.Client {
  bool postCalled = false;

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    postCalled = true;
    return http.Response('Success', 200);
  }
}

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

Future<void> main() async {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Push Notifications Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late PushNotifications pushNotifications;
    late MockFlutterLocalNotificationsPlugin
        mockFlutterLocalNotificationsPlugin;
    late FakeFirebaseMessaging firebaseMessaging;
    late GlobalKey<NavigatorState> mockNavigatorKey;
    late MockClient mockClient;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
      firebaseMessaging = FakeFirebaseMessaging();
      mockNavigatorKey = navigatorKey;
      mockClient = MockClient();
      mockFlutterLocalNotificationsPlugin =
          MockFlutterLocalNotificationsPlugin();
      pushNotifications = PushNotifications(
          auth: auth,
          firestore: firestore,
          messaging: firebaseMessaging,
          nav: mockNavigatorKey,
          http: mockClient,
          localnotificationsplugin: mockFlutterLocalNotificationsPlugin);
    });

    tearDown(() async {
      firestore.clearPersistence();
    });

    testWidgets('stores token', (WidgetTester tester) async {
      firestore.collection(UsersCollection).doc(auth.currentUser!.uid).set({
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@example.org',
        'roleType': 'Patient',
        'likedTopics': [],
        'dislikedTopics': [],
      });

      await pushNotifications.storeDeviceToken();

      final querySnapshot = firestore
          .collection(UsersCollection)
          .doc(auth.currentUser!.uid)
          .collection('deviceTokens');

      expect(querySnapshot, isNotNull);
    });

    test('initialize Firebase Messaging', () async {
      await pushNotifications.init();
      final settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      expect(settings.authorizationStatus, AuthorizationStatus.authorized);
    });

    test('initialize local notifications', () async {
      await pushNotifications.localNotiInit();
      expect(mockFlutterLocalNotificationsPlugin.initializeCalled, isTrue);
    });

    testWidgets('handle tap on local notification in foreground',
        (WidgetTester tester) async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          StreamProvider<List<custom.Notification>>(
            create: (_) => DatabaseService(
                    auth: auth,
                    firestore: firestore,
                    uid: auth.currentUser!.uid)
                .notifications,
            initialData: const [],
          ),
        ],
        child: MaterialApp(
          navigatorKey: mockNavigatorKey,
          home: const Scaffold(),
          routes: {
            '/notifications': (context) => Notifications(
                  auth: auth,
                  firestore: firestore,
                ),
          },
        ),
      ));

      await tester.pumpAndSettle();

      const mockNotificationResponse = NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
      );

      PushNotifications.onNotificationTap(mockNotificationResponse);

      await tester.pumpAndSettle();

      expect(find.byType(Notifications), findsOneWidget);
    });

    test('showSimpleNotification displays notification with correct parameters',
        () async {
      const expectedTitle = 'Test Title';
      const expectedBody = 'Test Body';
      const expectedPayload = 'Test Payload';

      await pushNotifications.showSimpleNotification(
        title: expectedTitle,
        body: expectedBody,
        payload: expectedPayload,
      );

      expect(mockFlutterLocalNotificationsPlugin.showCalled, isTrue);
    });

    test('sendNotificationToDevice sends notification successfully', () async {
      const deviceToken = 'test_device_token';
      const title = 'Test Title';
      const body = 'Test Body';

      await pushNotifications.sendNotificationToDevice(
        deviceToken,
        title,
        body,
      );

      expect(mockClient.postCalled, isTrue);
    });

    test('get device token', () async {
      final deviceToken = await pushNotifications.messaging.getToken();
      expect(deviceToken, 'fakeDeviceToken');
    });

    testWidgets('handle message opened app navigation',
        (WidgetTester tester) async {
      final fakeFirebaseMessaging = FakeFirebaseMessaging();

      await tester.pumpWidget(MultiProvider(
        providers: [
          StreamProvider<List<custom.Notification>>(
            create: (_) => DatabaseService(
                    auth: auth,
                    firestore: firestore,
                    uid: auth.currentUser!.uid)
                .notifications,
            initialData: const [],
          ),
        ],
        child: MaterialApp(
          navigatorKey: mockNavigatorKey,
          home: const Scaffold(),
          routes: {
            '/notifications': (context) => Notifications(
                  auth: auth,
                  firestore: firestore,
                ),
          },
        ),
      ));

      await tester.pumpAndSettle();

      const message = RemoteMessage(
        data: {'key': 'value'},
      );
      fakeFirebaseMessaging.onMessageOpenedAppHandler = (message) {
        mockNavigatorKey.currentState!.pushNamed('/notifications');
      };
      fakeFirebaseMessaging.simulateMessageOpenedApp(message);

      await tester.pumpAndSettle();

      expect(find.byType(Notifications), findsOneWidget);
    });

    test('sendNotificationsToDevices sends notifications to all devices',
        () async {
      firestore.collection(UsersCollection).doc(auth.currentUser!.uid).set({
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@example.org',
        'roleType': 'Patient',
        'likedTopics': [],
        'dislikedTopics': [],
      });

      await pushNotifications.storeDeviceToken();
      DatabaseService databaseService = DatabaseService(
          auth: auth, firestore: firestore, uid: auth.currentUser!.uid);
      const title = 'Test Title';
      const body = 'Test Body';

      await databaseService.sendNotificationToDevices(
          title, body, mockClient, mockFlutterLocalNotificationsPlugin);

      expect(mockClient.postCalled, isTrue);
    });
  });
}
