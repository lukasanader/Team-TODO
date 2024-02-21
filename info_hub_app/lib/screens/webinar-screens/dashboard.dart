import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'webinar_details_screen.dart';
import 'package:info_hub_app/services/database_service.dart';

class GoLiveScreen extends StatefulWidget {
  final UserModel user;
  final FirebaseFirestore firestore;
  const GoLiveScreen({Key? key, required this.user, required this.firestore}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List? image;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future goLiveWebinar() async {
    String channelId = await DatabaseService(uid: widget.user.uid, firestore: widget.firestore).startLiveStream(context, _titleController.text , image);
    if (channelId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BroadcastScreen(
            isBroadcaster: true,
            channelId: channelId,
            currentUser: widget.user,
            firestore: widget.firestore,
          ),
          ),
      );
    } else {
      print('Error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 50),
                child: GestureDetector(
                  onTap: () async {
                    Uint8List? pickedImage = await pickImage();
                    if (pickedImage != null) {
                      setState(() {
                        image = pickedImage;
                      });
                    }
                  },
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    child: image != null
                        ? Image.memory(image!)
                        : DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            dashPattern: [10, 4],
                            strokeCap: StrokeCap.round,
                            color: Colors.red,
                            child: Container(
                              height: 200,  // Adjusted height here
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
                    child: TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your title',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      goLiveWebinar();
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Uint8List?> pickImage() async {
  FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(type: FileType.image);
  if (pickedImage != null) {
    return await File(pickedImage.files.single.path!).readAsBytes();
  }
  return null;
}