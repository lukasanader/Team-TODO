import 'package:flutter/material.dart';
import '../../../controller/create_topic_controllers/media_upload_controller.dart';
import 'package:info_hub_app/view/topic_creation_view/topic_creation_view.dart';

import 'dart:io';
import 'package:chewie/chewie.dart';

/// Widget for displaying Media Previews and navigation buttons
class MediaDisplayWidget extends StatelessWidget {
  final MediaUploadController mediaUploadController;
  final TopicCreationViewState screen;

  const MediaDisplayWidget({
    super.key,
    required this.mediaUploadController,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display video preview if video URL is not null and chewie controller has been initialized
        if (mediaUploadController.videoURL != null &&
            mediaUploadController.chewieController != null)
          videoPreviewWidget(),
        // Display image preview if image URL is not null
        if (mediaUploadController.imageURL != null) imagePreviewWidget(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (mediaUploadController.mediaUrls.length > 1)
              // Button for navigating to previous media
              IconButton(
                key: const Key('previousMediaButton'),
                icon: const Icon(
                  Icons.arrow_circle_left_rounded,
                  color: Color.fromRGBO(150, 100, 200, 1.0),
                ),
                onPressed: () async {
                  if (screen.currentIndex - 1 >= 0) {
                    screen.currentIndex -= 1;
                    if (mediaUploadController.mediaUrls[screen.currentIndex]
                            ['mediaType'] ==
                        'video') {
                      mediaUploadController.videoURL = mediaUploadController
                          .mediaUrls[screen.currentIndex]['url'];
                      mediaUploadController.imageURL = null;
                      screen.updateState();
                      await mediaUploadController.initializeVideoPlayer();
                      screen.updateState();
                    } else if (mediaUploadController
                            .mediaUrls[screen.currentIndex]['mediaType'] ==
                        'image') {
                      mediaUploadController.imageURL = mediaUploadController
                          .mediaUrls[screen.currentIndex]['url'];
                      mediaUploadController.videoURL = null;
                      screen.updateState();
                      await mediaUploadController.initializeImage();
                    }
                  }
                },
                tooltip: 'Previous Video',
              ),
            if (mediaUploadController.mediaUrls.length > 1)
              // Button for navigating to next media
              IconButton(
                key: const Key('nextMediaButton'),
                icon: const Icon(
                  Icons.arrow_circle_right_rounded,
                  color: Color.fromRGBO(150, 100, 200, 1.0),
                ),
                onPressed: () async {
                  if (screen.currentIndex + 1 <
                      mediaUploadController.mediaUrls.length) {
                    screen.currentIndex += 1;
                    if (mediaUploadController.mediaUrls[screen.currentIndex]
                            ['mediaType'] ==
                        'video') {
                      mediaUploadController.videoURL = mediaUploadController
                          .mediaUrls[screen.currentIndex]['url'];
                      mediaUploadController.imageURL = null;
                      screen.updateState();
                      await mediaUploadController.initializeVideoPlayer();
                      screen.updateState();
                    } else if (mediaUploadController
                            .mediaUrls[screen.currentIndex]['mediaType'] ==
                        'image') {
                      mediaUploadController.imageURL = mediaUploadController
                          .mediaUrls[screen.currentIndex]['url'];
                      mediaUploadController.videoURL = null;
                      screen.updateState();
                      await mediaUploadController.initializeImage();
                    }
                  }
                },
                tooltip: 'Next Video',
              ),
          ],
        ),
      ],
    );
  }

  /// Widget for displaying video preview.
  Widget videoPreviewWidget() {
    mediaUploadController.initializeUrls;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio:
                mediaUploadController.videoController!.value.aspectRatio,
            child: Chewie(controller: mediaUploadController.chewieController!),
          ),
          // Text showing video preview status and what index of video user is currently viewing
          if (!screen.editing ||
              mediaUploadController.networkUrls
                  .contains(mediaUploadController.videoURL))
            Row(
              children: [
                const Text(
                  'The above is a preview of your video.',
                  key: Key('upload_text_video'),
                  style: TextStyle(color: Colors.grey),
                ),
                currentMediaCount()
              ],
            ),

          if (screen.editing &&
              !mediaUploadController.networkUrls
                  .contains(mediaUploadController.videoURL))
            Row(
              children: [
                const Text(
                  'The above is a preview of your new video.',
                  key: Key('edit_text_video'),
                  style: TextStyle(color: Colors.grey),
                ),
                currentMediaCount()
              ],
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Button to clear current video selection
              IconButton(
                key: const Key('deleteVideoButton'),
                icon: const Icon(Icons.delete_forever_outlined,
                    color: Colors.red),
                onPressed: mediaUploadController.clearSelection,
                tooltip: 'Remove Video',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget for displaying image preview.
  Widget imagePreviewWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!mediaUploadController.networkUrls
            .contains(mediaUploadController.imageURL))
          Image.file(File(mediaUploadController.imageURL!)),
        // if the Image is in the list of images that were already stored, get the image from the network
        if (mediaUploadController.networkUrls
            .contains(mediaUploadController.imageURL))
          Image.network((mediaUploadController.imageURL!)),
        // Text showing image preview status and what index of image user is currently viewing
        if (!screen.editing ||
            mediaUploadController.networkUrls
                .contains(mediaUploadController.imageURL))
          Row(
            children: [
              const Text(
                'The above is a preview of your image.',
                key: Key('upload_text_image'),
                style: TextStyle(color: Colors.grey),
              ),
              currentMediaCount()
            ],
          ),

        if (screen.editing &&
            !mediaUploadController.networkUrls
                .contains(mediaUploadController.imageURL))
          Row(
            children: [
              const Text(
                'The above is a preview of your new image.',
                key: Key('edit_text_image'),
                style: TextStyle(color: Colors.grey),
              ),
              currentMediaCount()
            ],
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button to clear current image selection
            IconButton(
              key: const Key('deleteImageButton'),
              icon:
                  const Icon(Icons.delete_forever_outlined, color: Colors.red),
              onPressed: mediaUploadController.clearSelection,
              tooltip: 'Remove Image',
            ),
          ],
        ),
      ],
    );
  }

  Widget currentMediaCount() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${screen.currentIndex + 1} / ${mediaUploadController.mediaUrls.length}',
          style: const TextStyle(color: Color.fromARGB(255, 197, 15, 15)),
        ),
      ),
    );
  }
}
