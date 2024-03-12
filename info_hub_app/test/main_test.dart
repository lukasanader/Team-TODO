import 'dart:ffi';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/registration/start_page.dart';
import 'package:integration_test/integration_test.dart';

void main() async {

  testWidgets('Test my app widget', (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();
    final mockStorage = MockFirebaseStorage();
    final auth = MockFirebaseAuth();
    await tester.pumpWidget(MyApp(
      firestore: firestore,
      auth: auth,
      storage: mockStorage,
    ));
    expect(find.byType(StartPage), findsOne);
    

  });


}
