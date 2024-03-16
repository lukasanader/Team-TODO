import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import '../webinar-screens/webinar_details_screen.dart';

class CreateWebinarScreen extends StatefulWidget {
  final UserModel user;
  final FirebaseFirestore firestore;
 
  const CreateWebinarScreen({Key? key, required this.user, required this.firestore}) : super(key: key);

  @override
  State<CreateWebinarScreen> createState() => _CreateWebinarScreenState();
}

class _CreateWebinarScreenState extends State<CreateWebinarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_removeFeatureShared);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();

  }
  
  void _removeFeatureShared() {
    setState(() {
      _urlController.text = _urlController.text.replaceAll('?feature=shared', '');
    });
  }
  
  Future<void> _goLiveWebinar(DateTime? time,{bool isScheduled = false}) async {
    if (_formKey.currentState!.validate()) {
      time ??= DateTime.now();
      String statusText = isScheduled ? 'Upcoming' : 'Live';
      final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm', 'en_GB');
      String webinarID = await WebinarService(firestore: widget.firestore)
          .startLiveStream(
            _titleController.text,
            _urlController.text,
            image,
            ("${widget.user.firstName} ${widget.user.lastName}"),
            formatter.format(time).toString(),
            statusText
          );
      if (webinarID.isNotEmpty) {
        if (!isScheduled) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BroadcastScreen(
                webinarID: webinarID,
                youtubeURL: _urlController.text,
                currentUser: widget.user,
                firestore: widget.firestore,
                title: _titleController.text,
              ),
            ),
          );
        } else {

          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A webinar with this URL may already exist. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<Uint8List?> _pickImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(type: FileType.image);
    if (pickedImage != null) {
      return await File(pickedImage.files.single.path!).readAsBytes();
    }
    return null;
  }

  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _goLiveWebinar(
            selectedDateTime,
            isScheduled: true);
      }
    }
  }

  String? _validateUrl(String? url) {
    final RegExp _youtubeUrlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)(\?feature=shared)?$',
    );
    final RegExp _youtubeLiveUrlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?youtube\.com\/live\/([a-zA-Z0-9_-]+)',
    );
    
    if (url == null || url.isEmpty) {
      return 'URL is required';
    }

    if (!_youtubeUrlRegex.hasMatch(url) && !_youtubeLiveUrlRegex.hasMatch(url)) {
      return 'Enter a valid YouTube video URL';
    }

    return null;
  }


void _showWebinarStartingHelpDialogue() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('How to Start a Livestream on YouTube'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep(
                stepNumber: 1,
                stepDescription: 'Sign in to your YouTube account on a web browser.',
              ),
              _buildStep(
                stepNumber: 2,
                stepDescription: 'Click on the Create button at the top right corner of the page.',
              ),
              _buildStep(
                stepNumber: 3,
                stepDescription: 'Select "Go live" from the dropdown menu.',
              ),
              _buildStep(
                stepNumber: 4,
                stepDescription: 'Enter the title and description for your livestream.',
              ),
              _buildStep(
                stepNumber: 5,
                stepDescription: 'Set the privacy settings for your livestream (Public, Unlisted, or Private).',
              ),
              _buildStep(
                stepNumber: 6,
                stepDescription: 'Click on "More options" to customize your livestream settings further (optional).',
              ),
              _buildStep(
                stepNumber: 7,
                stepDescription: 'Disable the stream chat in the YouTube Studio settings to prevent distractions.',
              ),
              _buildStep(
                stepNumber: 8,
                stepDescription: 'Click on "Next" to proceed to the next step.',
              ),
              _buildStep(
                stepNumber: 9,
                stepDescription: 'Wait for YouTube to set up your livestream. This may take a few moments.',
              ),
              _buildStep(
                stepNumber: 10,
                stepDescription: 'Once your livestream is set up, copy the link for the YouTube stream.',
              ),
              _buildStep(
                stepNumber: 11,
                stepDescription: 'Paste the copied link into the app to start streaming.',
              ),
              _buildStep(
                stepNumber: 12,
                stepDescription: 'Click on "Go live" to start streaming from the app.',
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

Widget _buildStep({required int stepNumber, required String stepDescription}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$stepNumber. ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(stepDescription),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Webinar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showWebinarStartingHelpDialogue();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: GestureDetector(
                    onTap: () async {
                      Uint8List? pickedImage = await _pickImage();
                      if (pickedImage != null) {
                        setState(() {
                          image = pickedImage;
                        });
                      }
                    },
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: image != null
                          ? Image.memory(image!)
                          : DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 4],
                              strokeCap: StrokeCap.round,
                              color: Colors.red,
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.folder_open,
                                      color: Colors.red,
                                      size: 40.0,
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      'Select a thumbnail',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your title',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Text(
                      'YouTube URL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _urlController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your YouTube video URL here',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: _validateUrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectDateTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Schedule Webinar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _goLiveWebinar(null);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Start Webinar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

