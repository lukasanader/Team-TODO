import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:info_hub_app/view/base_view/base.dart';
import 'package:info_hub_app/view/dashboard_view/home_page_view.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/model/notification_models/notification_model.dart' as custom;
import 'package:info_hub_app/controller/notification_controllers/notification_controller.dart';
import 'package:info_hub_app/view/notifications_view/notification_view.dart';
import 'package:info_hub_app/controller/notification_controllers/push_notifications_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../test_helpers/fake_firebase_messaging.dart';
import '../test_helpers/mock.dart';

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

Future<void> main() async {
  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Push Notifications Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late PushNotifications pushNotifications;
    late MockFirebaseStorage storage;
    late MockFlutterLocalNotificationsPlugin
        mockFlutterLocalNotificationsPlugin;
    late FakeFirebaseMessaging firebaseMessaging;
    late GlobalKey<NavigatorState> mockNavigatorKey;
    late MockClient mockClient;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(signedIn: true);
      firebaseMessaging = FakeFirebaseMessaging();
      storage = MockFirebaseStorage();
      mockNavigatorKey = navigatorKey;
      mockClient = MockClient();
      mockFlutterLocalNotificationsPlugin =
          MockFlutterLocalNotificationsPlugin();
      pushNotifications = PushNotifications(
          auth: auth,
          firestore: firestore,
          messaging: firebaseMessaging,
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
      Future<String> checkUser() async {
        if (auth.currentUser != null) {
          DocumentSnapshot snapshot = await firestore
              .collection('Users')
              .doc(auth.currentUser!.uid)
              .get();
          Map<String, dynamic> userData =
              snapshot.data() as Map<String, dynamic>;
          if (userData['roleType'] == 'admin') {
            return 'admin';
          } else {
            return 'user';
          }
        } else {
          return 'guest';
        }
      }

      firestore.collection(UsersCollection).doc(auth.currentUser!.uid).set({
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@example.org',
        'roleType': 'Patient',
        'likedTopics': [],
        'dislikedTopics': [],
      });
      await tester.pumpWidget(MultiProvider(
        providers: [
          StreamProvider<List<custom.Notification>>(
            create: (_) => NotificationController(
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
            '/home': (context) => HomePage(
                  auth: auth,
                  firestore: firestore,
                  storage: storage,
                ),
            '/base': (context) => FutureBuilder<Base>(
                  future: checkUser().then((roleType) => Base(
                        auth: auth,
                        firestore: firestore,
                        storage: storage,
                        themeManager: themeManager,
                        messaging: firebaseMessaging,
                        roleType: roleType,
                      )),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      return snapshot.data!;
                    }
                  },
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
            create: (_) => NotificationController(
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
            '/home': (context) => HomePage(
                  auth: auth,
                  firestore: firestore,
                  storage: storage,
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
      NotificationController notificationService = NotificationController(
          auth: auth, firestore: firestore, uid: auth.currentUser!.uid);
      const title = 'Test Title';
      const body = 'Test Body';

      await notificationService.sendNotificationToDevices(
          title, body, mockClient, mockFlutterLocalNotificationsPlugin);

      expect(mockClient.postCalled, isTrue);
    });
  });
}
