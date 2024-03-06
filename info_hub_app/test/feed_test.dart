import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/screens/webinar-screens/feed.dart';

void main() async {
  late FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
  late Widget FeedScreenWidget;
  late UserModel user;

  setUp(() {
    user = UserModel(
      uid: 'mockUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'Patient',
      email: 'testemail@email.com',
    );
    FeedScreenWidget = MaterialApp(
      home: FeedScreen(firestore: firestore, user: user),
    );
  });
  testWidgets('FeedScreen Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(FeedScreenWidget);
    await tester.pumpAndSettle();
    expect(find.text('Live Users'), findsOneWidget);
  });
}
