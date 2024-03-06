import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/screens/webinar-screens/chat.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late Widget ChatScreenWidget;
  late UserModel user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    user = UserModel(
      uid: 'mockUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'Patient',
      email: 'testemail@email.com',
    );
    ChatScreenWidget = MaterialApp(
      home: Chat(firestore: firestore, user: user, channelId: 'test'),
    );
  });

  testWidgets('Chat Widget Test - Loading State', (WidgetTester tester) async {
    await tester.pumpWidget(ChatScreenWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Chat Widget Test - Error State', (WidgetTester tester) async {
    firestore.collection('Webinar').doc('test').collection('comments').add({
      'uid': 'mockUid',
      'roleType': 'Patient',
      'message': 'Test message',
      'createdAt': DateTime.now(),
    });

    await tester.pumpWidget(ChatScreenWidget);
    await tester.pumpAndSettle();

    expect(find.text('Error loading chat'), findsNothing);
  });

  testWidgets('Chat Widget Test - Loaded State', (WidgetTester tester) async {
    firestore.collection('Webinar').doc('test').collection('comments').add({
      'uid': 'mockUid',
      'roleType': 'Patient',
      'message': 'Test message',
      'createdAt': DateTime.now(),
    });

    await tester.pumpWidget(ChatScreenWidget);
    await tester.pumpAndSettle();

    expect(find.text('Test message'), findsOneWidget);
  });

  testWidgets('Test Anonymous name displays correctly', (WidgetTester tester) async {
    firestore.collection('Webinar').doc('test').collection('comments').add({
      'uid': 'mockUid',
      'roleType': user.roleType,
      'message': 'Test message',
      'createdAt': DateTime.now(),
    });

    await tester.pumpWidget(ChatScreenWidget);
    await tester.pumpAndSettle();

    expect(find.text('Anonymous Beaver'), findsOneWidget);
  });

  testWidgets('Test Doctor name displays correctly', (WidgetTester tester) async {
    firestore.collection('Webinar').doc('test').collection('comments').add({
      'uid': 'mockUid',
      'roleType': 'Healthcare Professional',
      'message': 'Test message',
      'createdAt': DateTime.now(),
    });

    await tester.pumpWidget(ChatScreenWidget);
    await tester.pumpAndSettle();

    expect(find.text(user.firstName), findsOneWidget);
  });

  testWidgets('Test User can not write profanities in their messages', (WidgetTester tester) async {
    await tester.pumpWidget(ChatScreenWidget);
    await tester.pumpAndSettle();

    final enterMessageField = find.ancestor(
      of: find.text('Type your message...'),
      matching: find.byType(TextField),
    );
    await tester.enterText(enterMessageField, 'You are an ass');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('Please refrain from using language that may be rude to others or writing your name in your messages.'), findsOneWidget);
    
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    
    expect(find.text('Please refrain from using language that may be rude to others or writing your name in your messages.'), findsNothing);
  });

  testWidgets('Test User can not write their name in their messages', (WidgetTester tester) async {
    await tester.pumpWidget(ChatScreenWidget);
    await tester.pumpAndSettle();
    
    final enterMessageField = find.ancestor(
      of: find.text('Type your message...'),
      matching: find.byType(TextField),
    );
    
    await tester.enterText(enterMessageField, 'I am ${user.firstName}');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    
    expect(find.text('Please refrain from using language that may be rude to others or writing your name in your messages.'), findsOneWidget);
    
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    
    expect(find.text('Please refrain from using language that may be rude to others or writing your name in your messages.'), findsNothing);
  });
}