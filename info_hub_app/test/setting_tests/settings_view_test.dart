import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/view/settings_view/activity/activity_page.dart';
import 'package:info_hub_app/view/settings_view/preferences_view.dart';
import 'package:info_hub_app/view/settings_view/general_settings.dart';
import 'package:info_hub_app/view/settings_view/saved_page.dart';
import 'package:info_hub_app/view/settings_view/drafts_page.dart';
import 'package:info_hub_app/view/settings_view/privacy_base.dart';
import 'package:info_hub_app/view/settings_view/settings_view.dart';
import 'package:info_hub_app/view/settings_view/help_page_view.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import '../test_helpers/mock.dart';

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
  late Widget settingsViewWidget;
  late MockFirebaseAuth firebaseAuth;
  late MockFirebaseStorage firebaseStorage;
  late FakeFirebaseFirestore firestore;
  late ThemeManager themeManager;
  late FakeFirebaseMessaging firebaseMessaging;

  setUp(() {
    firebaseStorage = MockFirebaseStorage();
    firestore = FakeFirebaseFirestore();
    themeManager = ThemeManager();
    firebaseMessaging = FakeFirebaseMessaging();
    firestore.collection('Users').doc('adminUser').set({
      'name': 'John Doe',
      'email': 'john@example.com',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    firebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'adminUser'));

    settingsViewWidget = MaterialApp(
        home: SettingsView(
      auth: firebaseAuth,
      firestore: firestore,
      storage: firebaseStorage,
      themeManager: themeManager,
      messaging: firebaseMessaging,
    ));
  });

  testWidgets('SettingsView has appbar with back button and title "Settings"',
      (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);

    expect(find.text("Settings"), findsOneWidget);
  });

  testWidgets('SettingsView has all options', (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);

    expect(find.text("Account"), findsOneWidget);
    expect(find.text("General"), findsOneWidget);
    expect(find.text("Notifications"), findsOneWidget);
    expect(find.text("History"), findsOneWidget);
    expect(find.text("Privacy"), findsOneWidget);
    expect(find.text("Help"), findsOneWidget);
    expect(find.text("About LiverWise"), findsOneWidget);
    expect(find.text("Log Out"), findsOneWidget);
  });

  testWidgets('Test entering privacy settings works',
      (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(settingsViewWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('Privacy'));
    await tester.pumpAndSettle();

    // Verify that PrivacyPage is rendered after tapping on the ListTile.
    expect(find.byType(PrivacyPage), findsOneWidget);

    // Verify that TermsOfServicesPage renders an AppBar with the title "Terms of Services".
    expect(find.text('Privacy'), findsOneWidget);
  });

  testWidgets('Test entering manage settings works',
      (WidgetTester tester) async {
    await firebaseAuth.createUserWithEmailAndPassword(
        email: 'user@gmail.com', password: 'User123!');
    String uid = firebaseAuth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'user@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });

    CollectionReference preferenceCollection =
        firestore.collection('preferences');
    preferenceCollection.add({'push_notifications': false, 'uid': uid});

    await tester.pumpWidget(settingsViewWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();

    expect(find.byType(PreferencesPage), findsOneWidget);
  });

  testWidgets('test if logout works', (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);

    await tester.tap(find.text("Log Out"));
    await tester.pumpAndSettle();
    expect(firebaseAuth.currentUser, null);
  });

  testWidgets('Test tapping on Help navigates to HelpPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home:
            settingsViewWidget)); // Replace YourParentWidget with the widget containing the ListTile

    // Tap on the ListTile to navigate to the HelpPage
    await tester.tap(find.text("Help"));
    await tester.pumpAndSettle();

    // Verify that HelpPage is pushed onto the navigator's stack
    expect(find.byType(HelpPage), findsOneWidget);
  });

  testWidgets('Test entering general settings works',
      (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(settingsViewWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // Verify that PrivacyPage is rendered after tapping on the ListTile.
    expect(find.byType(ActivityView), findsOneWidget);

    // Verify that TermsOfServicesPage renders an AppBar with the title "Terms of Services".
    expect(find.text('History'), findsOneWidget);
  });
/*
  testWidgets('SettingsView history option goes to activity view', (WidgetTester tester) async {
    await tester.pumpWidget(settingsViewWidget);
    
    expect(find.text('History'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityView), findsOneWidget);
  });
*/

  testWidgets('Test entering account settings works',
      (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(settingsViewWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('Account'));
    await tester.pump();
  });

  testWidgets('Test entering general settings works',
      (WidgetTester tester) async {
    // Build our PrivacyPage widget and trigger a frame.
    await tester.pumpWidget(settingsViewWidget);

    // Tap on the ListTile to navigate to TermsOfServicesPage.
    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();

    // Verify that PrivacyPage is rendered after tapping on the ListTile.
    expect(find.byType(GeneralSettings), findsOneWidget);

    // Verify that TermsOfServicesPage renders an AppBar with the title "Terms of Services".
    expect(find.text('General'), findsOneWidget);
  });

  testWidgets('Test tapping on Saved topics navigates to SavedPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: settingsViewWidget));

    // Tap on the ListTile to navigate to the SavedPage
    await tester.tap(find.text('Saved Topics'));
    await tester.pumpAndSettle();

    // Verify that SavedPage is pushed onto the navigator's stack
    expect(find.byType(SavedPage), findsOneWidget);
  });

  testWidgets('Test tapping on Topic Drafts navigates to DraftsPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: settingsViewWidget));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('drafts_tile')));

    // Tap on the ListTile to navigate to the DraftsPage
    await tester.tap(find.byKey(const Key('drafts_tile')));
    await tester.pumpAndSettle();

    // Verify that DraftsPage is pushed onto the navigator's stack
    expect(find.byType(DraftsPage), findsOneWidget);
  });
}
