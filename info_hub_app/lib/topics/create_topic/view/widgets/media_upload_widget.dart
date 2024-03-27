import 'package:flutter/material.dart';
import '../../../../controller/create_topic_controllers/media_upload_controller.dart';

/// Widget for uploading and managing media.
class MediaUploadWidget extends StatelessWidget {
  final MediaUploadController mediaUploadController;

  const MediaUploadWidget({
    super.key,
    required this.mediaUploadController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          key: const Key('uploadMediaButton'),
          onPressed: () {
            if (mediaUploadController.videoURL != null ||
                mediaUploadController.imageURL != null) {
              // If media exists, set changingMedia to true
              mediaUploadController.changingMedia = true;
            } else if (mediaUploadController.videoURL == null &&
                mediaUploadController.imageURL == null) {
              // If no media, set changingMedia to false
              mediaUploadController.changingMedia = false;
            }
            showMediaUploadOptions(context);
          },
          icon: const Icon(Icons.cloud_upload_outlined),
          label: mediaUploadController.videoURL != null ||
                  mediaUploadController.imageURL != null
              ? const Text(
                  'Change Media',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Text(
                  'Upload Media',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (mediaUploadController.videoURL != null ||
            mediaUploadController.imageURL != null)
          ElevatedButton.icon(
            key: const Key('moreMediaButton'),
            onPressed: () {
              mediaUploadController.changingMedia = false;
              showMediaUploadOptions(context);
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Add More Media',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
      ],
    );
  }

  /// Shows a user the choice of uploading image or video
  Future<void> showMediaUploadOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Upload Image'),
              onTap: () {
                Navigator.pop(context);
                mediaUploadController.pickFromDevice("image");
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Upload Video'),
              onTap: () {
                Navigator.pop(context);
                mediaUploadController.pickFromDevice("video");
              },
            ),
          ],
        );
      },
    );
    return;
  }
}
