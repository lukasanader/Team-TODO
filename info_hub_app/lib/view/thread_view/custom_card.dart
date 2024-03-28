import 'package:flutter/material.dart';
import 'package:info_hub_app/view/thread_view/thread_replies.dart';
import 'package:flutter/cupertino.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:info_hub_app/model/thread_models/thread_model.dart';
import 'package:info_hub_app/controller/thread_controllers/thread_controller.dart';

class CustomCard extends StatefulWidget {
  final int index;
  final Thread thread;
  final ThreadController controller;
  final String threadId;

  const CustomCard({
    super.key,
    required this.index,
    required this.thread,
    required this.controller,
    required this.threadId,
  });

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;
  late bool isEdited;
  late String profilePhotoFilename;

  @override
  void initState() {
    super.initState();
    isEdited = widget.thread.isEdited;
    titleInputController = TextEditingController(text: widget.thread.title);
    descriptionInputController =
        TextEditingController(text: widget.thread.description);
  }

  @override
  void dispose() {
    titleInputController.dispose();
    descriptionInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formatter = widget.controller.formatDate(widget.thread.timestamp);
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
// UI for the custom card
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ExpansionTileCard(
            leading: FutureBuilder<String>(
              future: widget.controller
                  .getUserProfilePhotoFilename(widget.thread.creator),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return CircleAvatar(
                    key: Key('profilePhoto_${widget.index}'),
                    radius: 30,
                    backgroundImage: AssetImage('assets/${snapshot.data}'),
                  );
                }
                return CircleAvatar(
                  key: Key('profilePhoto_${widget.index}'),
                  radius: 30,
                  backgroundImage:
                      const AssetImage('assets/default_profile_photo.png'),
                );
              },
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    key: Key('navigateToThreadReplies_${widget.index}'),
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (BuildContext context) => ThreadReplies(
                          threadTitle: widget.thread.title,
                          threadId: widget.threadId,
                          firestore: widget.controller.firestore,
                          auth: widget.controller.auth,
                        ),
                      ));
                    },
                    child: Text(
                      widget.thread.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.thread.authorName,
                    key: Key('authorText_${widget.index}'),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Text(
                  formatter,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.thread.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 16),
                    ),
                    if (isEdited)
                      Text(
                        " (edited)",
                        key: Key('editedText_${widget.index}'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 0, 0),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      buttonHeight: 52.0,
                      buttonMinWidth: 90.0,
                      children: <Widget>[
                        if (widget.controller
                            .isUserCreator(widget.thread.creator))
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () {
                              _showDialog(context, widget.threadId);
                            },
                            child: Column(
                              children: <Widget>[
                                const Icon(Icons.edit, key: Key('editIcon_0')),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text(
                                  'Edit Post',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            ),
                          ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              widget.controller
                                  .getRoleIcon(widget.thread.roleType),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.0),
                            ),
                            widget.thread.roleType == 'Healthcare Professional'
                                ? Column(
                                    children: <Widget>[
                                      Text(
                                        'Healthcare',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        'Professional',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  )
                                : Text(
                                    widget.thread.roleType,
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                          ],
                        ),
                        if (widget.controller
                            .isUserCreator(widget.thread.creator))
                          TextButton(
                            style: flatButtonStyle,
                            onPressed: () => deleteThread(widget.threadId),
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.delete,
                                    key: Key('deleteIcon_${widget.index}')),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Text(
                                  'Delete Post',
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

// Dialog for editing thread
  _showDialog(BuildContext context, String threadId) async {
    bool showErrorTitle = false;
    bool showErrorDescription = false;

    var docData = await widget.controller.getThreadData(threadId);

    if (!mounted) return;

    titleInputController.text = docData?['title'] ?? '';

    descriptionInputController.text = docData?['description'] ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(12.0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text("Please fill out the form"),
                    TextField(
                      key: const Key('Title'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Title",
                        errorText:
                            showErrorTitle ? "Please enter a title" : null,
                      ),
                      controller: titleInputController,
                    ),
                    TextField(
                      key: const Key('Description'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Description",
                        errorText: showErrorDescription
                            ? "Please enter a description"
                            : null,
                      ),
                      controller: descriptionInputController,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    if (!showErrorTitle && !showErrorDescription) {
                      setState(() {
                        docData?['title'] = titleInputController.text;
                        docData?['description'] =
                            descriptionInputController.text;
                        isEdited = true;
                      });

                      widget.controller.updateThread(
                          threadId,
                          titleInputController.text,
                          descriptionInputController.text);

                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Update", key: Key('updateButtonText')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteThread(String threadId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: const Text(
              "Deleting your Thread will also delete all replies associated with it. Do you want to proceed?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete Thread'),
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.controller.deleteThread(threadId);
              },
            ),
          ],
        );
      },
    );
  }
}
