/*
 * Bottom navigation bar tests (Also contains )
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/model/notification_models/notification_model.dart' as custom;
import 'package:info_hub_app/view/base_view/base.dart';
import 'package:info_hub_app/view/discovery_view/discovery_view.dart';
import 'package:info_hub_app/view/dashboard_view/home_page_view.dart';
import 'package:info_hub_app/controller/notification_controllers/notification_controller.dart';
import 'package:info_hub_app/view/notifications_view/notification_view.dart';
import 'package:info_hub_app/view/settings_view/settings_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import '../test_helpers/mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

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
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseAuth auth = MockFirebaseAuth(signedIn: true);
  late MockFirebaseStorage storage = MockFirebaseStorage();
  late ThemeManager themeManager = ThemeManager();

  setupFirebaseAuthMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Bottom Nav Bar to Home Page', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await tester.pumpWidget(MaterialApp(
        home: Base(
      storage: storage,
      auth: auth,
      firestore: firestore,
      themeManager: themeManager,
      messaging: FakeFirebaseMessaging(),
      roleType: 'Patient',
    )));

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('LiverWise'), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });
  testWidgets('Bottom Nav Bar to Search Page', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await tester.pumpWidget(MaterialApp(
        home: Base(
      storage: storage,
      auth: auth,
      firestore: firestore,
      themeManager: themeManager,
      messaging: FakeFirebaseMessaging(),
      roleType: 'Patient',
    )));

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pump();

    expect(find.byType(DiscoveryView), findsOneWidget);
  });

  testWidgets('Bottom Nav Bar to Setting Page', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await tester.pumpWidget(MaterialApp(
        home: Base(
      storage: storage,
      auth: auth,
      firestore: firestore,
      themeManager: themeManager,
      messaging: FakeFirebaseMessaging(),
      roleType: 'Patient',
    )));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();

    expect(find.byType(SettingsView), findsOneWidget);
  });

  testWidgets('HomePage UI Test', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await tester.pumpWidget(MaterialApp(
      home: HomePage(
        storage: storage,
        auth: auth,
        firestore: firestore,
      ),
    ));

    expect(find.text('LiverWise'), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('HomePage to Notification Page', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) => NotificationController(
                  auth: auth, firestore: firestore, uid: auth.currentUser!.uid)
              .notifications,
          initialData: const [], // Initial data while waiting for Firebase data
        ),
      ],
      child: MaterialApp(
        home: HomePage(
          storage: storage,
          auth: auth,
          firestore: firestore,
        ),
      ),
    ));
    await tester.tap(find.byIcon(Icons.notifications_none_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(Notifications), findsOneWidget);
  });

  testWidgets('NotificationPage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        StreamProvider<List<custom.Notification>>(
          create: (_) => NotificationController(
                  auth: auth, firestore: firestore, uid: auth.currentUser!.uid)
              .notifications,
          initialData: const [], // Initial data while waiting for Firebase data
        ),
      ],
      child: MaterialApp(
        home: Notifications(
          auth: auth,
          firestore: firestore,
        ),
      ),
    ));
    expect(find.byType(Notifications), findsOneWidget);
  });
}
