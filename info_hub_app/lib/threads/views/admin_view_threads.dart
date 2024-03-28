import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
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
  bool isViewingThreads = true;
  late ThreadController controller;

  @override
  void initState() {
    super.initState();
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
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: TextButton(
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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No threads found.");
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Thread thread = snapshot.data![index];
            if (index == snapshot.data!.length - 1) {
              return Column(
                children: [
                  buildThreadItem(thread),
                  const SizedBox(height: 20),
                ],
              );
            } else {
              return buildThreadItem(thread);
            }
          },
        );
      },
    );
  }

  Widget buildThreadItem(Thread thread) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? COLOR_SECONDARY_GREY_LIGHT
                : COLOR_SECONDARY_GREY_DARK,
            width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          title: Text(
            thread.authorName,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                thread.title,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Topic: ${thread.topicTitle}",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                controller.formatDate(thread.timestamp),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => deleteThread(thread.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRepliesList() {
    return StreamBuilder<List<Reply>>(
      stream: repliesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No replies found.");
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Reply reply = snapshot.data![index];
            if (index == snapshot.data!.length - 1) {
              return Column(
                children: [
                  buildReplyItem(reply),
                  const SizedBox(height: 20),
                ],
              );
            } else {
              return buildReplyItem(reply);
            }
          },
        );
      },
    );
  }

  Widget buildReplyItem(Reply reply) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context).brightness == Brightness.light
                ? COLOR_SECONDARY_GREY_LIGHT
                : COLOR_SECONDARY_GREY_DARK,
            width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: FutureBuilder<String>(
            future: controller.getUserProfilePhotoFilename(reply.creator),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return CircleAvatar(
                  backgroundImage: AssetImage('assets/${snapshot.data}'),
                  radius: 24,
                );
              }
              return const CircleAvatar(
                backgroundImage: AssetImage('assets/default_profile_photo.png'),
                radius: 24,
              );
            },
          ),
          title: Text(
            reply.threadTitle,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                reply.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                controller.formatDate(reply.timestamp),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
                icon: const Icon(Icons.delete_outline),
                onPressed: () => deleteReply(reply.id),
              ),
            ],
          ),
          isThreeLine: true,
        ),
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
