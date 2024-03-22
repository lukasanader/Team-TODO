import 'package:flutter/material.dart';

class CreateWebinarHelper {

  CreateWebinarHelper();

  // Creates the instruction dialog for how to create a webinar and seed the database from the user side
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
}