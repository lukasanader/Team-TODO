import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class ViewTopicScreen extends StatefulWidget {
  final Map<String, dynamic> topic;

  const ViewTopicScreen({required this.topic, Key? key}) : super(key: key);

  @override
  State<ViewTopicScreen> createState() => _ViewTopicScreenState();
}

class _ViewTopicScreenState extends State<ViewTopicScreen> {
  late VideoPlayerController? _controller;
  late Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.topic['videoUrl'] != null && widget.topic['videoUrl'] != "") {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.topic['videoUrl']),
      );
      _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
        _controller!.pause();
      });
    } else {
      _controller = null;
      _initializeVideoPlayerFuture = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(200, 0, 0, 1.0),
        title: Text(widget.topic['title'],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            if (_controller != null)
              FutureBuilder<void>(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller!),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_controller!.value.isPlaying) {
                                  _controller!.pause();
                                } else {
                                  _controller!.play();
                                }
                              });
                            },
                            icon: Icon(
                              _controller!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            const SizedBox(height: 30),
            Text(
              '${widget.topic['description']}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 30),
            if (widget.topic['articleLink'] != '')
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse(widget.topic['articleLink']));
                  },
                  child: const Text('Read Article'),
                ),
              )
          ],
        ),
      ),
    );
  }
}
