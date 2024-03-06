import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/screens/webinar-screens/webinar_details_screen.dart';
import 'package:mockito/mockito.dart';


void main() {
    late FakeFirebaseFirestore mockFirestore;
    late UserModel testUser;
    late Widget BroadcastScreenWidget;

    setUp(() {
      mockFirestore = FakeFirebaseFirestore();
      testUser = UserModel(
        uid: 'testUid',
        firstName: 'John',
        lastName: 'Doe',
        roleType: 'Healthcare Professional',
        email: 'john.doe@nhs.co.uk',
      );
      BroadcastScreenWidget = MaterialApp(
          home: BroadcastScreen(
            isBroadcaster: true,
            channelId: 'testUid',
            currentUser: testUser,
            firestore: mockFirestore,
            title: 'Webinar Title',
          ),
        );
    });

    testWidgets('Test UI elements for broadcaster', (WidgetTester tester) async {
      await tester.pumpWidget(BroadcastScreenWidget);

      // Test UI elements for broadcaster, you can use find.byWidgetPredicate or find.byType
      expect(find.text('Webinar Title'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.text('Switch Camera'), findsOneWidget);
      expect(find.text('Mute'), findsOneWidget);
      expect(find.text('End Webinar'), findsOneWidget);
    });

    testWidgets('Test UI elements for audience', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BroadcastScreen(
            isBroadcaster: false,
            channelId: 'testChannelId',
            currentUser: testUser,
            firestore: mockFirestore,
            title: 'Webinar Title',
          ),
        ),
      );

      // Test UI elements for audience
      expect(find.text('Webinar Title'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.byKey(ValueKey('switch_camera_button')), findsNothing);
      expect(find.byKey(ValueKey('toggle_mute_button')), findsNothing);
      expect(find.byKey(ValueKey('end_webinar_button')), findsNothing);
    });

    testWidgets('Test Guide Button is pressable', (WidgetTester tester) async {
      await tester.pumpWidget(BroadcastScreenWidget);
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      expect(find.text('Webinar Guide and Expectations'),findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Webinar Guide and Expectations'),findsNothing);      
    });


}
