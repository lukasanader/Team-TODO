import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class WebinarService {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  WebinarService({required this.firestore, required this.storage});
    
  Future<String> startLiveStream(String title,String url, Uint8List? image,String name, String startTime, String streamStatus) async {
    // assign random integer as document name
    String collectionId = (Random().nextInt(4294967296) + 100000).toString();
    try {
      if (title.isNotEmpty && image != null) {
        // check if any document already exists with the set url or with the random id
        CollectionReference webinarRef = firestore.collection('Webinar');
        bool idExists = await checkURLExists(webinarRef, collectionId);
        bool webinarExists = await checkURLExists(webinarRef, url);
        if (!webinarExists && !idExists) {

          String thumbnailUrl = await uploadImageToStorage('webinar-thumbnails', image, collectionId);

          DocumentReference docRef = webinarRef.doc(collectionId);

          await docRef.set({
            'id': collectionId,
            'title': title,
            'url': url,
            'thumbnail': thumbnailUrl,
            'webinarleadname' : name,
            'startTime' : startTime,
            'views': 0,
            'dateStarted' : startTime,
            'status': streamStatus,
          });

        } else {
          return "";
        }
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
    return collectionId;
  }

  Future<bool> checkURLExists(CollectionReference ref, String url) async {
    try {
      QuerySnapshot querySnapshot = await ref.where('url', isEqualTo: url).get();
      // If there are documents in the query result, it means the uid already exists
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle any errors during the query
      if (kDebugMode) {
        print('Error checking uid existence: $e');
      }
      return false;
    }
  }

  Future<bool> checkRandomNumberExists(CollectionReference ref, String id) async {
    try {
      DocumentSnapshot docSnapshot = await ref.doc(id).get();
      // If there are documents in the query result, it means the uid already exists
      return docSnapshot.exists;
    } catch (e) {
      // Handle any errors during the query
      if (kDebugMode) {
        print('Error checking document existence: $e');
      }
      return false;
    }
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file, String uid) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.jpg');

    await tempFile.writeAsBytes(file);
    
    Reference ref = storage.ref().child(childName).child(uid);
    UploadTask uploadTask = ref.putFile(tempFile);
    
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    await tempFile.delete();
    return downloadUrl;
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try {
      await firestore.collection('Webinar').doc(id).update({
        'views': FieldValue.increment(isIncrease? 1: -1),
        
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> chat(String text, String id,String roleType,String userID) async {
    try {
      String commentId = const Uuid().v1();
      await firestore.collection('Webinar')
      .doc(id)
      .collection('comments')
      .doc(commentId)
      .set({
        'message' : text,
        'createdAt' : DateTime.now(),
        'commentId' : commentId,
        'roleType' : roleType,
        'uid' : userID,

      });

    } on FirebaseException catch(e) {
      debugPrint(e.toString());
    }
  }

  Future<String> getNumberOfLiveWebinars() async {
    QuerySnapshot snap = await firestore
      .collection('Webinar')
      .where('status', isEqualTo: "Live")
      .get();
    return snap.docs.length.toString();
  }

  Future<String> getNumberOfUpcomingWebinars() async {
    QuerySnapshot snap = await firestore
      .collection('Webinar')
      .where('status', isEqualTo: "Upcoming")
      .get();
    return snap.docs.length.toString();
  }

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

  Future<String> getNumberOfArchivedWebinars() async {
    QuerySnapshot snap = await firestore
      .collection('Webinar')
      .where('status', isEqualTo: "Archived")
      .get();
    return snap.docs.length.toString();
  }

  Future<void> setWebinarStatus(String webinarID, String url, {bool changeToLive = false, changeToArchived = false}) async {
    Map<String, dynamic> dataToUpdate = {
      'url': url,
    };

    if (changeToLive) {
      dataToUpdate['status'] = "Live";
    } else if (changeToArchived) {
      dataToUpdate['status'] = "Archived";
    }

    await firestore.collection('Webinar').doc(webinarID).update(dataToUpdate);
  }
}
