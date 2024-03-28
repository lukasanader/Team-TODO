import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:info_hub_app/view/discovery_view/discovery_view.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late MockFirebaseStorage storage;
  late CollectionReference topicsCollectionRef;
  late Widget discoveryViewWidget;
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    storage = MockFirebaseStorage();
    topicsCollectionRef = firestore.collection('topics');
    await auth.createUserWithEmailAndPassword(
        email: 'test@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'test@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'Patient'
    });
    topicsCollectionRef.add({
      'title': 'B test',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'categories': [],
      'tags': ['Patient']
    });
    topicsCollectionRef.add({
      'title': 'D test',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': [],
    });
    topicsCollectionRef.add({
      'title': 'A test',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': [],
    });
    topicsCollectionRef.add({
      'title': 'C test',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': [],
    });

    discoveryViewWidget = MaterialApp(
      home: DiscoveryView(storage: storage, auth: auth, firestore: firestore),
    );
  });

  testWidgets('DiscoveryView has appbar, search bar and search icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('DiscoveryView search button does nothing (is null)',
      (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);

    final searchButton = find.byType(TextField);

    await tester.tap(searchButton);
    await tester.pump();

    expect(find.byWidget(discoveryViewWidget), findsOneWidget);
  });

  testWidgets('DiscoveryView will display topics based on search accurately',
      (WidgetTester tester) async {
    topicsCollectionRef.add({
      'title': 'Multiple will show',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': [],
    });
    topicsCollectionRef.add({
      'title': 'Multiple will show 2',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': [],
    });
    topicsCollectionRef.add({
      'title': 'Multiple will show 3',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': [],
    });

    await tester.pumpWidget(discoveryViewWidget);

    final searchTextField = find.byType(TextField);

    await tester.enterText(searchTextField, 'multiple');
    await tester.pump();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(3));

    final textFinders = find.byType(Text);

    expect((textFinders.first.evaluate().single.widget as Text).data,
        'Multiple will show');
    expect((textFinders.at(2).evaluate().single.widget as Text).data,
        'Multiple will show 2');
    expect((textFinders.at(4).evaluate().single.widget as Text).data,
        'Multiple will show 3');
  });

  testWidgets(
      'DiscoveryView will display "Sorry there are no topics for this!" if no existing topic exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);

    final searchTextField = find.byType(TextField);

    await tester.enterText(searchTextField, 'There is not test with this name');
    await tester.pump();

    expect(find.text('Sorry there are no topics for this!'), findsOneWidget);
  });

  testWidgets('DiscoveryView topics are in alphabetical order',
      (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    // Tap into the ListView
    Finder listViewFinder = find.byType(ListView);
    expect(listViewFinder, findsOneWidget);

    // Get the list of cards
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(4));

    final textFinders = find.byType(Text);
    // Check the order of card titles
    expect((textFinders.first.evaluate().single.widget as Text).data, 'A test');
    expect((textFinders.at(2).evaluate().single.widget as Text).data, 'B test');
    expect((textFinders.at(4).evaluate().single.widget as Text).data, 'C test');
    expect((textFinders.at(6).evaluate().single.widget as Text).data, 'D test');
  });

  testWidgets('DiscoveryView will display categories as toggle buttons',
      (WidgetTester tester) async {
    await firestore.collection('categories').add({'name': 'Gym'});
    await firestore.collection('categories').add({'name': 'School'});
    await firestore.collection('categories').add({'name': 'Smoking'});

    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gym'));
    await tester.pumpAndSettle();
    expect(find.text('Gym'), findsOneWidget);

    await tester.ensureVisible(find.text('School'));
    await tester.pumpAndSettle();
    expect(find.text('School'), findsOneWidget);

    await tester.ensureVisible(find.text('Smoking'));
    await tester.pumpAndSettle();
    expect(find.text('Smoking'), findsOneWidget);
  });

  testWidgets('DiscoveryView will display topics specific to one category',
      (WidgetTester tester) async {
    await firestore.collection('categories').add({'name': 'Gym'});
    await firestore.collection('categories').add({'name': 'School'});
    await firestore.collection('categories').add({'name': 'Smoking'});

    topicsCollectionRef.add({
      'title': 'Gym topic should only show',
      'description': 'this is a test',
      'articleLink': '',
      'categories': ['Gym'],
      'media': [],
      'views': 1,
      'tags': ['Patient'],
      'date': DateTime.now()
    });

    topicsCollectionRef.add({
      'title': 'Gym topic should only show 2',
      'description': 'this is a test',
      'articleLink': '',
      'categories': ['Gym'],
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'tags': ['Patient']
    });

    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gym'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gym'));
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(2));

    expect(find.text('Gym topic should only show'), findsOneWidget);
    expect(find.text('Gym topic should only show 2'), findsOneWidget);
  });

  testWidgets('Tapping the filters twice will turn it off',
      (WidgetTester tester) async {
    await firestore.collection('categories').add({'name': 'Gym'});
    await firestore.collection('categories').add({'name': 'School'});
    await firestore.collection('categories').add({'name': 'Smoking'});

    topicsCollectionRef.add({
      'title': 'Gym topic should only show',
      'description': 'this is a test',
      'articleLink': '',
      'categories': ['Gym'],
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'tags': ['Patient']
    });

    topicsCollectionRef.add({
      'title': 'Gym topic should only show 2',
      'description': 'this is a test',
      'articleLink': '',
      'categories': ['Gym'],
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'tags': ['Patient']
    });

    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gym'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gym'));
    await tester.pumpAndSettle();

    //filters to two
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(2));

    //pressing filter again
    await tester.tap(find.text('Gym'));
    await tester.pumpAndSettle();

    //all topics are now visible as filter is off
    expect(cardFinder, findsNWidgets(6));
  });

  testWidgets('DiscoveryView will display topics based on multiple filters',
      (WidgetTester tester) async {
    await firestore.collection('categories').add({'name': 'Gym'});
    await firestore.collection('categories').add({'name': 'School'});
    await firestore.collection('categories').add({'name': 'Smoking'});

    topicsCollectionRef.add({
      'title': 'Gym topic should only show',
      'description': 'this is a test',
      'articleLink': '',
      'categories': ['Gym'],
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'tags': ['Patient']
    });

    topicsCollectionRef.add({
      'title': 'Gym and smoking',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'categories': ['Gym', 'Smoking'],
      'tags': ['Patient']
    });

    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Gym'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gym'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Smoking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smoking'));
    await tester.pumpAndSettle();

    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(1));

    expect(find.text('Gym and smoking'), findsOneWidget);
  });

  testWidgets('DiscoveryView will display topics based on filter and search',
      (WidgetTester tester) async {
    await firestore.collection('categories').add({'name': 'Gym'});
    await firestore.collection('categories').add({'name': 'School'});
    await firestore.collection('categories').add({'name': 'Smoking'});

    topicsCollectionRef.add({
      'title': 'Smoking topic',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'categories': ['Smoking'],
      'tags': ['Patient']
    });

    topicsCollectionRef.add({
      'title': 'Smoking topic with specific title',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'categories': ['Smoking'],
      'tags': ['Patient']
    });

    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Smoking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smoking'));
    await tester.pumpAndSettle();

    //expecting both topics to show
    Finder cardFinder = find.byType(Card);
    expect(cardFinder, findsNWidgets(2));

    final searchTextField = find.byType(TextField);

    await tester.enterText(searchTextField, 'specific');
    await tester.pump();

    //smoking topic should be gone
    expect(cardFinder, findsNWidgets(1));

    expect(find.text('Smoking topic'), findsNothing);
    expect(find.text('Smoking topic with specific title'), findsOneWidget);
  });

  testWidgets('Ask topic question Test', (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    // Trigger the _showPostDialog method
    await tester.tap(find.text('Ask a question!'));
    await tester.pumpAndSettle();

    // Verify that the first AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text('Ask a question!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a question.'), findsOne);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.enterText(find.byType(TextField).last, 'Test question');

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify that the second AlertDialog is displayed
    expect(find.text('Message'), findsOneWidget);

    // Tap the OK button to close the second AlertDialog
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Verify that both AlertDialogs are closed
    expect(find.byType(AlertDialog), findsNothing);

    // Verify that the question is added to the Firestore collection
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firestore.collection("questions").get();
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;

    // Check if the collection contains a document with the expected question
    expect(
      documents.any(
        (doc) => doc.data()?['question'] == 'Test question',
      ),
      isTrue,
    );
  });

  testWidgets('Test snackbar pops up when blank question asked',
      (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    // Trigger the _showPostDialog method
    await tester.tap(find.text('Ask a question!'));
    await tester.pumpAndSettle();

    // Verify that the first AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);

    // Enter text into the TextField
    await tester.enterText(find.byType(TextField).last, '');

    // Tap the Submit button
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();


    //blank answer submitted therefore alert dialog isn't closed
    expect(find.text('Please enter a question.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);

  });


  testWidgets('Test cancel button upon show dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    // Trigger the _showPostDialog method
    await tester.tap(find.text('Ask a question!'));
    await tester.pumpAndSettle();

    // Verify that the first AlertDialog is displayed
    expect(find.byType(AlertDialog), findsOneWidget);


    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    //verify the AlertDialog is no longer displayed
    expect(find.byType(AlertDialog), findsNothing);

    expect(find.byType(DiscoveryView), findsOneWidget);

  });


  testWidgets('test that shown topics are only of the same role as user',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.

    CollectionReference topicCollectionRef = firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'test 1',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': [],
    });
    topicCollectionRef.add({
      'title': 'test 2',
      'description': 'this is a test again',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Parent'],
      'categories': [],
    });
    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    expect(find.text('test 1'), findsOneWidget);
    expect(find.text('test 2'), findsNothing);
  });

  testWidgets('test that admin can see all topics',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await auth.createUserWithEmailAndPassword(
        email: 'admin@tested.org', password: 'Password123!');
    String uid = auth.currentUser!.uid;
    await firestore.collection('Users').doc(uid).set({
      'email': 'admin@tested.org',
      'firstName': 'James',
      'lastName': 'Doe',
      'roleType': 'admin'
    });

    CollectionReference topicCollectionRef = firestore.collection('topics');
    topicCollectionRef.add({
      'title': 'test 1',
      'description': 'this is a test',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Patient'],
      'categories': [],
    });
    topicCollectionRef.add({
      'title': 'test 2',
      'description': 'this is a test again',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Parent'],
      'categories': [],
    });
    topicCollectionRef.add({
      'title': 'test 3',
      'description': 'this is a test again',
      'articleLink': '',
      'media': [],
      'views': 1,
      'date': DateTime.now(),
      'likes': 0,
      'dislikes': 0,
      'tags': ['Healthcare Professional'],
      'categories': [],
    });
    await tester.pumpWidget(discoveryViewWidget);
    await tester.pumpAndSettle();

    expect(find.text('test 1'), findsOneWidget);
    expect(find.text('test 2'), findsOneWidget);
    expect(find.text('test 3'), findsOneWidget);
  });
}
