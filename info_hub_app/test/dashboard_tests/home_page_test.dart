// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/view/base_view/base.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/view/message_view/patient_message_view.dart';
import 'package:info_hub_app/view/experience_view/experiences_view.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/controller/thread_controllers/name_generator_controller.dart';
import 'package:info_hub_app/view/topic_view/topic_view.dart';
import 'package:info_hub_app/view/webinar_view/webinar-screens/webinar_view.dart';

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
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage storage;
  late Widget trendingTopicWidget;
  late ThemeManager themeManager;

  setUp(() async {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    // Initialize allNouns and allAdjectives before each test
    allNouns = await loadWordSet('assets/texts/nouns.txt');
    allAdjectives = await loadWordSet('assets/texts/adjectives.txt');
    storage = MockFirebaseStorage();
    themeManager = ThemeManager();
    CollectionReference topicCollectionRef = firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'test 1',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 10,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });
    topicCollectionRef.add({
      'title': 'test 2',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 9,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });
    topicCollectionRef.add({
      'title': 'test 3',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 8,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });

    trendingTopicWidget = MaterialApp(
      home: Base(
        storage: storage,
        auth: auth,
        firestore: firestore,
        themeManager: themeManager,
        messaging: FakeFirebaseMessaging(),
        roleType: 'Patient',
      ),
    );
  });

  testWidgets('Trendings topic are in right order',
      (WidgetTester tester) async {
    // Build your widget
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });

    await tester.pumpWidget(trendingTopicWidget);
    await tester.pumpAndSettle();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));

    final textFinders = find.byType(Text);
    // Check the order of card titles
    expect((textFinders.at(1).evaluate().single.widget as Text).data, 'test 1');
    expect((textFinders.at(3).evaluate().single.widget as Text).data, 'test 2');
    expect((textFinders.at(5).evaluate().single.widget as Text).data, 'test 3');
  });

  testWidgets('Shows only first 6 trending topics',
      (WidgetTester tester) async {
    // Build your widget
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await auth.signInWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    CollectionReference topicCollectionRef = firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'test 4',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 5,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });
    topicCollectionRef.add({
      'title': 'test 5',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 4,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });
    topicCollectionRef.add({
      'title': 'test 6',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 3,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });
    topicCollectionRef.add({
      'title': 'test 7',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });

    await tester.pumpWidget(trendingTopicWidget);
    await tester.pumpAndSettle();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final textFinders = find.byType(Text);

    // Check that test 7 is ignored
    expect(
        (textFinders.at(11).evaluate().single.widget as Text).data, 'test 6');
  });

  testWidgets('Click into a topic test', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await tester.pumpWidget(trendingTopicWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();
    expect(find.byType(TopicView), findsOne);
  });

  testWidgets('Click onto inbox leads to patient message view',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'patient@gmail.com', password: 'Patient123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'patient@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });

    CollectionReference userCollectionRef = firestore.collection('Users');
    userCollectionRef.doc('1').set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });

    CollectionReference chatRoomMembersCollectionReference =
        firestore.collection('message_rooms');

    chatRoomMembersCollectionReference.add({
      'adminId': '1',
      'patientId': uid,
      'patientDisplayName': generateUniqueName(uid),
      'adminDisplayName': 'patient@gmail.com'
    });

    await tester.pumpWidget(trendingTopicWidget);
    await tester.pumpAndSettle();

    Finder inboxButton = find.byIcon(Icons.email_outlined);
    await tester.tap(inboxButton);
    await tester.pumpAndSettle();

    expect(find.byType(PatientMessageView), findsOne);
  });

  testWidgets('Click onto shared experiences leads to experience view',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await tester.pumpWidget(trendingTopicWidget);
    await tester.pumpAndSettle();

    Finder experienceViewButton = find.text('Shared Experience');
    await tester.tap(experienceViewButton);
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceView), findsOne);
  });

  testWidgets('Click onto webinar view leads to webinar view',
      (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(trendingTopicWidget);
    await tester.pumpAndSettle();

    Finder webinarViewButton = find.text('Webinars');
    await tester.tap(webinarViewButton);
    await tester.pumpAndSettle();

    expect(find.byType(WebinarView), findsOne);
  });

  testWidgets('Topics with the same tag as user role are shown',
      (WidgetTester tester) async {
    // Build your widget
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    await auth.signInWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    CollectionReference topicCollectionRef = firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'test 4',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 5,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });
    topicCollectionRef.add({
      'title': 'test 5',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 4,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Parent'],
      'categories': ['Gym']
    });
    topicCollectionRef.add({
      'title': 'test 6',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 3,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });
    topicCollectionRef.add({
      'title': 'test 7',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': ['Gym']
    });

    await tester.pumpWidget(trendingTopicWidget);
    await tester.pumpAndSettle();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(6));

    final textFinders = find.byType(Text);

    // Check that test 6 is seen but test 5 is not
    expect((textFinders.at(9).evaluate().single.widget as Text).data, 'test 6');
    expect(find.text('test 5'), findsNothing);
  });
}
