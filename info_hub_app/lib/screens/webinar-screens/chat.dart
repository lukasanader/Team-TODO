import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:info_hub_app/models/user_model.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:info_hub_app/services/database_service.dart";

// Implements chat functionality
class Chat extends StatefulWidget {
  final String channelId;
  final UserModel user;
  final FirebaseFirestore firestore;

  const Chat({Key? key, required this.channelId, required this.user, required this.firestore}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _chatController = TextEditingController();

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
    _chatStream = FirebaseFirestore.instance
        .collection('Webinar')
        .doc(widget.channelId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Displays chat messages in a scrollable feature
  Widget _buildChatItem(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    return ListTile(
      title: Text(
        document['roleType'] == 'Healthcare Professional'
            ? '${widget.user.firstName}'
            : 'Anonymous Beaver',
        style: TextStyle(
          color: document['uid'] == widget.user.uid ? Colors.blue : Colors.black,
        ),
      ),
      subtitle: Text(
        document['message'],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Text('Error loading chat');
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) => _buildChatItem(snapshot.data!.docs[index]),
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
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    await DatabaseService(firestore: widget.firestore, uid: widget.user.uid,)
                        .chat(_chatController.text, widget.channelId, widget.user.roleType);
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
    );
  }
}
