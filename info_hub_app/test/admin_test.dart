import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/analytics/topics/analytics_topic.dart';

import 'package:info_hub_app/main.dart';

import 'package:info_hub_app/message_feature/admin_message_view.dart';

import 'package:info_hub_app/experiences/admin_experience_view.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'package:info_hub_app/ask_question/question_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:info_hub_app/webinar/views/admin-webinar-screens/admin_webinar_dashboard.dart';

void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseAuth auth = MockFirebaseAuth();
  late MockFirebaseStorage mockStorage = MockFirebaseStorage();
  late Widget adminWidget;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    adminWidget = MaterialApp(
      home: AdminHomepage(
        firestore: firestore,
        auth: auth,
        storage: mockStorage,
        themeManager: themeManager,
      ),
    );
  });

  testWidgets('Add/view webinar test', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'admin@gmail.com', password: 'Admin123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin',
      'likedTopics': [],
      'dislikedTopics': [],
    });
    await tester.pumpWidget(adminWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage Webinar'));
    await tester.pumpAndSettle();
    expect(find.byType(WebinarDashboard), findsOneWidget);
  });

  testWidgets('Test create topic button', (WidgetTester tester) async {
    await tester.pumpWidget(adminWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Topic'));
    await tester.pumpAndSettle();
    expect(find.byType(TopicCreationView), findsOneWidget);
  });

  testWidgets('Test view questions button', (WidgetTester tester) async {
    await tester.pumpWidget(adminWidget);
    await tester.tap(find.text('Topic Questions'));
    await tester.pumpAndSettle();
    expect(find.byType(ViewQuestionPage), findsOneWidget);
    //test back arrow
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(AdminHomepage), findsOneWidget);
  });

  testWidgets('Test view thread button', (WidgetTester tester) async {
    await tester.pumpWidget(adminWidget);
    await tester.tap(find.text('Threads'));
    await tester.pumpAndSettle();
    //expect(find.byType(TopicCreationView), findsOneWidget);
  });

  testWidgets('Test view experiences button', (WidgetTester tester) async {
    await tester.pumpWidget(adminWidget);
    await tester.tap(find.text('Experiences'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminExperienceView), findsOneWidget);
  });

  testWidgets('Test view analytics button', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'admin@gmail.com', password: 'Admin123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });
    await tester.pumpWidget(adminWidget);
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.byType(AnalyticsTopicView), findsOneWidget);
  });

  testWidgets('Test view message feature button', (WidgetTester tester) async {
    await auth.createUserWithEmailAndPassword(
        email: 'admin@gmail.com', password: 'Admin123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@gmail.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'admin'
    });

    await tester.pumpWidget(adminWidget);
    await tester.tap(find.text('Message User'));
    await tester.pumpAndSettle();
    expect(find.byType(MessageView), findsOneWidget);
  });

  testWidgets('Add admin test', (WidgetTester tester) async {
    CollectionReference userCollectionRef = firestore.collection('Users');
    userCollectionRef.add({
      'email': 'test@nhs.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Healthcare Professional'
    });
    userCollectionRef.add({
      'email': 'test@outlook.com',
      'firstName': 'Jane',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminWidget);
    // Trigger the _showUser method
    await tester.tap(find.text('Add Admin'));
    await tester.pump();
    // Verify that the AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);
    Finder textFinder = find.text('test@nhs.com');

    //Verify that only healthcare professionals are showing
    expect(textFinder, findsOneWidget);
    expect(tester.widget<Text>(textFinder).data, 'test@nhs.com');
    //Select user
    await tester.tap(textFinder.first);
    await tester.pumpAndSettle();
    //Tap the submit button
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    QuerySnapshot data = await firestore
        .collection('Users')
        .where('roleType', isEqualTo: 'admin')
        .get();
    List<dynamic> users = List.from(data.docs);
    expect(users[0]['email'], 'test@nhs.com');
    // Verify that the dialog is closed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Add admin search test', (WidgetTester tester) async {
    CollectionReference userCollectionRef = firestore.collection('Users');
    userCollectionRef.add({
      'email': 'john@nhs.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'roleType': 'Healthcare Professional'
    });
    userCollectionRef.add({
      'email': 'jane@nhs.com',
      'firstName': 'Jane',
      'lastName': 'Doe',
      'roleType': 'Healthcare Professional'
    });
    // Build our app and trigger a frame.
    await tester.pumpWidget(adminWidget);
    await tester.pumpAndSettle();
    // Trigger the _showUser method
    await tester.tap(find.text('Add Admin'));
    await tester.pump();

    final searchTextField = find.byType(TextField);
    await tester.enterText(searchTextField, 'jo');
    await tester.pump();

    Finder textFinder = find.text('john@nhs.com');
    expect(tester.widget<Text>(textFinder).data, 'john@nhs.com');

    await tester.enterText(searchTextField, 'There is no user with this email');
    await tester.pump();
    textFinder = find.text(
        'Sorry there are no healthcare professionals matching this email.');
    expect(tester.widget<Text>(textFinder).data,
        'Sorry there are no healthcare professionals matching this email.');
  });
}
