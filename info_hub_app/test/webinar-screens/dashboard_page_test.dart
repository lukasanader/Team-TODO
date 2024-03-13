import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/screens/webinar-screens/dashboard.dart';
import 'package:info_hub_app/models/user_model.dart';


void main() {
  late FakeFirebaseFirestore firestore;
  late Widget GoLive;
  late UserModel testUser;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    testUser = UserModel(
      uid: 'mockUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'Healthcare Professional',
      email: 'testemail@email.com',
    );
    GoLive = MaterialApp(
      home: GoLiveScreen(user: testUser, firestore: firestore),
    );
  });

  testWidgets('Test Image Picker is present', (WidgetTester tester) async {
    await tester.pumpWidget(GoLive);
    expect(find.text('Select a thumbnail'), findsOneWidget);
  });

  testWidgets('Test Title Text is present', (WidgetTester tester) async {
    await tester.pumpWidget(GoLive);
    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets('Test Title Text Entry is present', (WidgetTester tester) async {
    await tester.pumpWidget(GoLive);
    expect(find.text('Enter your title'), findsOneWidget);
  });

  testWidgets('Test Start Webinar button is present', (WidgetTester tester) async {
    await tester.pumpWidget(GoLive);
    expect(find.text('Start Webinar'), findsOneWidget);
  });

}
