import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class WebinarService {
  final FirebaseFirestore firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  WebinarService({required this.firestore});
    
  Future<String> startLiveStream(String title,String url, Uint8List? image,String name, String startTime) async {
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
    
    Reference ref = _storage.ref().child(childName).child(uid);
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
  Future<void> endLiveStream(String channelId) async {
    try {
      QuerySnapshot snap = await firestore
      .collection('Webinar')
      .doc(channelId)
      .collection('comments')
      .get();
      for (int i = 0; i < snap.docs.length; i++) {
        await firestore
        .collection('Webinar')
        .doc(channelId)
        .collection('comments')
        .doc(
          ((snap.docs[i].data()! as dynamic)['commentId']),
          ).delete();
      }
      await firestore.collection('Webinar').doc(channelId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

}
