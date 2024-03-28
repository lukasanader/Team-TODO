import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/discovery_view/discovery_view_dialogs.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/controller/create_topic_controllers/topic_controller.dart';
import 'package:info_hub_app/topics/create_topic/helpers/categories/category_controller.dart';
import 'package:info_hub_app/topics/create_topic/helpers/categories/category_model.dart';

import 'package:info_hub_app/helpers/topics_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/topic_model.dart';

class DiscoveryView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  const DiscoveryView(
      {super.key,
      required this.auth,
      required this.storage,
      required this.firestore});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  final TextEditingController _searchController = TextEditingController();

  List<Topic> _topicsList = [];
  List<Topic> _displayedTopicsList = [];

  late List<bool> isSelected = [];
  List<Widget> _categoriesWidget = [];
  List<String> _categories = [];
  List<String> categoriesSelected = [];

  //this is necessary to allow for the UI to update 
  //when changes are made on other screens
  late StreamSubscription<QuerySnapshot<Object?>> _topicsSubscription;

  @override
  void initState() {
    super.initState();
    initializeData();
    widget.firestore
        .collection('categories')
        .snapshots()
        .listen(_updateCategoryList);
  }

  @override
  void dispose() {
    _topicsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search',
          ),
          onChanged: (query) {
            _searchData(query);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  addVerticalSpace(10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    //toggle buttons to chose categories
                    child: ToggleButtons(
                      isSelected: isSelected,
                      onPressed: (int index) {
                        setState(() {
                          isSelected[index] = !isSelected[index];
                          if (!categoriesSelected
                              .contains(_categories[index])) {
                            categoriesSelected.add(_categories[index]);
                          } else {
                            categoriesSelected.remove(_categories[index]);
                          }
                          _searchData(_searchController.text);
                        });
                      },
                      children: List.generate(
                        _categoriesWidget.length,
                        (index) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: _categoriesWidget[index],
                        ),
                      ),
                    ),
                  ),
                  addVerticalSpace(10),

                  //listbuilder to actually create the list of topics
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _displayedTopicsList.isEmpty
                        ? 1
                        : _displayedTopicsList.length * 2 - 1,
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        // Add Padding and Container between TopicCards
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        );
                      } else {
                        final topicIndex = index ~/ 2;
                        if (_displayedTopicsList.isEmpty &&
                            _topicsList.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if (_displayedTopicsList.isEmpty) {
                            return const ListTile(
                              title: Text(
                                "Sorry there are no topics for this!",
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            return TopicCard(
                              widget.firestore,
                              widget.auth,
                              widget.storage,
                              _displayedTopicsList[topicIndex],
                              "topic",
                            );
                          }
                        }
                      }
                    },
                  ),
                  addVerticalSpace(20),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              addQuestionDialog(context, widget.firestore, widget.auth);
            },
            child: const Text("Ask a question!"),
          ),
          addVerticalSpace(20),
        ],
      ),
    );
  }

  Future<void> initializeData() async {
    getCategoryList();
    await getAllTopicsList().then((_) {
      setState(() {
        _displayedTopicsList = _topicsList;
      });
    });


    Query<Object?> topicsQuery = await TopicController(auth: widget.auth, firestore: widget.firestore).getTopicQuery();


    _topicsSubscription = topicsQuery.snapshots().listen(_updateTopicsList);
  }


  //logic to implement searching filter
  void _searchData(String query) {
    updateTopicListBasedOnCategory(categoriesSelected);

    if (query.isNotEmpty) {
      List<Topic> tempList = [];
      for (int i = 0; i < _displayedTopicsList.length; i++) {
        Topic topic = _displayedTopicsList[i];
        if (topic.title != null) {
          String title = topic.title.toString().toLowerCase();
          if (title.contains(query.toLowerCase())) {
            tempList.add(topic);
          }
        }
      }

      setState(() {
        _displayedTopicsList = tempList;
      });
    }
  }

  Future getAllTopicsList() async {
    List<Topic> tempList =
        await TopicController(auth: widget.auth, firestore: widget.firestore)
            .getTopicList();

    setState(() {
      _topicsList = tempList;
    });
  }

  //implements logic for category based filtering
  Future updateTopicListBasedOnCategory(List<String> categories) async {
    if (categories.isNotEmpty) {
      List<Topic> categoryTopicList = [];
      for (var topic in _topicsList) {
        if (topic.categories != null) {
          if (categories.every((item) => topic.categories!.contains(item))) {
            categoryTopicList.add(topic);
          }
        }
      }

      setState(() {
        _displayedTopicsList = categoryTopicList;
      });
    } else {
      setState(() {
        _displayedTopicsList = _topicsList;
      });
    }
  }

  Future getCategoryList() async {
    List<String> tempStringList = [];
    List<Widget> tempWidgetList = [];

    List<Category> categories =
        await CategoryController(widget.firestore).getCategoryList();

    for (Category category in categories) {
      tempStringList.add(category.name!);
      tempWidgetList.add(Text(category.name!));
    }

    setState(() {
      _categories = tempStringList;
      _categoriesWidget = tempWidgetList;
      isSelected = List<bool>.filled(_categoriesWidget.length, false);
    });
  }

  void _updateTopicsList(QuerySnapshot<Object?> snapshot) {
    final List<QueryDocumentSnapshot<Object?>> topics = snapshot.docs;
    final List<Topic> topicList =
        topics.map((doc) => Topic.fromSnapshot(doc)).toList();
    setState(() {
      _topicsList = topicList;
      _displayedTopicsList = List.from(_topicsList);
    });
    updateTopicListBasedOnCategory(categoriesSelected);
  }

  void _updateCategoryList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    categoriesSelected = [];
    getCategoryList();
    updateTopicListBasedOnCategory(categoriesSelected);
  }
}
