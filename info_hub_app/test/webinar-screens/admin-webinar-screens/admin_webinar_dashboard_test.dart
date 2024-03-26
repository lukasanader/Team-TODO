import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/webinar/views/admin-webinar-screens/admin_webinar_dashboard.dart';
import 'package:info_hub_app/webinar/views/admin-webinar-screens/create_webinar_screen.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/controllers/webinar_controller.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/webinar_view.dart';


void main() {
  late FakeFirebaseFirestore mockFirestore;
  late UserModel testUser;
  late MockFirebaseStorage mockStorage;
  late Widget webinarDashboardWidget;

  setUp(() {
    mockFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    WebinarController webService = WebinarController(
      firestore: mockFirestore,
      storage: mockStorage);
    testUser = UserModel(
      uid: 'testUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'admin',
      email: 'john.doe@nhs.co.uk',
      likedTopics: [],
      dislikedTopics: [],
    );

    webinarDashboardWidget = MaterialApp(
      home: WebinarDashboard(
        firestore: mockFirestore,
        user: testUser,
        webinarController: webService, // Pass the mock service to the widget
      ),
    );

  });


  testWidgets('Test all widgets appear as expected', (WidgetTester tester) async {
    await tester.pumpWidget(webinarDashboardWidget);
    expect(find.text('Webinar Dashboard'), findsOne);
    expect(find.text('Webinar Analytics'), findsOne);
    expect(find.text('Live Webinars'), findsOne);
    expect(find.text('Upcoming Webinars'), findsOne);
    expect(find.text('Live Viewers'), findsOne);
    expect(find.text('Archived Webinars'), findsOne);
    expect(find.text('View Webinars'), findsOne);
    expect(find.text('Create Webinars'), findsOne);
  });

  testWidgets('Test pressing View Webinars button redirects to view webinar screen', (WidgetTester tester) async {
    await tester.pumpWidget(webinarDashboardWidget);
    await tester.ensureVisible(find.text('View Webinars'));

    await tester.tap(find.text('View Webinars'));
    await tester.pumpAndSettle();

    expect(find.byType(WebinarView), findsOne);
  });


  testWidgets('Test pressing Create Webinar button redirects to create webinar screen', (WidgetTester tester) async {
    await tester.pumpWidget(webinarDashboardWidget);
    await tester.ensureVisible(find.text('Create Webinars'));

    await tester.tap(find.text('Create Webinars'));
    await tester.pumpAndSettle();
    
    expect(find.byType(CreateWebinarScreen), findsOne);
  });

  testWidgets('Test adding a webinar that is live should change analytics to say 1 live', (WidgetTester tester) async {
    mockFirestore.collection('Webinar').add({
      'id' : 'id',
      'title' : 'Test',
      'url' :  'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail' : "doesntmatter",
      'webinarleadname' : 'John Doe',
      'startTime' : DateTime.now().toString(),
      'views' : 0,
      'dateStarted' : DateTime.now().toString(),
      'status' : 'Live',
    });
    await tester.pumpWidget(webinarDashboardWidget);
    await tester.pumpAndSettle();
  
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Test adding a webinar that is upcoming should change analytics to say 1 upcoming', (WidgetTester tester) async {
    mockFirestore.collection('Webinar').add({
      'id' : 'id',
      'title' : 'Test',
      'url' :  'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail' : "doesntmatter",
      'webinarleadname' : 'John Doe',
      'startTime' : DateTime.now().toString(),
      'views' : 0,
      'dateStarted' : DateTime.now().toString(),
      'status' : 'Upcoming',
    });
    await tester.pumpWidget(webinarDashboardWidget);
    await tester.pumpAndSettle();
  
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Test setting a webinar as archived should change analytics to say 1 archived', (WidgetTester tester) async {
    mockFirestore.collection('Webinar').add({
      'id' : 'id',
      'title' : 'Test',
      'url' :  'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail' : "doesntmatter",
      'webinarleadname' : 'John Doe',
      'startTime' : DateTime.now().toString(),
      'views' : 0,
      'dateStarted' : DateTime.now().toString(),
      'status' : 'Archived',
    });
    await tester.pumpWidget(webinarDashboardWidget);
    await tester.pumpAndSettle();
  
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Test having a webinar with views should change live viewers analytics to say number of viewers', (WidgetTester tester) async {
    mockFirestore.collection('Webinar').add({
      'id' : 'id',
      'title' : 'Test',
      'url' :  'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail' : "doesntmatter",
      'webinarleadname' : 'John Doe',
      'startTime' : DateTime.now().toString(),
      'views' : 5,
      'dateStarted' : DateTime.now().toString(),
      'status' : 'Archived',
    });
    await tester.pumpWidget(webinarDashboardWidget);
    await tester.pumpAndSettle();
  
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('Test having multiple webinar with views should change live viewers analytics to say number of viewers', (WidgetTester tester) async {
    mockFirestore.collection('Webinar').add({
      'id' : 'id',
      'title' : 'Test',
      'url' :  'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail' : "doesntmatter",
      'webinarleadname' : 'John Doe',
      'startTime' : DateTime.now().toString(),
      'views' : 5,
      'dateStarted' : DateTime.now().toString(),
      'status' : 'Archived',
    });
    mockFirestore.collection('Webinar').add({
      'id' : '2ndid',
      'title' : 'Test',
      'url' :  'https://www.youtube.com/watch?v=tSXZ8hervyY',
      'thumbnail' : "doesntmatter",
      'webinarleadname' : 'Jane Doe',
      'startTime' : DateTime.now().toString(),
      'views' : 10,
      'dateStarted' : DateTime.now().toString(),
      'status' : 'Archived',
    });
    await tester.pumpWidget(webinarDashboardWidget);
    await tester.pumpAndSettle();
  
    expect(find.text('15'), findsOneWidget);
  });

}
