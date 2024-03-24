import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/display_webinar.dart';

class CardController {
  final WebinarService webinarService;
  final FirebaseFirestore firestore;

  CardController({
    required this.webinarService,
    required this.firestore,
  });

  Future<String> handleTap(BuildContext context, Livestream post, UserModel user) async {
    if (post.status == "Upcoming") {
      return "Upcoming";
    } else {
      // if live or archived redirect to watch screen and increment view counter
      await webinarService.updateViewCount(post.webinarID, true);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebinarScreen(
            webinarID: post.webinarID,
            youtubeURL: post.youtubeURL,
            currentUser: user,
            firestore: firestore,
            title: post.title,
            webinarService: webinarService,
            status: post.status,
            chatEnabled: post.chatEnabled,
          ),
        ),
      );
      return "";
    }
  }

  // validates url into expected formats and sets these changes into database
  Future<bool> validateCardLogic(Livestream post,String url) async {
    final RegExp regex = RegExp(
      r'https:\/\/(?:www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)|https:\/\/youtu\.be\/([a-zA-Z0-9_-]+)');
    if (regex.hasMatch(url)) {
      await webinarService.setWebinarStatus(
          post.webinarID, url,
          changeToArchived: true);
          return true;
    }
    return false;
  }

  void deleteWebinar(String webinarID) {
    webinarService.deleteWebinar(webinarID);
  }

}
