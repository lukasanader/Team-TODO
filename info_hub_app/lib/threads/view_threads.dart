import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/thread_replies.dart';
import 'package:intl/intl.dart';

class ViewThreads extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ViewThreads({super.key, required this.firestore, required this.auth});

  @override
  State<ViewThreads> createState() => _ViewThreadsState();
}

class _ViewThreadsState extends State<ViewThreads> {
  late Stream<QuerySnapshot> contentStream;
  bool isViewingThreads = true;

  @override
  void initState() {
    super.initState();
    contentStream = widget.firestore.collection("thread").snapshots();
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
              contentStream = widget.firestore.collection("thread").snapshots();
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
              contentStream =
                  widget.firestore.collection("replies").snapshots();
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
      body: StreamBuilder<QuerySnapshot>(
        stream: contentStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              if (isViewingThreads) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      "${data['author']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data['title'] ?? 'No Title'}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Topic: ${data['topicTitle']} ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          data['timestamp'] != null ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(data['timestamp'].toDate()) : "Unknown time",
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
                          onPressed: () => deleteThread(document.id),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!isViewingThreads) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                              'assets/${data['userProfilePhoto'] ?? 'default_profile_photo.png'}')
                          as ImageProvider<Object>,
                      radius: 38,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (!isViewingThreads) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ThreadReplies(
                                      threadId: data['threadId'],
                                      firestore: widget.firestore,
                                      auth: widget.auth,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              (data['threadTitle'] ?? 'Missing Thread Title'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              //overflow: TextOverflow.ellipsis,
                              //maxLines: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ThreadReplies(
                                    threadId: data['threadId'],
                                    firestore: widget.firestore,
                                    auth: widget.auth,
                                  ),
                                ),
                              );
                            }),
                        const SizedBox(width: 8),
                        /*if (data['authorId'] ==
                            widget.auth.currentUser!
                                .uid) */ // Use authorId or similar field
                        IconButton(
                          icon: const Icon(Icons.delete),
                          /*onPressed: () => !isViewingThreads
                              ? deleteThread(document.id)
                              : deleteReply(document.id), */
                          onPressed: () => deleteReply(document.id),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          (data['content'] ?? 'No Content'),
                          //overflow: TextOverflow.ellipsis,
                          //maxLines: 2,
                        ),
                        const Padding(padding: EdgeInsets.all(2)),
                        const SizedBox(height: 4),
                        if (!isViewingThreads)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${data['author']} - ",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                data['timestamp'] != null
                                    ? DateFormat("dd-MMM-yyyy 'at' HH:mm")
                                        .format(data['timestamp'].toDate())
                                    : "Unknown time",
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    /*trailing: IconButton(
                      icon: const Icon(FontAwesomeIcons.trashAlt, size: 15),
                      onPressed: () => deleteReply(document.id),
                    ),*/
                    isThreeLine: true,
                  ),
                );
              }
              return null;
            },
          );
        },
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
              "Are you sure you want to delete this thread and all its replies?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first

                // Delete all replies associated with the thread
                final replyQuerySnapshot = await widget.firestore
                    .collection("replies")
                    .where('threadId', isEqualTo: threadId)
                    .get();

                final WriteBatch batch = widget.firestore.batch();
                for (DocumentSnapshot replyDoc in replyQuerySnapshot.docs) {
                  batch.delete(replyDoc.reference);
                }

                // Commit the batch deletion of replies
                await batch.commit();

                // Now delete the thread itself
                await widget.firestore
                    .collection("thread")
                    .doc(threadId)
                    .delete();
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
          content: const Text("Are you sure you want to delete this reply?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first

                // Delete the reply
                await widget.firestore
                    .collection("replies")
                    .doc(replyId)
                    .delete();
              },
            ),
          ],
        );
      },
    );
  }
}
