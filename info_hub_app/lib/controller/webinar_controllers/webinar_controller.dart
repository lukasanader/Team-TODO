import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:info_hub_app/model/user_models/user_model.dart';
import 'package:info_hub_app/controller/notification_controllers/notification_controller.dart';
import 'package:info_hub_app/model/livestream_models/livestream_model.dart';
import 'package:uuid/uuid.dart';

class WebinarController {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  WebinarController(
      {required this.firestore, required this.storage, required this.auth});

  /// Initiates live stream creation process on database
  Future<String> startLiveStream(
      String title,
      String url,
      Uint8List image,
      String name,
      String startTime,
      String streamStatus,
      List<String> selectedTags) async {
    // assign random integer as document name
    String webinarID = const Uuid().v1();
    String result = ""; // Variable to store the result
    // check if any document already exists with the set url or with the random id
    CollectionReference webinarRef = firestore.collection('Webinar');
    bool webinarExists = await checkURLExists(webinarRef, url);

    if (!webinarExists) {
      String thumbnailUrl =
          await uploadImageToStorage('webinar-thumbnails', image, webinarID);
      DocumentReference docRef = webinarRef.doc(webinarID);

      await docRef.set({
        'id': webinarID,
        'title': title,
        'url': url,
        'thumbnail': thumbnailUrl,
        'webinarleadname': name,
        'startTime': startTime,
        'views': 0,
        'dateStarted': startTime,
        'status': streamStatus,
        'chatenabled': true,
        'selectedtags': selectedTags,
      });

      result = webinarID; // Assign the collectionId to the result
    }
    return result; // Return the result variable
  }

  /// Checks if admin is uploading an already existing URL
  Future<bool> checkURLExists(CollectionReference ref, String url) async {
    QuerySnapshot querySnapshot = await ref.where('url', isEqualTo: url).get();
    // If there are documents in the query result, it means the uid already exists
    return querySnapshot.docs.isNotEmpty;
  }

  /// Uploads image to storage
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, String uid) async {
    Reference ref = storage.ref().child(childName).child(uid);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Increments or decrements live viewer count on a specific document
  Future<void> updateViewCount(String id, bool isIncrease) async {
    await firestore.collection('Webinar').doc(id).update({
      'views': FieldValue.increment(isIncrease ? 1 : -1),
    });
  }

  /// Adds a comment into the chat feature
  Future<void> chat(
      String text, String id, String roleType, String userID) async {
    String commentId = const Uuid().v1();
    await firestore
        .collection('Webinar')
        .doc(id)
        .collection('comments')
        .doc(commentId)
        .set({
      'message': text,
      'createdAt': DateTime.now(),
      'commentId': commentId,
      'roleType': roleType,
      'uid': userID,
    });
  }

  // retrieves users belonging to a specific webinar
  Future<List<String>> getWebinarRoles(String webinarID) async {
    DocumentSnapshot docSnapshot =
        await firestore.collection('Webinar').doc(webinarID).get();
    if (docSnapshot.exists) {
      List<String> userList = [];
      List<dynamic> selectedTags = docSnapshot['selectedtags'];
      for (String tag in selectedTags) {
        if (tag != 'admin') {
          QuerySnapshot data = await firestore
              .collection('Users')
              .where('roleType', isEqualTo: tag)
              .get();
          data.docs.forEach((doc) {
            userList.add(UserModel.fromSnapshot(doc).uid);
          });
        }
      }
      return userList;
    }
    return [];
  }

  /// Returns number of live webinars
  Future<String> getNumberOfLiveWebinars() async {
    QuerySnapshot snap = await firestore
        .collection('Webinar')
        .where('status', isEqualTo: "Live")
        .get();
    return snap.docs.length.toString();
  }

  /// Returns number of upcoming webinars
  Future<String> getNumberOfUpcomingWebinars() async {
    QuerySnapshot snap = await firestore
        .collection('Webinar')
        .where('status', isEqualTo: "Upcoming")
        .get();
    return snap.docs.length.toString();
  }

  /// Returns number of currently live viewers
  Future<String> getNumberOfLiveViewers() async {
    int totalViews = 0;
    QuerySnapshot snap = await firestore
        .collection('Webinar')
        .where('views', isGreaterThan: 0)
        .get();
    for (int i = 0; i < snap.docs.length; i++) {
      totalViews += snap.docs[i]['views'] as int;
    }
    return totalViews.toString();
  }

  /// Returns number of archived webinars
  Future<String> getNumberOfArchivedWebinars() async {
    QuerySnapshot snap = await firestore
        .collection('Webinar')
        .where('status', isEqualTo: "Archived")
        .get();
    return snap.docs.length.toString();
  }

  /// Alters webinar status from live to archived or upcoming to live
  Future<void> setWebinarStatus(String webinarID, String url,
      {bool changeToLive = false, changeToArchived = false}) async {
    Map<String, dynamic> dataToUpdate = {
      'url': url,
    };

    if (changeToLive) {
      dataToUpdate['status'] = "Live";
    } else if (changeToArchived) {
      dataToUpdate['status'] = "Archived";
      dataToUpdate['chatenabled'] = false;
      NotificationController notificationController = NotificationController(
          auth: auth, firestore: firestore, uid: auth.currentUser!.uid);
      List<String> notificationId =
          await notificationController.getNotificationIdFromPayload(webinarID);
      if (notificationId.isNotEmpty) {
        for (String id in notificationId) {
          notificationController.deleteNotification(id);
        }
      }
    }
    await firestore.collection('Webinar').doc(webinarID).update(dataToUpdate);
  }

  /// Removes webinar document and associated off the database
  Future<void> deleteWebinar(String webinarID) async {
    QuerySnapshot snap = await firestore
        .collection('Webinar')
        .doc(webinarID)
        .collection('comments')
        .get();

    for (int i = 0; i < snap.docs.length; i++) {
      await firestore
          .collection('Webinar')
          .doc(webinarID)
          .collection('comments')
          .doc(
            ((snap.docs[i].data()! as dynamic)['commentId']),
          )
          .delete();
    }
    await firestore.collection('Webinar').doc(webinarID).delete();
  }

  /// Returns all the comments found within a webinar
  Stream<QuerySnapshot<Map<String, dynamic>>> getChatStream(String webinarID) {
    return firestore
        .collection('Webinar')
        .doc(webinarID)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Returns all Live Webinars associated to a specific role type
  Stream<QuerySnapshot<Map<String, dynamic>>> getLiveWebinars(String roleType) {
    return firestore
        .collection('Webinar')
        .where('status', isEqualTo: 'Live')
        .where('selectedtags', arrayContains: roleType)
        .snapshots();
  }

  /// Returns all Upcoming Webinars associated to a specific role type
  Stream<QuerySnapshot<Map<String, dynamic>>> getUpcomingWebinars(
      String roleType) {
    return firestore
        .collection('Webinar')
        .where('status', isEqualTo: 'Upcoming')
        .where('selectedtags', arrayContains: roleType)
        .snapshots();
  }

  /// Returns all Archived Webinars associated to a specific role type
  Stream<QuerySnapshot<Map<String, dynamic>>> getArchivedWebinars(
      String roleType) {
    return firestore
        .collection('Webinar')
        .where('status', isEqualTo: 'Archived')
        .where('selectedtags', arrayContains: roleType)
        .snapshots();
  }

  Future<Livestream> getWebinar(String? id) async {
    DocumentSnapshot snapshot =
        await firestore.collection('Webinar').doc(id).get();

    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
    return Livestream.fromMap(snapshotData);
  }
}
