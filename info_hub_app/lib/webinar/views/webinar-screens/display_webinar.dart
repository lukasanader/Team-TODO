import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/chat.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

// Displays webinar view screen alongside the respective chat for this webinar
class WebinarScreen extends StatefulWidget {
  final String webinarID;
  final String youtubeURL;
  final UserModel currentUser;
  final FirebaseFirestore firestore;
  final String title;
  final WebinarService webinarService;
  final String status;
  final bool chatEnabled;

  const WebinarScreen({
    super.key,
    required this.webinarID,
    required this.youtubeURL,
    required this.currentUser,
    required this.firestore,
    required this.title,
    required this.webinarService,
    required this.status,
    required this.chatEnabled,
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

  
  // Displays the guide dialog explaining the expectations of those participating in the webinar
  void showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Webinar Guide and Expectations'),
          content: const SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'What to expect from the webinar lead\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Our webinar leads are esteemed experts with advanced education and extensive training in their respective fields. '
                  'They are rich sources of valuable information and are always ready to assist you. Whether you have questions about the presentation '
                  'or seek additional insights, feel free to utilize the message box in order to communicate with the webinar lead.\n\n'
                  
                  'We understand that your queries are important, and the webinar lead will make every effort to respond promptly. '
                  'Please bear in mind that due to the high volume of questions, a brief delay may occur. Your patience is greatly appreciated, '
                  'and rest assured, the webinar lead is committed to providing thorough and helpful answers to enhance your webinar experience. '
                  'Thank you for your understanding and engagement during this interactive session.\n',
                  style: TextStyle(fontSize: 13.0),
                ),
                Text(
                  'What we expect from those watching\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'In our collaborative pursuit of knowledge, let\'s ensure a welcoming and respectful environment for all attendees. '
                  'Please observe the following behaviour expectations:\n\n'
                  '• Refrain from using foul language.\n'
                  '• Avoid disclosing personal identifiers in your messages.\n'
                  '• Prioritize respectful communication with fellow participants.\n\n'
                  
                  'Your cooperation in upholding these expectations contributes to an inclusive and positive webinar experience. '
                  'Thank you for being mindful of your behavior and actively participating in creating a conducive learning environment.',
                  style: TextStyle(fontSize: 13.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
              showGuideDialog(context);
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
              chatEnabled: widget.chatEnabled,
            ),
          ),
        ],
      ),
    );
  }


}

