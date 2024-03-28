import 'package:flutter/material.dart';
import 'package:info_hub_app/view/topic_view/topic_view.dart';
import 'package:chewie/chewie.dart';
import '../../../controller/topic_view_controllers/media_controller.dart';
import 'package:info_hub_app/model/topic_models/topic_model.dart';

/// Widget for displaying Media Previews and navigation buttons
class ViewMediaWidget extends StatelessWidget {
  final TopicViewState screen;
  final MediaController mediaController;
  final Topic topic;

  const ViewMediaWidget(
      {super.key,
      required this.screen,
      required this.topic,
      required this.mediaController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display video preview if video URL is not null and Chewie controller has been initialized
        if (mediaController.videoURL != null &&
            mediaController.chewieController != null)
          videoPreviewWidget(),
        // Display image preview if image URL is not null
        if (mediaController.imageUrl != null) imagePreviewWidget(),
        if (mediaController.videoURL != null ||
            mediaController.imageUrl != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Button to navigate to previous media if it exists
              if (topic.media!.length > 1)
                IconButton(
                  key: const Key('previousMediaButton'),
                  icon: const Icon(Icons.arrow_circle_left_rounded,
                      color: Color.fromRGBO(150, 100, 200, 1.0)),
                  onPressed: () async {
                    if (mediaController.currentIndex - 1 >= 0) {
                      mediaController.currentIndex -= 1;
                      _updateMedia(mediaController.currentIndex);
                    }
                  },
                  tooltip: 'Previous Video',
                ),
              // Button to navigate to next media if it exists
              if (topic.media!.length > 1)
                IconButton(
                  key: const Key('nextMediaButton'),
                  icon: const Icon(Icons.arrow_circle_right_rounded,
                      color: Color.fromRGBO(150, 100, 200, 1.0)),
                  onPressed: () async {
                    if (mediaController.currentIndex + 1 <
                        topic.media!.length) {
                      mediaController.currentIndex += 1;
                      _updateMedia(mediaController.currentIndex);
                    }
                  },
                  tooltip: 'Next Video',
                ),
            ],
          ),
      ],
    );
  }

  /// Updates the media to be displayed based on the provided index.
  void _updateMedia(int index) async {
    if (topic.media![index]['mediaType'] == 'video') {
      mediaController.videoURL = topic.media![index]['url'];
      mediaController.imageUrl = null;
      screen.updateState();
      await mediaController.initializeVideoPlayer();
      screen.updateState();
    } else if (topic.media![index]['mediaType'] == 'image') {
      mediaController.imageUrl = topic.media![index]['url'];
      mediaController.videoURL = null;
      screen.updateState();
      await mediaController.initializeImage();
      screen.updateState();
    }
  }

  /// Shows preview of selected video
  Widget videoPreviewWidget() {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: mediaController.videoController!.value.aspectRatio,
                child: Chewie(controller: mediaController.chewieController!),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${mediaController.currentIndex + 1} / ${topic.media!.length}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows preview of selected image
  Widget imagePreviewWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(mediaController.imageUrl!),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${mediaController.currentIndex + 1} / ${topic.media!.length}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
