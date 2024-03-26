import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/controllers/webinar_controller.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/display_webinar.dart';
import 'package:intl/intl.dart';

/// Controls backend logic for the create webinar screen
class CreateWebinarController {
  final WebinarController webinarController;
  final FirebaseFirestore firestore;
  final UserModel user;
  
  CreateWebinarController({
    required this.webinarController,
    required this.firestore,
    required this.user,
  });

  /// validates URL entered by user
  String? validateUrl(String? url) {
    final RegExp youtubeUrlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)(\?feature=shared)?$',
    );
    final RegExp youtubeLiveUrlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?youtube\.com\/live\/([a-zA-Z0-9_-]+)',
    );

    if (url == null || url.isEmpty) {
      return 'URL is required';
    }

    if (!youtubeUrlRegex.hasMatch(url) && !youtubeLiveUrlRegex.hasMatch(url)) {
      return 'Enter a valid YouTube video URL';
    }

    return null;
  }


  /// Handles image picking for webinar thumbmnail
  Future<Uint8List?> pickImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(type: FileType.image);
    if (pickedImage != null) {
      return await File(pickedImage.files.single.path!).readAsBytes();
    }
    return null;
  }

  /// Routes user to new screen
  Future<void> goLiveWebinar(BuildContext context, DateTime? time, FormState? state, String title,
                            String url, Uint8List? image, List<String> selectedTags,{bool isScheduled = false}) 
    async {
      if (state!.validate()) {
        // if data is valid, begin uploading webinar information to database
        time ??= DateTime.now();
        String statusText = isScheduled ? 'Upcoming' : 'Live';
        final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm', 'en_GB');
        String webinarID = await webinarController.startLiveStream(
            title,
            url,
            image,
            ("${user.firstName} ${user.lastName}"),
            formatter.format(time).toString(),
            statusText,
            selectedTags);
        if (webinarID.isNotEmpty) {
          // if not scheduled, push admin to screen where webinar is present
          if (!isScheduled) {
            webinarController.updateViewCount(webinarID, true);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WebinarScreen(
                    webinarID: webinarID,
                    youtubeURL: url,
                    currentUser: user,
                    firestore: firestore,
                    title: title,
                    webinarController: webinarController,
                    status: statusText,
                    chatEnabled: true,
                  ),
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A webinar with this URL may already exist. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
  }

  /// Builds the dialog for how to setup a webinar
  Widget buildStep({required int stepNumber, required String stepDescription}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepNumber. ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(stepDescription),
          ),
        ],
      ),
    );
  }

  /// Checks if any role has been selected for the webinar
  bool isAnyRoleSelected(bool isPatientSelected, bool isParentSelected,bool isHealthcareProfessionalSelected) {
    return isPatientSelected || isParentSelected || isHealthcareProfessionalSelected;
  }

  /// Sets the adequate tags to be displayed
  List<String> populateTags(bool isPatientSelected, bool isParentSelected,bool isHealthcareProfessionalSelected) {
    List<String> selectedTags = [];
    if (isPatientSelected) {
      selectedTags.add('Patient');
    }
    if (isParentSelected) {
      selectedTags.add('Parent');
    }
    if (isHealthcareProfessionalSelected) {
      selectedTags.add('Healthcare Professional');
    }
    selectedTags.add('admin'); // admin must always be a tag
    return selectedTags;
  }
  
  /// Returns error message
  void showThumbnailAndRoleError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please check if you have uploaded a thumbnail or selected a role.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

}