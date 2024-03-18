import 'dart:io';
import 'package:info_hub_app/webinar/helpers/create_webinar_helper.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import '../webinar-screens/display_webinar.dart';

class CreateWebinarScreen extends StatefulWidget {
  final UserModel user;
  final FirebaseFirestore firestore;
  final WebinarService webinarService;
 
  const CreateWebinarScreen({super.key, required this.user, required this.firestore, required this.webinarService});

  @override
  State<CreateWebinarScreen> createState() => _CreateWebinarScreenState();
}

class _CreateWebinarScreenState extends State<CreateWebinarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final CreateWebinarHelper helper = CreateWebinarHelper();
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
      String webinarID = await widget.webinarService
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
              builder: (context) => WebinarScreen(
                webinarID: webinarID,
                youtubeURL: _urlController.text,
                currentUser: widget.user,
                firestore: widget.firestore,
                title: _titleController.text,
                webinarService: widget.webinarService,
                status: statusText
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
    final RegExp youtubeUrlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)(\?feature=shared)?$',
    );
    final RegExp youtubeLiveUrlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?youtube\.com\/live\/([a-zA-Z0-9_-]+)',
    );
    
    if (url == null || url.isEmpty) {
      return 'URL is required';
    }

    if (!youtubeUrlRegex.hasMatch(url) && !youtubeLiveUrlRegex.hasMatch(url)) {
      return 'Enter a valid YouTube video URL';
    }

    return null;
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
            helper.showWebinarStartingHelpDialogue(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
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
      ),
    );
  }
}

