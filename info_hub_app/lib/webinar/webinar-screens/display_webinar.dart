// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/helpers/dsplay_webinar_helper.dart';
import 'package:info_hub_app/webinar/webinar-screens/chat.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

// Displays base broadcasting screen
class WebinarScreen extends StatefulWidget {
  final String webinarID;
  final String youtubeURL;
  final UserModel currentUser;
  final FirebaseFirestore firestore;
  final String title;
  final WebinarService webinarService;
  final String status;

  const WebinarScreen({
    super.key,
    required this.webinarID,
    required this.youtubeURL,
    required this.currentUser,
    required this.firestore,
    required this.title,
    required this.webinarService,
    required this.status,
  });

  @override
  State<WebinarScreen> createState() => _WebinarScreenState();
}

class _WebinarScreenState extends State<WebinarScreen> {
  late YoutubePlayerController _controller;
  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  String? modifiedURL;
  final bool _isPlayerReady = false;
  List<String> participants = [];

  @override
  void initState() {
    super.initState();
    //set device orientations to be portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    participants.add(widget.currentUser.uid);
    // create youtube player
    modifiedURL = YoutubePlayer.convertUrlToId(widget.youtubeURL);
    _controller = YoutubePlayerController(
      initialVideoId: modifiedURL ?? '',
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        isLive: widget.status == "Live" ? true : false,
        forceHD: true,
        enableCaption: false,
        showLiveFullscreenButton: false,
      ),
    )..addListener(listener);
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;  
  }

  // stop the youtube player from playing and exit the channel, decrementing the Live statistics 
  @override
  void dispose() {
    _controller.pause();
    _leaveChannel();
    super.dispose();
  }

  // Listens on changes from the user side
  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  // initates leaving sequence. Decrements the total viewer count by 1
  _leaveChannel() async {
    participants.remove(widget.currentUser.uid);
    await widget.webinarService.updateViewCount(widget.webinarID, false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              DisplayWebinarHelper().showGuideDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: SizedBox(
              width: double.infinity,
              height: 210, 
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.redAccent,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "${participants.length} watching",
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Expanded(
            child: Chat(
              webinarID: widget.webinarID,
              user: widget.currentUser,
              firestore: widget.firestore,
              webinarService: widget.webinarService,
            ),
          ),
        ],
      ),
    );
  }


}

