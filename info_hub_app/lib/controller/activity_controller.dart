import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/model.dart';

class ActivityController{
  FirebaseFirestore firestore;
  FirebaseAuth auth;
  ActivityController({required this.firestore,required this.auth});

  Future addActivity(String aid, String activityType) async{
    String uid = auth.currentUser!.uid;
    Activity activity = Activity(
      id: '', 
      aid: aid, 
      type: activityType,
      uid: uid,
      date: Timestamp.now()
    );
    QuerySnapshot data = await firestore.collection('activity').where('aid', isEqualTo: aid).where('uid', isEqualTo: uid).get();
    if(data.docs.isEmpty){
      addAcitivity(activity);
    }else{
      activity.id=data.docs.first.id;
      updateActivity(activity);
    }
  }

  Future<void> addAcitivity(Activity activity) async{
    CollectionReference activityCollectionRef = firestore.collection('activity');
      await activityCollectionRef.add({
        'uid': activity.uid,
        'aid': activity.aid,
        'type': activity.type,
        'date': activity.date
      });
    }

  Future<void> updateActivity(Activity activity) async{
    CollectionReference activityCollectionRef = firestore.collection('activity');
      await activityCollectionRef.doc(activity.id).set({
        'date': activity.date
      });
    }
  
  
  
  Future<List<dynamic>> getActivityList(String activity) async {
    String uid = auth.currentUser!.uid;
    QuerySnapshot data = await firestore.collection('activity').where('type', isEqualTo: activity).where('uid', isEqualTo: uid).get();
    List<Activity> activities = data.docs.map((doc) => Activity.fromSnapshot(doc)).toList();
    List<dynamic> userActivity = [];

    for (int index = 0; index < activities.length; index++) {
      String activityID = activities[index].aid;
      DocumentSnapshot snapshot = await firestore.collection(activity).doc(activityID).get();
      Map<String, dynamic> temp = snapshot.data() as Map<String, dynamic>;
      temp['viewDate'] = activities[index].date;
      userActivity.add(temp);
    }
    return userActivity;
}

Future<List<dynamic>> getLikedTopics() async {
  String uid = auth.currentUser!.uid;
  DocumentSnapshot snapshot = await firestore.collection('Users').doc(uid).get();
    Map<String, dynamic> temp = snapshot.data() as Map<String, dynamic>;
    List<dynamic> userTopics = temp['likedTopics'];
    (userTopics);
    
    List<dynamic> likedTopics =[];
    for(int index = 0; index < userTopics.length; index++){
      DocumentSnapshot doc = await firestore.collection('topics').doc(userTopics[index]).get();
      Map<String, dynamic> temp = doc.data() as Map<String, dynamic>;
      likedTopics.add(temp);
    } 
    return likedTopics;
}

  Future<void> deleteActivity(String aid) async {
    CollectionReference collectionRef = FirebaseFirestore.instance.collection('activity');
    QuerySnapshot querySnapshot = await collectionRef.where('aid', isEqualTo: aid).get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }

  }
}