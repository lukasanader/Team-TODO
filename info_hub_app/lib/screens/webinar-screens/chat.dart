import 'package:flutter/material.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/services/database_service.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:timeago/timeago.dart' as timeago;

// Implements chat functionality
class Chat extends StatefulWidget {
  final String webinarID;
  final UserModel user;
  final FirebaseFirestore firestore;

  const Chat({
    Key? key,
    required this.webinarID,
    required this.user,
    required this.firestore,
  }) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _chatController = TextEditingController();
  final filter = ProfanityFilter();

  late Stream<QuerySnapshot<Map<String, dynamic>>> _chatStream;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize the Firestore stream
    _chatStream = widget.firestore
        .collection('Webinar')
        .doc(widget.webinarID)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Displays chat messages in a scrollable feature
  Widget _buildChatItem(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String timeAgo,
  ) {
    return ListTile(
      title: Text(
        document['roleType'] == 'Healthcare Professional'
            ? widget.user.firstName
            : 'Anonymous Beaver',
        style: TextStyle(
          color: document['uid'] == widget.user.uid ? Colors.red : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            document['message'],
          ),
          Text(
            timeAgo, // Display time ago string
            style: TextStyle(
              fontSize: 12, // Adjust font size if needed
              color: Colors.grey, // Adjust color if needed
            ),
          ),
        ],
      ),
    );
  }

  // Function to show a warning dialog for profanity
  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            'Please refrain from using language that may be rude to others or writing your name in your messages.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue), // Set button text color
              ),
            ),
          ],
        );
      },
    );
  }

  // Tests if user has entered their name in the message
  bool _namePresent(String messageText) {
    String messageToLowercase = messageText.toLowerCase();
    String name = widget.user.firstName.toLowerCase();
    return messageToLowercase.contains(name);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _chatStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text('Error loading chat');
                  }

                  // Convert Firestore timestamp to DateTime and update time ago string
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> chatDocuments =
                      snapshot.data!.docs;
                  List<Widget> chatItems = chatDocuments.map((document) {
                    DateTime createdAt =
                        (document['createdAt'] as Timestamp).toDate();
                    String timeAgo = timeago.format(createdAt);

                    return _buildChatItem(document, timeAgo);
                  }).toList();

                  return ListView(
                    reverse: true, // To display new messages at the bottom
                    children: chatItems,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      // checks for profanities or name before adding comment to database
                      bool hasProfanities = filter.hasProfanity(_chatController.text);
                      bool hasName = _namePresent(_chatController.text);
                      if (!hasProfanities && !hasName) {
                        await DatabaseService(firestore: widget.firestore,)
                            .chat(_chatController.text, widget.webinarID, widget.user.roleType,widget.user.uid);
                      } else {
                        _showWarningDialog();
                      }
                      setState(() {
                        _chatController.text = "";
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
