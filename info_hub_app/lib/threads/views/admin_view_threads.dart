import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/views/thread_replies.dart';
import 'package:info_hub_app/threads/models/thread_model.dart';
import 'package:info_hub_app/threads/models/thread_replies_model.dart';
import 'package:info_hub_app/threads/controllers/thread_controller.dart';

class ViewThreads extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ViewThreads({super.key, required this.firestore, required this.auth});

  @override
  State<ViewThreads> createState() => _ViewThreadsState();
}

class _ViewThreadsState extends State<ViewThreads> {
  late Stream<List<Thread>> threadsStream;
  late Stream<List<Reply>> repliesStream;
  //late String profilePhotoFilename;
  bool isViewingThreads = true;
  late ThreadController controller;

  @override
  void initState() {
    super.initState();
    //_loadUserProfilePhoto();
    controller =
        ThreadController(firestore: widget.firestore, auth: widget.auth);
    threadsStream = controller.getAllThreadsStream();
    repliesStream = controller.getAllRepliesStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isViewingThreads ? "View Threads" : "View Replies"),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              isViewingThreads = true;
              threadsStream;
            }),
            style: TextButton.styleFrom(
              backgroundColor: isViewingThreads
                  ? Theme.of(context).primaryColor
                  : Colors.white,
            ),
            child: Text(
              "Threads",
              style: TextStyle(
                  color: isViewingThreads
                      ? Colors.white
                      : Theme.of(context).primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              isViewingThreads = false;
              repliesStream;
            }),
            style: TextButton.styleFrom(
              backgroundColor: !isViewingThreads
                  ? Theme.of(context).primaryColor
                  : Colors.white,
            ),
            child: Text(
              "Replies",
              style: TextStyle(
                  color: !isViewingThreads
                      ? Colors.white
                      : Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: isViewingThreads ? buildThreadsList() : buildRepliesList(),
    );
  }

  Widget buildThreadsList() {
    return StreamBuilder<List<Thread>>(
      stream: threadsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No threads found.");
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Thread thread = snapshot.data![index];
            return buildThreadItem(thread);
          },
        );
      },
    );
  }

  Widget buildThreadItem(Thread thread) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      elevation: 5,
      child: ListTile(
        title: Text(
          thread.authorName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              thread.title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Topic: ${thread.topicTitle} ",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              controller.formatDate(thread.timestamp),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteThread(thread.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRepliesList() {
    return StreamBuilder<List<Reply>>(
      stream: repliesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No replies found.");
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Reply reply = snapshot.data![index];
            return buildReplyItem(reply);
          },
        );
      },
    );
  }

  Widget buildReplyItem(Reply reply) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      elevation: 5,
      child: ListTile(
        leading: FutureBuilder<String>(
          future: controller.getUserProfilePhotoFilename(reply.creator),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return CircleAvatar(
                backgroundImage: AssetImage('assets/${snapshot.data}'),
                radius: 38,
              );
            }
            return const CircleAvatar(
              backgroundImage: AssetImage('assets/default_profile_photo.png'),
              radius: 38,
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                reply.threadTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ThreadReplies(
                      threadId: reply.threadId,
                      firestore: widget.firestore,
                      auth: widget.auth,
                      threadTitle: reply.threadTitle,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteReply(reply.id),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(reply.content),
            const SizedBox(height: 4),
            Text(
              controller.formatDate(reply.timestamp),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void deleteThread(String threadId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Thread'),
          content: const Text(
              "Confirm deletion of this thread and all its replies?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                controller.deleteThread(threadId);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteReply(String replyId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reply'),
          content: const Text("Confirm deletion of this reply?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                controller.deleteReply(replyId);
              },
            ),
          ],
        );
      },
    );
  }
}
