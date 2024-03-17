import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/admin-webinar-screens/admin_webinar_dashboard.dart';
import 'package:info_hub_app/webinar/admin-webinar-screens/create_webinar_screen.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/webinar_view.dart';


void main() {
  late FakeFirebaseFirestore mockFirestore;
  late UserModel testUser;
  late MockFirebaseStorage mockStorage;
  late Widget WebinarDashboardWidget;

  setUp(() {
    mockFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    WebinarService webService = WebinarService(
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

    WebinarDashboardWidget = MaterialApp(
      home: WebinarDashboard(
        firestore: mockFirestore,
        user: testUser,
        webinarService: webService, // Pass the mock service to the widget
      ),
    );

  });


  testWidgets('Test all widgets appear as expected', (WidgetTester tester) async {
    await tester.pumpWidget(WebinarDashboardWidget);

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
    await tester.pumpWidget(WebinarDashboardWidget);
    await tester.ensureVisible(find.text('View Webinars'));

    await tester.tap(find.text('View Webinars'));
    await tester.pumpAndSettle();

    expect(find.byType(WebinarView), findsOne);
  });


  testWidgets('Test pressing Create Webinar button redirects to create webinar screen', (WidgetTester tester) async {
    await tester.pumpWidget(WebinarDashboardWidget);
    await tester.ensureVisible(find.text('Create Webinars'));

    await tester.tap(find.text('Create Webinars'));
    await tester.pumpAndSettle();
    
    expect(find.byType(CreateWebinarScreen), findsOne);
  });

}
