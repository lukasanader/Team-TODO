import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/config/app_id.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:permission_handler/permission_handler.dart';

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  final UserModel currentUser;
  const BroadcastScreen({Key? key, required this.isBroadcaster, required this.channelId, required this.currentUser}) :super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  int? _remoteUid;
  List<int> userUIDs = [];

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  void _initEngine() async {
    await [Permission.microphone, Permission.camera].request();
    _engine =  createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appID,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
    _addListeners();
    
    if (widget.isBroadcaster) {
      _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    } else {
      _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
    await _engine.enableVideo();
    await _engine.startPreview();
    // await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

    await _engine.joinChannel(
      token: tempToken,
      channelId: 'howdoesthiswork',
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void _addListeners() {
    _engine.registerEventHandler(RtcEngineEventHandler(

      onJoinChannelSuccess:(channel, uid) {
        debugPrint('joinChannelSuccess $channel $uid ');
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint('userJoined $connection $remoteUid $elapsed');
        setState(() {
            _remoteUid = remoteUid;
        }); 
      },
      onUserOffline:(connection, remoteUid, reason) {
        debugPrint('userOffline $connection $remoteUid $reason');
        setState(() {
          userUIDs.removeWhere((element) => element == remoteUid);
        });
      },
      onLeaveChannel:(connection, stats) {
        debugPrint('leaveChannel $stats');
        setState(() {
          userUIDs.clear();
        });
      },
    ));
  }

  // void _joinChannel() async {
  //   if (defaultTargetPlatform == TargetPlatform.android) {
  //     await [Permission.microphone, Permission.camera].request();
  //   }
  //   await _engine.joinChannelWithUserAccount(token: tempToken, channelId: 'howdoesthiswork', userAccount: widget.currentUser.uid);
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currentUser.firstName}\'s Webinar'),
      ),
      body: Stack(
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
                        )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  // Widget _renderVideo() {
  //   return AgoraVideoView(
  //       controller: VideoViewController(
  //         rtcEngine: _engine,
  //         canvas: VideoCanvas(uid: _remoteUid),
  //       )
  //     );
  //   }
    //  else {
    //     return const Text(
    //       'Please wait for remote user to join',
    //       textAlign: TextAlign.center,
    //     );

    //   aspectRatio: 16 / 9,
    //   child: "${user.uid}" == widget.channelId
    //       ? 
    //       RtcLocalView.SurfaceView(
    //           zOrderMediaOverlay: true,
    //           zOrderOnTop: true,
    //         )
    //       : remoteUid.isNotEmpty
    //           ? kIsWeb
    //               ? RtcRemoteView.SurfaceView(
    //                   uid: remoteUid[0],
    //                   channelId: widget.channelId,
    //                 )
    //               : RtcRemoteView.TextureView(
    //                   uid: remoteUid[0],
    //                   channelId: widget.channelId,
    //                 )
    //           : Container(), // Add a default widget when remoteUid is empty
    // )

}