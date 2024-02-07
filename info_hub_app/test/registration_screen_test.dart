import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:info_hub_app/screens/registration_screen.dart';

void main() {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Test if text at top of screen is present', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegistrationScreen()));
    expect(find.text('Please fill in the registration details.'), findsOneWidget);
  });
}
