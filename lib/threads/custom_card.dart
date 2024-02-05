import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'thread_replies.dart';

class CustomCard extends StatelessWidget {
  final QuerySnapshot? snapshot;
  final int index;

  const CustomCard({Key? key, this.snapshot, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var docData = snapshot!.docs[index].data()
        as Map<String, dynamic>; // Cast the document data to a Map
    var docId = snapshot!.docs[index].id;
    var title = docData['title'] ?? 'No title';
    var description = docData['description'] ?? 'No description';
    var name = docData['name'] ?? 'Unknown';
    var timestamp = docData['timestamp']?.toDate();
    'Timestamp not available'; // Safely access the timestamp
    var formatter = timestamp != null
        ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(timestamp)
        : 'Timestamp not available';

    /* return Column(
      children: <Widget>[ */

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(CupertinoPageRoute(builder: (context) => ThreadReplies()));
      },
      child: Container(
        height: 140,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 5,
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Make the title text bold
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Prevent overflow and add ellipsis
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                    width:
                        8), // Small spacing between the title and "something" text
                IconButton(
                    icon: Icon(
                      FontAwesomeIcons.edit,
                      size: 15,
                    ),
                    onPressed: () {}),

                IconButton(
                    icon: Icon(
                      FontAwesomeIcons.trashAlt,
                      size: 15,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('thread')
                          .doc(docId)
                          .delete();
                    }),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align the text to the start
              mainAxisSize: MainAxisSize.min, // Use minimum space
              children: <Widget>[
                Text(
                  description,
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis if text overflows
                  maxLines: 2,
                ), // The original subtitle text
                Padding(padding: const EdgeInsets.all(2)),
                const SizedBox(
                    height:
                        4), // Add some spacing between the description and the timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name + ": ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 255, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow
                          .ellipsis, // Prevent overflow and add ellipsis
                      maxLines: 1,
                    ),
                    Text(
                      formatter,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            leading: CircleAvatar(
              radius: 34,
              child: Text(title[
                  0]), // Assumes title is not empty place holder for avatar
            ),
          ),
        ),
      ),
    );
  }
}
