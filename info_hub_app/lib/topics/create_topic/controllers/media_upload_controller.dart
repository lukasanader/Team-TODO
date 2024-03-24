import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;
import '../model/topic_model.dart';
import '../controllers/form_controller.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';

/// Controller class responsible for managing media upload operations.
class MediaUploadController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  FormController formController;

  CreateTopicScreenState screen;

  MediaUploadController(this.auth, this.firestore, this.storage,
      this.formController, this.screen);

  String? videoURL;
  String? imageURL;
  List<Map<String, dynamic>> mediaUrls = [];
  List<Map<String, dynamic>> originalUrls = [];
  List<dynamic> networkUrls = [];
  Topic? topic;
  Topic? draft;
  bool changingMedia = false;
  VideoPlayerController? videoController;
  ChewieController? chewieController;

  // Initializes the media data based on whether the form is for editing a topic or creating a new one from a draft.
  void initializeData() {
    topic = formController.topic;
    draft = formController.draft;
    if (formController.editing) {
      mediaUrls = [...formController.topic!.media!];
      originalUrls = [...mediaUrls];
      List<dynamic> tempUrls = [];
      for (var item in mediaUrls) {
        tempUrls.add(item['url']);
      }
      networkUrls = [...tempUrls];
      initializeUrls();
    } else if (formController.drafting) {
      mediaUrls = [...draft!.media!];
      originalUrls = [...mediaUrls];
      List<dynamic> tempUrls = [];
      for (var item in mediaUrls) {
        tempUrls.add(item['url']);
      }
      networkUrls = [...tempUrls];
      initializeUrls();
    }
  }

  /// Initializes the URLs for the media files.
  Future<void> initializeUrls() async {
    topic = formController.topic;
    draft = formController.draft;

    List<dynamic> mediaData = topic != null ? topic!.media! : draft!.media!;
    if (mediaData.isNotEmpty) {
      if (mediaData[screen.currentIndex]['mediaType']! == 'video') {
        videoURL = mediaData[screen.currentIndex]['url']!;
        imageURL = null;

        await initializeVideoPlayer();
      } else {
        imageURL = mediaData[screen.currentIndex]['url']!;
        videoURL = null;
        await initializeImage();
      }
    }
  }

  /// Picks media files from the device.
  Future<void> pickFromDevice(String type) async {
    List<String> extensions = type == "image"
        ? ['jpg', 'jpeg', 'png']
        : ['mp4', 'mov', 'avi', 'mkv', 'wmv'];

    FilePickerResult? result = screen.widget.selectedFiles == null
        ? await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: extensions,
            allowMultiple: !changingMedia,
          )
        : null;

    if (result != null) {
      await handleNavigation(result, null, type);
    } else {
      await handleNavigation(null, screen.widget.selectedFiles, type);
    }
  }

  /// Handles navigation after picking media files.
  Future<void> handleNavigation(FilePickerResult? result,
      List<PlatformFile>? selection, String type) async {
    List<PlatformFile>? data =
        result != null && result.files.isNotEmpty ? result.files : selection;
    if (data != null) {
      for (PlatformFile file in filterFiles(data, type)) {
        String mediaPath = file.path!;

        imageURL = type == 'image' ? mediaPath : null;
        videoURL = type == 'video' ? mediaPath : null;
        Map<String, String> fileInfo = {
          'url': mediaPath,
          'mediaType': type,
        };
        if (!changingMedia) {
          mediaUrls.add(fileInfo);
          screen.currentIndex = mediaUrls.length - 1;
        } else {
          mediaUrls[screen.currentIndex] = fileInfo;
        }
        if (type == "image") {
          videoURL = null;
        } else {
          imageURL = null;
        }
        screen.updateState();
      }
    }
    if (data != null && data.isNotEmpty) {
      if (type == 'image') {
        await initializeImage();
      } else {
        await initializeVideoPlayer();
      }
    }
  }

  /// Filters picked files based on their type (image or video)
  List<PlatformFile> filterFiles(List<PlatformFile> files, String type) {
    return files.where((file) {
      // Get the file extension
      String extension = path.extension(file.path!).toLowerCase();

      // Check if the extension is for an image file
      if (type == "image") {
        return extension == '.jpg' ||
            extension == '.jpeg' ||
            extension == '.png';
      } else {
        return extension == '.mp4' ||
            extension == '.mov' ||
            extension == '.avi' ||
            extension == '.mkv' ||
            extension == '.wmv' ||
            extension == '.flv';
      }
    }).toList();
  }

  /// Clears the media file currenly on screen.
  void clearSelection() {
    List<Map<String, dynamic>> oldMediaUrls = [...mediaUrls];

    if (mediaUrls[screen.currentIndex]['mediaType'] == 'video') {
      disposeVideoPlayer();
    }
    if (mediaUrls.length == 1) {
      screen.currentIndex = 0;
      screen.updateState();
    }
    mediaUrls.removeAt(screen.currentIndex);
    if (mediaUrls.isNotEmpty) {
      if (screen.currentIndex - 1 >= 0) {
        screen.currentIndex -= 1;
        screen.updateState();
      } else {
        screen.currentIndex += 1;
        screen.updateState();
      }
      if (oldMediaUrls[screen.currentIndex]['mediaType'] == 'video') {
        videoURL = oldMediaUrls[screen.currentIndex]['url'];

        imageURL = null;
        screen.updateState;
        initializeVideoPlayer();
        screen.updateState();
      } else if (oldMediaUrls[screen.currentIndex]['mediaType'] == 'image') {
        imageURL = oldMediaUrls[screen.currentIndex]['url'];
        videoURL = null;
        screen.updateState;
        initializeImage();

        screen.updateState();
      }
      if (mediaUrls.length == 1) {
        screen.currentIndex = 0;
        screen.updateState();
      }
    } else {
      if (oldMediaUrls[screen.currentIndex]['mediaType'] == 'video') {
        videoURL = null;
      } else {
        imageURL = null;
      }
      screen.updateState();
    }
  }

  /// Uploads a media file to Firebase Storage.
  Future<String> uploadMediaToStorage(String url) async {
    Reference ref = storage.ref().child('media/${basename(url)}');
    await ref.putFile(File(url));
    return await ref.getDownloadURL();
  }

  /// Deletes a media file from Firebase Storage.
  Future<void> deleteMediaFromStorage(String url) async {
    // get reference to the file
    Reference ref = storage.refFromURL(url);

    // Delete the file
    await ref.delete();
  }

  /// Initializes the video player.
  Future<void> initializeVideoPlayer() async {
    disposeVideoPlayer();
    if (videoURL != null && videoURL!.isNotEmpty) {
      if (!networkUrls.contains(videoURL)) {
        videoController = VideoPlayerController.file(File(videoURL!));
      } else {
        videoController =
            VideoPlayerController.networkUrl(Uri.parse(videoURL!));
      }

      await videoController!.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoInitialize: true,
        looping: false,
        aspectRatio: 16 / 9,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        allowedScreenSleep: false,
      );
      screen.updateState();
    }
  }

  /// Disposes the current video player.
  void disposeVideoPlayer() {
    videoController?.pause();
    videoController?.dispose();
    videoController = null;

    chewieController?.pause();
    chewieController?.dispose();
    chewieController = null;
  }

  // Initialize image by forcing screen refresh with up-to-date image url
  Future<void> initializeImage() async {
    if (imageURL != null && imageURL!.isNotEmpty) {
      screen.updateState();
    }
  }
}
