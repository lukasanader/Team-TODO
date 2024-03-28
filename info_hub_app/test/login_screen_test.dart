import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:info_hub_app/login/login_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/reset_password/reset_password_view.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

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
  final storage = MockFirebaseStorage();
  final firebaseMessaging = FakeFirebaseMessaging();
  final mockFlutterLocalNotificationsPlugin =
      MockFlutterLocalNotificationsPlugin();
  testWidgets('test if login text exists', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    expect(find.text('Please fill in the login details.'), findsOneWidget);
  });

  testWidgets('test if email textfield exists', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test');
    expect(find.text('test'), findsOneWidget);
  });
  testWidgets('test if password textfield exists', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(passwordField, 'test');
    expect(find.text('test'), findsOneWidget);
  });

  testWidgets('test if log in validation works', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test');
    await test.enterText(passwordField, 'test');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.text('Email or password is incorrect. Please try again'),
        findsNothing);
  });

  testWidgets('test if log in works on a valid user',
      (WidgetTester test) async {
    await auth.createUserWithEmailAndPassword(
        email: 'gamer@gmail.com', password: 'G@mer123');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'gamer@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'gamer@gmail.com');
    await test.enterText(passwordField, 'G@mer123');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('test if log in works on a valid admin',
      (WidgetTester test) async {
    await auth.createUserWithEmailAndPassword(
        email: 'admin@gmail.com', password: 'Admin123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'admin@gmail.com');
    await test.enterText(passwordField, 'Admin123!');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.byType(AdminHomepage), findsOneWidget);
  });

  testWidgets('test if stops when email is empty', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(passwordField, 'test');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);
  });

  testWidgets('test if stops when password is empty',
      (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('test if stops when both are empty', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('test if user forgets password', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    await test.pumpAndSettle();

    await test.tap(find.text('Forgot Password?'));
    await test.pumpAndSettle();

    expect(find.byType(ResetPassword), findsOne);
  });

  testWidgets('test if show/hide password switches between both options',
      (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    await test.pumpAndSettle();

    final showHideButton = find.byIcon(Icons.visibility);
    await test.tap(showHideButton);
    await test.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('test if show/hide password works', (WidgetTester test) async {
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    await test.pumpAndSettle();

    final showHideButton = find.byIcon(Icons.visibility);

    final passwordfield = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );

    await test.enterText(passwordfield, 'test');
    await test.tap(showHideButton);
    await test.pumpAndSettle();
    expect(find.text('test'), findsOneWidget);
  });

  testWidgets('test logging in with a patient works',
      (WidgetTester test) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested@example.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient',
    });
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test@tested.org');
    await test.enterText(passwordField, 'Password123!');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('test logging in with a parent works', (WidgetTester test) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Parent',
    });
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test@tested.org');
    await test.enterText(passwordField, 'Password123!');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('test logging in with a healthcare professional works',
      (WidgetTester test) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Healthcare Professional',
    });
    await test.pumpWidget(MaterialApp(
        home: LoginScreen(
            firestore: firestore,
            auth: auth,
            storage: storage,
            messaging: firebaseMessaging,
            localnotificationsplugin: mockFlutterLocalNotificationsPlugin,
            themeManager: ThemeManager())));
    final emailField = find.ancestor(
      of: find.text('Email'),
      matching: find.byType(TextFormField),
    );
    final passwordField = find.ancestor(
      of: find.text('Password'),
      matching: find.byType(TextFormField),
    );
    await test.enterText(emailField, 'test@tested.org');
    await test.enterText(passwordField, 'Password123!');
    final loginButton = find.text('Login');
    await test.tap(loginButton);
    await test.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });
}
