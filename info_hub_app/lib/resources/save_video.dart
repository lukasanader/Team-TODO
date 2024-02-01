import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

final FirebaseStorage _storage = FirebaseStorage.instance;

class StoreData {
  Future<String> uploadVideo(String videoUrl) async {
    Reference ref = _storage.ref().child('videos/${DateTime.now()}.mp4');
    await ref.putFile(File(videoUrl));
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }
}
