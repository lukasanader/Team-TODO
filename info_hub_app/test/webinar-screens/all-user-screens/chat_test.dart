import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/chat.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late Widget chatScreenWidget;
  late MockFirebaseStorage mockStorage;
  late UserModel user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    WebinarService webService = WebinarService(
      firestore: firestore,
      storage: mockStorage);
    user = UserModel(
      uid: 'mockUid',
      firstName: 'John',
      lastName: 'Doe',
      roleType: 'Patient',
      email: 'testemail@email.com',
      likedTopics: [],
      dislikedTopics: [],
    );
    chatScreenWidget = MaterialApp(
      home: Chat(firestore: firestore,
      user: user, webinarID: 'test',
      webinarService: webService)
    );
  });

  testWidgets('Chat Widget Test - Loading State', (WidgetTester tester) async {
    await tester.pumpWidget(chatScreenWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Chat Widget Test - Error State', (WidgetTester tester) async {
    firestore.collection('Webinar').doc('test').collection('comments').add({
      'uid': 'mockUid',
      'roleType': 'Patient',
      'message': 'Test message',
      'createdAt': DateTime.now(),
    });

    await tester.pumpWidget(chatScreenWidget);
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

    await tester.pumpWidget(chatScreenWidget);
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

    await tester.pumpWidget(chatScreenWidget);
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

    await tester.pumpWidget(chatScreenWidget);
    await tester.pumpAndSettle();

    expect(find.text(user.firstName), findsOneWidget);
  });

  testWidgets('Test User can not write profanities in their messages', (WidgetTester tester) async {
    await tester.pumpWidget(chatScreenWidget);
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
    await tester.pumpWidget(chatScreenWidget);
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

  testWidgets('Test User can type and send message', (WidgetTester tester) async {
    await tester.pumpWidget(chatScreenWidget);
    await tester.pumpAndSettle();
    final enterMessageField = find.ancestor(
      of: find.text('Type your message...'),
      matching: find.byType(TextField),
    );
    await tester.enterText(enterMessageField, 'Hello world');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    final querySnapshot = await firestore
                            .collection('Webinar')
                            .doc('test')
                            .collection('comments')
                            .get();
    expect(querySnapshot.docs.length,greaterThan(0));
  });
}