import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/topic_model.dart';
import 'package:info_hub_app/view/topic_view/topic_view.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Controller class responsible for managing the form data and actions in the topic creation process.
class MediaController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  Topic topic;

  TopicViewState screen;

  MediaController(
    this.auth,
    this.firestore,
    this.topic,
    this.screen,
  );

  VideoPlayerController? videoController;
  ChewieController? chewieController;
  String? videoURL;
  String? imageUrl;
  int currentIndex = 0;

  /// Initializes form data based on whether the form is for editing an existing topic or creating a new one.
  void initializeData() {
    initData(topic);
  }

  Future<void> initData(Topic currentTopic) async {
    if (currentTopic.media!.isNotEmpty) {
      if (currentTopic.media![currentIndex]['mediaType'] == 'video') {
        videoURL = currentTopic.media![currentIndex]['url'];
        imageUrl = null;

        await initializeVideoPlayer();
      } else {
        imageUrl = currentTopic.media![currentIndex]['url'];
        videoURL = null;
        await initializeImage();
      }
    }
  }

  Future<void> initializeVideoPlayer() async {
    bool isLoading = true; // Initialize isLoading to true

    isLoading = true;
    screen.updateState();

    if (isLoading) {
      const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    }

    _disposeVideoPlayer();

    if (videoURL != null && videoURL!.isNotEmpty) {
      videoController = VideoPlayerController.networkUrl(Uri.parse(videoURL!));

      await videoController!.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoInitialize: true,
        looping: false,
        aspectRatio: 16 / 9,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        allowedScreenSleep: false,
      );

      // Hide loading indicator after initialization

      isLoading = false;
      screen.updateState();
    }

    // Return loading indicator if isLoading is true
    if (isLoading) {
      const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    }
  }

  void _disposeVideoPlayer() {
    videoController?.pause();
    videoController?.dispose();
    videoController = null;

    chewieController?.pause();
    chewieController?.dispose();
    chewieController = null;
  }

  Future<void> initializeImage() async {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      screen.updateState();
    }
  }

  Future<void> deleteMediaFromStorage(int index) async {
    String fileUrl = topic.media![index]['url'];

    // get reference to the video file
    Reference ref = screen.widget.storage.refFromURL(fileUrl);

    // Delete the file
    await ref.delete();
  }
}
