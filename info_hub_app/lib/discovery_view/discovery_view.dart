import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/discovery_view/discovery_view_dialogs.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/topics/categories/category_model.dart';
import 'package:info_hub_app/topics/categories/category_service.dart';
import 'package:info_hub_app/topics/topics_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';

import '../controller/topic_question_controller.dart';

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
  List<Object> _topicsList = [];
  List<Object> _displayedTopicsList = [];

  late List<bool> isSelected = [];
  List<Widget> _categoriesWidget = [];
  List<String> _categories = [];
  List<String> categoriesSelected = [];



  @override
  void initState() {
    super.initState();
    getCategoryList();
    getAllTopicsList().then((_) {
      setState(() {
        _displayedTopicsList = _topicsList;
      });
    });
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
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  15.0), // Adjust the horizontal spacing here
                          child: _categoriesWidget[index],
                        ),
                      ),
                    ),
                  ),
                  addVerticalSpace(10),
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
                              _displayedTopicsList[topicIndex]
                                  as QueryDocumentSnapshot<Object>,
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


  void _searchData(String query) {
    updateTopicListBasedOnCategory(categoriesSelected);

    if (query.isNotEmpty) {
      List<QueryDocumentSnapshot<Object?>> tempList = [];

      for (int i = 0; i < _displayedTopicsList.length; i++) {
        QueryDocumentSnapshot topic =
            _displayedTopicsList[i] as QueryDocumentSnapshot<Object?>;
        if (topic['title'] != null) {
          String title = topic['title'].toString().toLowerCase();
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
    String role =
        await UserController(widget.auth, widget.firestore).getUserRoleType();
    late QuerySnapshot data;

    if (role == 'admin') {
      data = await widget.firestore.collection('topics').orderBy('title').get();
    } else {
      data = await widget.firestore
          .collection('topics')
          .where('tags', arrayContains: role)
          .orderBy('title')
          .get();
    }

    List<Object> tempList = List.from(data.docs);

    setState(() {
      _topicsList = tempList;
    });
  }

  Future updateTopicListBasedOnCategory(List<String> categories) async {
    if (categories.isNotEmpty) {
      List<Object> categoryTopicList = [];

      for (dynamic topic in _topicsList) {
        var data = topic.data();
        if (data != null && data.containsKey('categories')) {
          if (categories.every((item) => data['categories'].contains(item))) {
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
    List<Category> categoryList = await CategoryController(
      widget.firestore).getCategoryList();


    List<String> tempStringList = [];
    List<Widget> tempWidgetList = [];

    for (Category category in categoryList) {
      tempStringList.add(category.name.toString());
      tempWidgetList.add(Text(category.name.toString()));
    }

    setState(() {
      _categories = tempStringList;
      _categoriesWidget = tempWidgetList;
      isSelected = List<bool>.filled(_categoriesWidget.length, false);
    });
  }
}
