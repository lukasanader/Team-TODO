import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/analytics/analytics_base.dart';
import 'package:info_hub_app/analytics/topics/analytics_topic.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

void main() {
  late FirebaseFirestore firestore = FakeFirebaseFirestore();
  late MockFirebaseStorage mockStorage = MockFirebaseStorage();
  late Widget allAnalyticsWidget;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    allAnalyticsWidget = MaterialApp(
      home: AnalyticsBase(firestore: firestore, storage: mockStorage),
    );
  });

  testWidgets('Test Topics button', (WidgetTester tester) async {
    await tester.pumpWidget(allAnalyticsWidget);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.byType(AnalyticsTopicView), findsOneWidget);
  });
}
