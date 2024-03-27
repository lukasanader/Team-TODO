import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/topic_model.dart';

class TopicController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  TopicController({required this.auth, required this.firestore});

  Future<String> getTopicTitle(String topicID) async {
    DocumentSnapshot snapshot =
        await firestore.collection('topics').doc(topicID).get();
    return snapshot['title'];
  }

  Future<List<Topic>> getTopicList() async {
    String uid = auth.currentUser!.uid;
    DocumentSnapshot user = await firestore.collection('Users').doc(uid).get();
    String role = user['roleType'];
    QuerySnapshot data;

    if (role == 'admin') {
      data = await firestore.collection('topics').orderBy('title').get();
    } else {
      data = await firestore
          .collection('topics')
          .where('tags', arrayContains: role)
          .orderBy('title')
          .get();
    }

    List<Topic> topicList =
        List.from(data.docs.map((doc) => Topic.fromSnapshot(doc)));

    return topicList;
  }

  Future<void> incrementView(Topic topic) async {
    DocumentReference docRef = firestore.collection('topics').doc(topic.id);
    // Run the transaction
    await firestore.runTransaction((transaction) async {
      // Get the latest snapshot of the document
      DocumentSnapshot snapshot = await transaction.get(docRef);
      int currentViews =
          (snapshot.data() as Map<String, dynamic>)['views'] ?? 0;
      // Increment the views by one
      int newViews = currentViews + 1;
      // Update the 'views' field in Firestore
      transaction.update(docRef, {'views': newViews});
    });
  }

  Future<Topic> getTopic(String? id) async {
    DocumentSnapshot snapshot =
        await firestore.collection('Topics').doc(id).get();
    return Topic.fromSnapshot(snapshot);
  }
}
