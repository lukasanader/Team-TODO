import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/config/app_id.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/screens/webinar-screens/chat.dart';
import 'package:info_hub_app/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
// Displays base broadcasting screen
class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  final UserModel currentUser;
  final FirebaseFirestore firestore;
  final String title;

  const BroadcastScreen({
    super.key,
    required this.isBroadcaster,
    required this.channelId,
    required this.currentUser,
    required this.firestore,
    required this.title,
  });

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine = createAgoraRtcEngine();
  int localUid = 0;

  bool switchCamera = true;
  bool isMuted = false;
  List<int> userUIDs = [];

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  // initialises broadcasting engine according to user privelleges
  void _initEngine() async {
    await [Permission.microphone, Permission.camera].request();
    await _engine.initialize(const RtcEngineContext(
      appId: appID,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    if (widget.isBroadcaster) {
      _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    } else {
      _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
    await _engine.enableVideo();
    _addListeners();

    await _engine.joinChannelWithUserAccount(token: tempToken, channelId: widget.channelId, userAccount: widget.currentUser.uid);
    // joinChannel(
    //   token: tempToken,
    //   channelId: widget.channelId,
    //   uid: 0,
    //   options: const ChannelMediaOptions(),
    // );
    await _engine.startPreview();
  }

  // establishes events and how to handle them
  void _addListeners() {
    _engine.registerEventHandler(RtcEngineEventHandler(
      // local user
      onJoinChannelSuccess: (channel, uid) {
        debugPrint('joinChannelSuccess $channel $uid ');
      },
      // remote user
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint('userJoined $connection $remoteUid $elapsed');
        setState(() {
          userUIDs.add(remoteUid);
        });
      },
      onUserOffline: (connection, remoteUid, reason) {
        debugPrint('userOffline $connection $remoteUid $reason');
        setState(() {
          userUIDs.removeWhere((element) => element == remoteUid);
        });
      },
      onLeaveChannel: (connection, stats) {
        debugPrint('leaveChannel $stats');
        setState(() {
          userUIDs.clear();
        });
      },
    ));
  }

  // allows for the ability for webinar lead to switch camera
  void _switchCamera() {
    if (widget.isBroadcaster) {
      _engine.switchCamera().then((value) {
        setState(() {
          switchCamera = !switchCamera;
        });
      }).catchError((err) {
        debugPrint('switchCamera $err');
      });
    }
  }


  // allows for the ability for webinar lead to toggle their microphone on and off
  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  /* initates leaving sequence. If user is webinar lead, the stream is ended and everybody is removed
  If they are merely a member watching, they will exit the screen
  */
  _leaveChannel() async {
    await _engine.leaveChannel();
    await _engine.release();
    if (widget.currentUser.uid == widget.channelId) {
      await DatabaseService(firestore: widget.firestore, uid: widget.currentUser.uid).endLiveStream(widget.channelId);
    } else {
      await DatabaseService(firestore: widget.firestore, uid: widget.currentUser.uid).updateViewCount(widget.channelId, false);
    }
  }

  void _showGuideDialog() {
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
                Navigator.of(context).pop(); // Close the dialog
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
    // removes the entirety of the screen from the scope
    return PopScope(
      onPopInvoked: (didPop) async {
        await _leaveChannel();
        // ignore: void_checks
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                _showGuideDialog();
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 300,
                  height: 250,
                  child: Center(
                    child: 
                    AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.currentUser.uid == widget.channelId)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: _switchCamera,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Text(
                        'Switch Camera',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  //  Toggle mute button
                  InkWell(
                    onTap: onToggleMute,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isMuted ? Colors.grey : Colors.red,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        isMuted ? 'Unmute' : 'Mute',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _leaveChannel,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Text(
                        'End Webinar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: Chat(
                channelId: widget.channelId,
                user: widget.currentUser,
                firestore: widget.firestore,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
