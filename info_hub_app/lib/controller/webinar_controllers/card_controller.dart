import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/model/user_models/user_model.dart';
import 'package:info_hub_app/model/livestream_models/livestream_model.dart';
import 'package:info_hub_app/controller/webinar_controllers/webinar_controller.dart';
import 'package:info_hub_app/view/webinar_view/webinar-screens/display_webinar.dart';

/// Handles back-end logic for webinar cards
class CardController {
  final WebinarController webinarController;
  final FirebaseFirestore firestore;

  CardController({
    required this.webinarController,
    required this.firestore,
  });

  /// Handles the tap gesture on a card
  Future<String> handleTap(BuildContext context, Livestream post, UserModel user) async {
    if (post.status == "Upcoming") {
      return "Upcoming";
    } else {
      // if live or archived redirect to watch screen and increment view counter
      await webinarController.updateViewCount(post.webinarID, true);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WebinarScreen(
            webinarID: post.webinarID,
            youtubeURL: post.youtubeURL,
            currentUser: user,
            firestore: firestore,
            title: post.title,
            webinarController: webinarController,
            status: post.status,
            chatEnabled: post.chatEnabled,
          ),
        ),
      );
      return "";
    }
  }

  /// validates url into expected formats and sets these changes into database
  Future<bool> validateCardLogic(Livestream post,String url) async {
    final RegExp regex = RegExp(
      r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube(-nocookie)?\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|live\/|v\/)?)([\w\-]+)(\S+)?$');
    if (regex.hasMatch(url)) {
      await webinarController.setWebinarStatus(
          post.webinarID, url,
          changeToArchived: true);
          return true;
    }
    return false;
  }

  /// Calls the webinar conrtroller to delete the webinar
  void deleteWebinar(String webinarID) {
    webinarController.deleteWebinar(webinarID);
  }

}
