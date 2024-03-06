import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final String uid;
  final FirebaseFirestore firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DatabaseService({required this.uid, required this.firestore});

  // adds user data to database
  Future addUserData(String firstName, String lastName,String email,String roleType) async {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    return await usersCollectionRef.add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
    });
  }
    
  Future<String> startLiveStream(BuildContext context, String title, Uint8List? image, String lastName) async {
    String channelId = '';
    try {
      if (title.isNotEmpty && image != null) {
        CollectionReference webinarRef = firestore.collection('Webinar');
        bool uidExists = await checkUidExists(uid);
        if (!uidExists) {
          String thumbnailUrl = await uploadImageToStorage('webinar-thumbnails', image, uid);

          DocumentReference docRef = webinarRef.doc(uid);

          await docRef.set({
            'title': title,
            'thumbnail': thumbnailUrl,
            'uid': uid,
            'webinarleadlname' : lastName,
            'views': 0,
          });

          channelId = uid;
        } else {
          print('You cannot start a stream if you already have one');
        }
      } else {
        print('Error');
      }
    } catch (e) {
      print(e);
    }
    return channelId;
  }


  Future<bool> checkUidExists(String uid) async {
    try {
      CollectionReference webinarRef = firestore.collection('Webinar');
      QuerySnapshot querySnapshot = await webinarRef.where('uid', isEqualTo: uid).get();

      // If there are documents in the query result, it means the uid already exists
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Handle any errors during the query
      print('Error checking uid existence: $e');
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
      await firestore.collection('webinar').doc(id).update({
        'views': FieldValue.increment(isIncrease? 1: -1),
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> chat(String text, String id,String roleType) async {
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
        'uid' : uid,

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
