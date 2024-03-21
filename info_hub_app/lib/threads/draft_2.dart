// ignore_for_file: dead_code

/*

import 'package:flutter/material.dart';

i dont know where to put this
 @override
  Widget build(BuildContext context) {
    
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ); 

return Column(
  children: <Widget>[
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ExpansionTileCard(
        leading:  radius: 30,
          backgroundImage: widget.userProfilePhoto.startsWith('http')
              ? NetworkImage(widget.userProfilePhoto) as ImageProvider<Object>
              : AssetImage('assets/${widget.userProfilePhoto}') as ImageProvider<Object>,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: InkWell(
                key: Key('navigateToThreadReplies_${widget.index}'),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (BuildContext context) => ThreadReplies(
                            threadId: docId,
                            firestore: widget.firestore,
                            auth: widget.auth,
                          )));
                },
                child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          //maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                   subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                authorName, // This should be the subtitle, like the user's name.
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
                  Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                formatter, // This should be your timestamp
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        children: <Widget>[
          const Divider(
            thickness: 1.0,
            height: 1.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                     description,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                   if (isEdited) // Check if the post is edited
                    const Text(
                      " (edited)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 255, 0, 0),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "$authorName: ",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceAround,
                    buttonHeight: 52.0,
                    buttonMinWidth: 90.0,
                    children: <Widget>[
                      if (currentUserId == creator)
                        TextButton(
                          onPressed: () {
                            _showDialog(context, docId);
                          },
                          child: const Column(
                            children: <Widget>[
                              Icon(Icons.edit),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text('Edit Post'),
                            ],
                          ),
                        ),
                      if (currentUserId == creator)
                        TextButton(
                          onPressed: () async {
                            // Place your delete logic here
                          },
                          child: const Column(
                            children: <Widget>[
                              Icon(Icons.delete),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text('Delete Post'),
                            ],
                          ),
                        ),
                         //(tells what role the user who posted is)
                        TextButton(
                          onPressed: () async {
//i dont want to have a button here basically users have 3 roles either patient, healthcare professional or admin, so i want the post to be tagged with the role of the user who posted it with a different image for each role
                          },
                          child: const Column(
                            children: <Widget>[
                              Icon(Icons.profile),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text(' user role will be either patient, healthcare professional or admin'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ],
);  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),

                  ),
                ],
              )
          )
        ]

        */