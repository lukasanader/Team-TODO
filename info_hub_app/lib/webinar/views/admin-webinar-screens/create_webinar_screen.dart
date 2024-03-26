// ignore_for_file: use_build_context_synchronously

import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
import 'package:info_hub_app/webinar/controllers/create_webinar_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:info_hub_app/webinar/controllers/webinar_controller.dart';

/// Screen concerned with the creation of a webinar instance
class CreateWebinarScreen extends StatefulWidget {
  final UserModel user;
  final FirebaseFirestore firestore;
  final WebinarController webinarController;

  const CreateWebinarScreen(
      {super.key,
      required this.user,
      required this.firestore,
      required this.webinarController});

  @override
  State<CreateWebinarScreen> createState() => _CreateWebinarScreenState();
}

class _CreateWebinarScreenState extends State<CreateWebinarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late CreateWebinarController controller;
  Uint8List? image;

  bool isPatientSelected = false;
  bool isParentSelected = false;
  bool isHealthcareProfessionalSelected = false;

  @override
  void initState() {
    super.initState();
    controller = CreateWebinarController(webinarController: widget.webinarController, firestore: widget.firestore, user: widget.user);
    _urlController.addListener(_removeFeatureShared);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  /// Removes YouTube tracking from link copying
  void _removeFeatureShared() {
    setState(() {
      String currentText = _urlController.text;
      if (currentText.endsWith('?feature=shared')) {
        _urlController.text = currentText.substring(0, currentText.length - '?feature=shared'.length);
      }
    });
  }

  /// Grants user the ability to schedule their webinar for a later date
  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2), // Will show time for the next 2 years, change '2' for more or less
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
        if (controller.isAnyRoleSelected(
          isPatientSelected,
          isParentSelected,
          isHealthcareProfessionalSelected) 
          && 
          image != null) {
            List<String> selectedTags = controller.populateTags(isPatientSelected, isParentSelected,isHealthcareProfessionalSelected);
            selectedTags.add('admin');
            controller.goLiveWebinar(
              context,
              selectedDateTime,
              _formKey.currentState,
              _titleController.text,
              _urlController.text,
              image,
              selectedTags,
              isScheduled: true
            );
          } else {
            controller.showThumbnailAndRoleError(context);
        }

      }
    }
  }


  /// Creates the instruction dialog for how to create a webinar and seed the database from the user side
  void showWebinarStartingHelpDialogue(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Start a Livestream on YouTube'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.buildStep(
                  stepNumber: 1,
                  stepDescription: 'Sign in to your YouTube account on a web browser.',
                ),
                controller.buildStep(
                  stepNumber: 2,
                  stepDescription: 'Click on the Create button at the top right corner of the page.',
                ),
                controller.buildStep(
                  stepNumber: 3,
                  stepDescription: 'Select "Go live" from the dropdown menu.',
                ),
                controller.buildStep(
                  stepNumber: 4,
                  stepDescription: 'Enter the title and description for your livestream.',
                ),
                controller.buildStep(
                  stepNumber: 5,
                  stepDescription: 'Set the privacy settings for your livestream (Public, Unlisted, or Private).',
                ),
                controller.buildStep(
                  stepNumber: 6,
                  stepDescription: 'Click on "More options" to customize your livestream settings further (optional).',
                ),
                controller.buildStep(
                  stepNumber: 7,
                  stepDescription: 'Disable the stream chat in the YouTube Studio settings to prevent distractions.',
                ),
                controller.buildStep(
                  stepNumber: 8,
                  stepDescription: 'Click on "Next" to proceed to the next step.',
                ),
                controller.buildStep(
                  stepNumber: 9,
                  stepDescription: 'Wait for YouTube to set up your livestream. This may take a few moments.',
                ),
                controller.buildStep(
                  stepNumber: 10,
                  stepDescription: 'Once your livestream is set up, copy the link for the YouTube stream.',
                ),
                controller.buildStep(
                  stepNumber: 11,
                  stepDescription: 'Paste the copied link into the app to start streaming.',
                ),
                controller.buildStep(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Webinar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showWebinarStartingHelpDialogue(context);
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
                        Uint8List? pickedImage = await controller.pickImage();
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
                                color: COLOR_PRIMARY_LIGHT,
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
                                      Icon(
                                        Icons.folder_open,
                                        color: COLOR_PRIMARY_LIGHT,
                                        size: 40.0,
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        'Select a thumbnail',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              COLOR_SECONDARY_GREY_LIGHT_DARKER,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.title),
                            hintText: 'Title',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.link),
                            hintText: 'YouTube Video URL',
                          ),
                          validator: controller.validateUrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('This webinar is for:',                 
                        style: TextStyle(
                          fontSize: 15,
                          color: COLOR_SECONDARY_GREY_LIGHT_DARKER,
                        ),
                        textAlign: TextAlign.left,
                      ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isPatientSelected = !isPatientSelected;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPatientSelected ? Colors.red : null,
                          ),
                          child: Text(
                            'Patients',
                            style: TextStyle(
                              color: isPatientSelected ? Colors.white : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5,),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isParentSelected = !isParentSelected;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isParentSelected ? Colors.red : null,
                          ),
                          child: Text(
                            'Parents',
                            style: TextStyle(
                              color: isParentSelected ? Colors.white : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5,),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isHealthcareProfessionalSelected =
                                  !isHealthcareProfessionalSelected;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isHealthcareProfessionalSelected
                                ? Colors.red
                                : null,
                          ),
                          child: Text(
                            'Healthcare Professionals',
                            style: TextStyle(
                              color: isHealthcareProfessionalSelected
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && image != null && controller.isAnyRoleSelected(isPatientSelected,isParentSelected,isHealthcareProfessionalSelected)) {
                        List<String> selectedTags = controller.populateTags(isPatientSelected,isParentSelected,isHealthcareProfessionalSelected);
                        await controller.goLiveWebinar(context, null, _formKey.currentState, _titleController.text, _urlController.text, image, selectedTags);
                      } else {
                        controller.showThumbnailAndRoleError(context);
                      }
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

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: _selectDateTime,
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'Schedule Webinar',
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