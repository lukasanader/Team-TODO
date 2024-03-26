import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class WebinarViewHelper{
  FakeFirebaseFirestore fakeFirestore;

  WebinarViewHelper({
    required this.fakeFirestore,
  });

  void addUpcomingFirestoreDocument() async {
    await fakeFirestore.collection('Webinar').doc('id').set({
      'id': 'id',
      'title': 'Test Title',
      'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail': 'https://picsum.photos/250?image=9',
      'webinarleadname': 'John Doe',
      'startTime': DateTime.now().toString(),
      'views': 0,
      'dateStarted': DateTime.now().toString(),
      'status': 'Upcoming',
      'chatenabled': true,
      'selectedtags': ['admin'],
    });
  }

  void addLiveFirestoreDocument() async {
    await fakeFirestore.collection('Webinar').doc('id').set({
      'id': 'id',
      'title': 'Test Title',
      'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail': 'https://picsum.photos/250?image=9',
      'webinarleadname': 'John Doe',
      'startTime': DateTime.now().toString(),
      'views': 5,
      'dateStarted': DateTime.now().toString(),
      'status': 'Live',
      'chatenabled': true,
      'selectedtags': ['admin'],
    });
  }

  void addArchiveFirestoreDocument() async {
    await fakeFirestore.collection('Webinar').doc('id').set({
      'id': 'id',
      'title': 'Test Title',
      'url': 'https://www.youtube.com/watch?v=tSXZ8hervgY',
      'thumbnail': 'https://picsum.photos/250?image=9',
      'webinarleadname': 'John Doe',
      'startTime': DateTime.now().toString(),
      'views': 5,
      'dateStarted': DateTime.now().toString(),
      'status': 'Archived',
      'chatenabled': true,
      'selectedtags': ['admin'],
    });
  }

}