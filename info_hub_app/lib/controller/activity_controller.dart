import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/activity_model.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';

class ActivityController {
  FirebaseFirestore firestore;
  FirebaseAuth auth;
  ActivityController({required this.firestore, required this.auth});

  Future addActivity(String aid, String activityType) async {
    String uid = auth.currentUser!.uid;
    Activity activity = Activity(
        id: '', aid: aid, type: activityType, uid: uid, date: Timestamp.now());
    QuerySnapshot data = await firestore
        .collection('activity')
        .where('aid', isEqualTo: aid)
        .where('uid', isEqualTo: uid)
        .get();
    if (data.docs.isEmpty) {
      addAcitivity(activity);
    } else {
      activity.id = data.docs.first.id;
      updateActivity(activity);
    }
  }

  Future<void> addAcitivity(Activity activity) async {
    CollectionReference activityCollectionRef =
        firestore.collection('activity');
    await activityCollectionRef.add({
      'uid': activity.uid,
      'aid': activity.aid,
      'type': activity.type,
      'date': activity.date
    });
  }

  Future<void> updateActivity(Activity activity) async {
    CollectionReference activityCollectionRef = firestore.collection('activity');
  
    // Create a map containing only the fields to be updated
    Map<String, dynamic> data = {'date': activity.date};
  
    // Perform the update with merge option set to true
    await activityCollectionRef.doc(activity.id).set(data, SetOptions(merge: true));
  }

  Future<List<dynamic>> getActivityList(String activityName) async {
    String uid = auth.currentUser!.uid;
    QuerySnapshot data = await firestore
        .collection('activity')
        .where('type', isEqualTo: activityName)
        .where('uid', isEqualTo: uid)
        .get();
    List<Activity> activities =
        data.docs.map((doc) => Activity.fromSnapshot(doc)).toList();
    List<dynamic> userActivity = [];

    for (int index = 0; index < activities.length; index++) {
      String activityID = activities[index].aid;
      DocumentSnapshot snapshot =
          await firestore.collection(activityName).doc(activityID).get();
      dynamic activity;   
      if(activityName=='topics'){    
        activity= Topic.fromSnapshot(snapshot);
        activity.viewDate=activities[index].date;
      }else{
        activity = snapshot.data();
        activity['viewDate']=activities[index].date;
      }
      userActivity.add(activity);
    }
    return userActivity;
  }

  Future<List<Topic>> getLikedTopics() async {
    String uid = auth.currentUser!.uid;
    DocumentSnapshot snapshot =
        await firestore.collection('Users').doc(uid).get();
    Map<String, dynamic> temp = snapshot.data() as Map<String, dynamic>;
    List<dynamic> userTopics = temp['likedTopics'];
    (userTopics);

    List<Topic> likedTopics = [];
    for (int index = 0; index < userTopics.length; index++) {
      DocumentSnapshot doc =
          await firestore.collection('topics').doc(userTopics[index]).get();
      Topic temp = Topic.fromSnapshot(doc);
      likedTopics.add(temp);
    }
    return likedTopics;
  }

  Future<void> deleteActivity(String aid) async {
    CollectionReference collectionRef = firestore.collection('activity');
    QuerySnapshot querySnapshot =
        await collectionRef.where('aid', isEqualTo: aid).get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }
  }
}
