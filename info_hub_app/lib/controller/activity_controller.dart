import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/activity_model.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';

class ActivityController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ActivityController({
    required this.firestore,
    required this.auth,
  });

  // Add or update an activity based on the given aid and activityType
  Future<void> addActivity(String aid, String activityType) async {
    final String uid = auth.currentUser!.uid;
    final Activity activity = Activity(
      id: '',
      aid: aid,
      type: activityType,
      uid: uid,
      date: Timestamp.now(),
    );

    final QuerySnapshot data = await firestore
        .collection('activity')
        .where('aid', isEqualTo: aid)
        .where('uid', isEqualTo: uid)
        .get();

    if (data.docs.isEmpty) {
      await addActivityToFirestore(activity);
    } else {
      activity.id = data.docs.first.id;
      await updateActivity(activity);
    }
  }

  // Add a new activity to Firestore
  Future<void> addActivityToFirestore(Activity activity) async {
    final CollectionReference activityCollectionRef =
        firestore.collection('activity');

    await activityCollectionRef.add({
      'uid': activity.uid,
      'aid': activity.aid,
      'type': activity.type,
      'date': activity.date,
    });
  }

  // Update an existing activity in Firestore
  Future<void> updateActivity(Activity activity) async {
    final CollectionReference activityCollectionRef =
        firestore.collection('activity');

    // Create a map containing only the fields to be updated
    final Map<String, dynamic> data = {'date': activity.date};

    // Perform the update with merge option set to true
    await activityCollectionRef
        .doc(activity.id)
        .set(data, SetOptions(merge: true));
  }

  // Get a list of activities based on the given activityName
  Future<List<dynamic>> getActivityList(String activityName) async {
    final String uid = auth.currentUser!.uid;
    final QuerySnapshot data = await firestore
        .collection('activity')
        .where('type', isEqualTo: activityName)
        .where('uid', isEqualTo: uid)
        .get();

    final List<Activity> activities =
        data.docs.map((doc) => Activity.fromSnapshot(doc)).toList();
    final List<dynamic> userActivity = [];

    for (int index = 0; index < activities.length; index++) {
      final String activityID = activities[index].aid;
      final DocumentSnapshot snapshot =
          await firestore.collection(activityName).doc(activityID).get();

      dynamic activity;
      if (activityName == 'topics') {
        activity = Topic.fromSnapshot(snapshot);
        activity.viewDate = activities[index].date;
      } else {
        activity = snapshot.data();
        activity['viewDate'] = activities[index].date;
      }

      userActivity.add(activity);
    }

    return userActivity;
  }

  // Get a list of liked topics for the current user
  Future<List<Topic>> getLikedTopics() async {
    final String uid = auth.currentUser!.uid;
    final DocumentSnapshot snapshot =
        await firestore.collection('Users').doc(uid).get();
    final Map<String, dynamic>? temp = snapshot.data() as Map<String, dynamic>?;

    final List<dynamic>? userTopics = temp?['likedTopics'];
    final List<Topic> likedTopics = [];

    if (userTopics != null) {
      for (int index = 0; index < userTopics.length; index++) {
        final DocumentSnapshot doc =
            await firestore.collection('topics').doc(userTopics[index]).get();
        final Topic temp = Topic.fromSnapshot(doc);
        likedTopics.add(temp);
      }
    }

    return likedTopics;
  }

  // Delete an activity based on the given aid
  Future<void> deleteActivity(String aid) async {
    final CollectionReference collectionRef = firestore.collection('activity');
    final QuerySnapshot querySnapshot =
        await collectionRef.where('aid', isEqualTo: aid).get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
  }
}