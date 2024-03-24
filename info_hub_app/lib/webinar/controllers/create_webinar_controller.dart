import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/display_webinar.dart';
import 'package:intl/intl.dart';

class CreateWebinarController {
  final WebinarService webinarService;
  final FirebaseFirestore firestore;
  final UserModel user;
  
  CreateWebinarController({
    required this.webinarService,
    required this.firestore,
    required this.user,
  });

  // validates URL entered by user
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


  // Handles image picking for webinar thumbmnail
  Future<Uint8List?> pickImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(type: FileType.image);
    if (pickedImage != null) {
      return await File(pickedImage.files.single.path!).readAsBytes();
    }
    return null;
  }

  Future<void> goLiveWebinar(BuildContext context,
    DateTime? time,
    FormState? state, 
    String title,
    String url,
    Uint8List? image,
    List<String> selectedTags,
    {bool isScheduled = false}) async {
      if (state!.validate()) {
        time ??= DateTime.now();
        String statusText = isScheduled ? 'Upcoming' : 'Live';
        final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm', 'en_GB');
        String webinarID = await webinarService.startLiveStream(
            title,
            url,
            image,
            ("${user.firstName} ${user.lastName}"),
            formatter.format(time).toString(),
            statusText,
            selectedTags);
        if (webinarID.isNotEmpty) {
          if (!isScheduled) {
            webinarService.updateViewCount(webinarID, true);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WebinarScreen(
                    webinarID: webinarID,
                    youtubeURL: url,
                    currentUser: user,
                    firestore: firestore,
                    title: title,
                    webinarService: webinarService,
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
  
}