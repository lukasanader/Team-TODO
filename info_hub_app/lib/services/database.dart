import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/preferences.dart';

class DatabaseService {
  final String uid;
  final FirebaseFirestore firestore;

  DatabaseService({required this.uid, required this.firestore});

  Future<String> createNotification(
      String title, String body, DateTime timestamp) async {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    var docRef = await notificationsCollection.add({
      'uid': uid,
      'title': title,
      'body': body,
      'timestamp': timestamp,
    });
    return docRef.id;
  }

  Future<void> deleteNotification(String id) async {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    await notificationsCollection.doc(id).delete();
  }

  List<custom.Notification> notificationListFromSnapshot(
      QuerySnapshot snapshot) {
    final notifications = snapshot.docs.map((doc) {
      return custom.Notification(
        id: doc.id,
        uid: doc.get('uid') ?? '',
        title: doc.get('title') ?? '',
        body: doc.get('body') ?? '',
        timestamp: doc.get('timestamp').toDate() ?? DateTime.now(),
      );
    }).toList();

    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return notifications;
  }

  Stream<List<custom.Notification>> get notifications {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    return notificationsCollection
        .snapshots()
        .map(notificationListFromSnapshot);
  }

  Future addUserData(
      String firstName,
      String lastName,
      String email,
      String roleType,
      List<String> likedTopics,
      List<String> dislikedTopics,
      bool hasOptedOutOfExperienceExpectations) async {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    if (roleType == 'Patient') {
      // If you are a patient, you have access to the story expectations
      return await usersCollectionRef.doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'roleType': roleType,
        'likedTopics': likedTopics,
        'dislikedTopics': dislikedTopics,
        'hasOptedOutOfExperienceExpectations':
            hasOptedOutOfExperienceExpectations,
      });
    }
    return await usersCollectionRef.doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
      'likedTopics': likedTopics,
      'dislikedTopics': dislikedTopics,
    });
  }

  List<UserModel> userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModel(
        uid: doc.id,
        firstName: doc.get('firstName') ?? '',
        lastName: doc.get('lastName') ?? '',
        email: doc.get('email') ?? '',
        roleType: doc.get('roleType') ?? '',
        likedTopics: doc.get('likedTopics') ?? [],
        dislikedTopics: doc.get('dislikedTopics') ?? [],
        hasOptedOutOfExperienceExpectations:
            doc.get('hasOptedOutOfExperienceExpectations') ?? false,
      );
    }).toList();
  }

  Stream<List<UserModel>> get users {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    return usersCollectionRef.snapshots().map(userListFromSnapshot);
  }

  Future<void> createPreferences() async {
    CollectionReference prefCollection = firestore.collection('preferences');
    await prefCollection.add({
      'uid': uid,
      'push_notifications': true,
    });
  }

  List<Preferences> prefListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Preferences(
        uid: uid,
        push_notifications: doc.get('push_notifications') ?? true,
      );
    }).toList();
  }

  Stream<List<Preferences>> get preferences {
    CollectionReference prefCollectionRef = firestore.collection('preferences');
    return prefCollectionRef.snapshots().map(prefListFromSnapshot);
  }

    Future addTopicActivity(QueryDocumentSnapshot topic) async{
    QuerySnapshot data = await firestore.collection('activity').where('aid', isEqualTo: topic.id).where('uid', isEqualTo: uid).get();
    if(data.docs.isEmpty){
      CollectionReference activityCollectionRef = firestore.collection('activity');
      await activityCollectionRef.add({
        'uid': uid,
        'aid': topic.id,
        'type': 'topics',
        'date': DateTime.now()
      });
    }
  }
  Future addThreadActivity(String threadId) async{
    QuerySnapshot data = await firestore.collection('activity').where('aid', isEqualTo: threadId).where('uid', isEqualTo: uid).get();
    if(data.docs.isEmpty){
      CollectionReference activityCollectionRef = firestore.collection('activity');
      await activityCollectionRef.add({
        'uid': uid,
        'aid': threadId,
        'type': 'thread',
        'date': DateTime.now()
      });
    }
  }
  
  Future<List<dynamic>> getActivityList(String activity) async {
  QuerySnapshot data = await firestore.collection('activity').where('type', isEqualTo: activity).where('uid', isEqualTo: uid).get();
  List<dynamic> activities = List.from(data.docs);
  List<dynamic> userActivity = [];

  for (int index = 0; index < activities.length; index++) {
    String activityID = activities[index]['aid'];
    DocumentSnapshot snapshot = await firestore.collection(activity).doc(activityID).get();
    Map<String, dynamic> temp = snapshot.data() as Map<String, dynamic>;
    temp['viewDate'] = activities[index]['date'];
    userActivity.add(temp);
  }
  return userActivity;
}

Future<List<dynamic>> getLikedTopics() async {
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

}

