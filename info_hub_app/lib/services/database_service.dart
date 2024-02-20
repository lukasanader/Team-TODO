import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/models/livestream.dart';

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
  
  Future<String> startLiveStream(BuildContext context, String title, Uint8List? image) async {
    String channelId = '';
    try {
      if (title.isNotEmpty && image != null) {
        CollectionReference webinarRef = firestore.collection('Webinar');
        bool uidExists = await await checkUidExists(uid);
        if (!uidExists) {
          String thumbnailUrl = await uploadImageToStorage('webinar-thumbnails', image,uid);
          webinarRef.add( {
            'title' : title,
            'thumbnail': thumbnailUrl,
            'uid': uid,
          });
          channelId = uid;
          } else {
            print('You can not start a stream if you already have one');
          }
        } else {
          print('Error');
        }
   } catch(e) {
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
    // Create a temporary file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.jpg');
    
    // Write the Uint8List data to the file
    await tempFile.writeAsBytes(file);

    // Create a reference to the storage path
    Reference ref = _storage.ref().child(childName).child(uid);

    // Upload the file to Firebase Storage
    UploadTask uploadTask = ref.putFile(tempFile);

    // Wait for the upload to complete
    TaskSnapshot snapshot = await uploadTask;

    // Get the download URL of the uploaded file
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // Delete the temporary file
    await tempFile.delete();

    return downloadUrl;
  }



}
