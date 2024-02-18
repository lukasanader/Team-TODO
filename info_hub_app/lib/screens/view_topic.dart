import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class ViewTopicScreen extends StatefulWidget {
  final QueryDocumentSnapshot topic;

  const ViewTopicScreen({required this.topic, Key? key}) : super(key: key);

  @override
  State<ViewTopicScreen> createState() => _ViewTopicScreenState();
}

class _ViewTopicScreenState extends State<ViewTopicScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool vidAvailable = false;

  @override
  void initState() {
    super.initState();
    if (widget.topic['videoUrl'] != null && widget.topic['videoUrl'] != "") {
      _initializeVideoPlayer();
      vidAvailable = true;
    }
  }

  void _initializeVideoPlayer() async {
    final videoUrl = widget.topic['videoUrl'] as String?;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoInitialize: true,
        looping: false,
        aspectRatio: 16 / 9,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        allowedScreenSleep: false,
      );
      _chewieController!.addListener(() {
        if (!_chewieController!.isFullScreen) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        }
      });

      // Ensure that the video player controller is updated
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(200, 0, 0, 1.0),
        title: Text(
          widget.topic['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vidAvailable && _chewieController != null)
              SizedBox(
                height: 250,
                child: Chewie(controller: _chewieController!),
              ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.topic['description']}',
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (widget.topic['articleLink'] != '')
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse(widget.topic['articleLink']));
                  },
                  child: const Text('Read Article'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
