import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/config/app_id.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/screens/random_screen.dart';
import 'package:info_hub_app/screens/webinar-screens/chat.dart';
import 'package:info_hub_app/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  final UserModel currentUser;
  final FirebaseFirestore firestore;

  const BroadcastScreen({
    Key? key,
    required this.isBroadcaster,
    required this.channelId,
    required this.currentUser,
    required this.firestore,
  }) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine = createAgoraRtcEngine();
  bool switchCamera = true;
  bool isMuted = false;
  int? _remoteUid;
  List<int> userUIDs = [];

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  void _initEngine() async {
    int userUID = 1;
    await [Permission.microphone, Permission.camera].request();
    await _engine.initialize(const RtcEngineContext(
      appId: appID,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    _addListeners();

    if (widget.isBroadcaster) {
      _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      userUID = 0;
    } else {
      _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: tempToken,
      channelId: 'howdoesthiswork',
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void _addListeners() {
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (channel, uid) {
        debugPrint('joinChannelSuccess $channel $uid ');
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint('userJoined $connection $remoteUid $elapsed');
        setState(() {
          _remoteUid = remoteUid;
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

  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

_leaveChannel() async {
  await _engine.leaveChannel();

  if (widget.currentUser.uid == widget.channelId) {
    await DatabaseService(firestore: widget.firestore, uid: widget.currentUser.uid).endLiveStream(widget.channelId);
  } else {
    await DatabaseService(firestore: widget.firestore, uid: widget.currentUser.uid).updateViewCount(widget.channelId, false);
  }

  if (mounted) { // Check if the widget is still mounted before navigation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RandomScreen(),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.currentUser.firstName}\'s Webinar'),
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
                    child: AgoraVideoView(
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
                      padding: EdgeInsets.all(12.0),
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.red, // Set button background color
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Text(
                        'Switch',
                        style: TextStyle(
                          color: Colors.white, // Set text color
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onToggleMute,
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isMuted ? Colors.grey : Colors.red, // Set button background color
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        isMuted ? 'Unmute' : 'Mute',
                        style: TextStyle(
                          color: Colors.white, // Set text color
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
