import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/threads/models/thread_replies_model.dart';

import 'package:info_hub_app/threads/controllers/thread_controller.dart';

class ReplyCard extends StatefulWidget {
  final Reply reply;
  final ThreadController controller;

  const ReplyCard({
    super.key,
    required this.reply,
    required this.controller,
  });

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  late TextEditingController contentController;
  late String profilePhotoFilename;

  @override
  void initState() {
    super.initState();
    contentController = TextEditingController(text: widget.reply.content);
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String docId = widget.reply.id;
    String content = widget.reply.content;
    bool isEdited = widget.reply.isEdited;
    String creator = widget.reply.creator;
    String formatter = widget.controller.formatDate(widget.reply.timestamp);

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    IconData getRoleIcon(String roleType) {
      return widget.controller.getRoleIcon(roleType);
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ExpansionTileCard(
            elevation: 5,
            leading: FutureBuilder<String>(
              future: widget.controller
                  .getUserProfilePhotoFilename(widget.reply.creator),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/${snapshot.data}'),
                  );
                }
                return const CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      AssetImage('assets/default_profile_photo.png'),
                );
              },
            ),
            title: Text(
              widget.reply.authorName,
              key: const Key('authorText_0'),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  content,
                  key: const Key('Content'),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter,
                  style: const TextStyle(fontSize: 12),
                ),
                if (isEdited)
                  const Text(
                    " (edited)",
                    key: Key('editedText'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 0, 0),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            children: <Widget>[
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                buttonHeight: 52.0,
                buttonMinWidth: 90.0,
                children: <Widget>[
                  if (widget.controller.isUserCreator(creator))
                    TextButton(
                      key: const Key('editButton_0'),
                      style: flatButtonStyle,
                      onPressed: () {
                        _showDialog(context, docId);
                      },
                      child: Column(
                        children: <Widget>[
                          const Icon(Icons.edit),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                          ),
                          Text(
                            'Edit Reply',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        getRoleIcon(widget.reply.roleType),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      widget.reply.roleType == 'Healthcare Professional'
                          ? Column(
                              children: <Widget>[
                                Text(
                                  'Healthcare',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Professional',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                          : Text(
                              widget.reply.roleType,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                    ],
                  ),
                  if (widget.controller.isUserCreator(creator))
                    TextButton(
                      key: const Key('deleteButton_0'),
                      style: flatButtonStyle,
                      onPressed: () => deleteReply(docId),
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            Icons.delete,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                          ),
                          Text(
                            'Delete',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 50.0, right: 50.0),
          child: Divider(
            color: Colors.grey,
            height: 1,
          ),
        )
      ],
    );
  }

  void _showDialog(BuildContext context, String docId) async {
    bool showErrorContent = false;
    var replyData = await widget.controller.getReplyData(docId);

    if (!mounted) return;

    contentController.text = replyData?['content'] ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(12.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("Edit your reply"),
                TextField(
                  key: const Key('Content'),
                  autofocus: true,
                  autocorrect: true,
                  decoration: InputDecoration(
                    labelText: "Content",
                    errorText: showErrorContent ? "Please enter content" : null,
                  ),
                  controller: contentController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('cancelButton'),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('updateButtonText'),
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  String updatedContent = contentController.text;

                  await widget.controller.updateReply(docId, updatedContent);
                }
                if (mounted) {
                  Navigator.pop(context);
                } else {
                  setState(() {
                    showErrorContent = true;
                  });
                }
              },
              child: const Text('Save'),
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
          title: const Text('Warning'),
          content: const Text("Are you sure you want to delete your reply?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete Reply'),
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.controller.deleteReply(replyId);
              },
            ),
          ],
        );
      },
    );
  }
}
