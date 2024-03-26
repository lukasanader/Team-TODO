  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/topics/create_topic/helpers/categories/category_controller.dart';
import 'package:info_hub_app/topics/create_topic/helpers/categories/category_model.dart';

class CategoryDialogManager {
  final FirebaseFirestore _firestore;
  final List<String> categoriesOptions;
  late CategoryController categoryController;
  Function updateCatergoryList;

  CategoryDialogManager(this._firestore, this.categoriesOptions, this.updateCatergoryList) {
    categoryController = CategoryController(_firestore);
  }

  void createNewCategoryDialog(context) {
    final TextEditingController newCategoryNameController = TextEditingController();

    newCategoryNameController.clear();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Create a new category"),
            content: TextField(
              controller: newCategoryNameController,
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (!categoriesOptions
                          .contains(newCategoryNameController.text) &&
                      newCategoryNameController.text.isNotEmpty) {
                    categoryController.addCategory(newCategoryNameController.text);
                    updateCatergoryList();
                    Navigator.of(context).pop();
                  } else {
                    return showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text('Warning!'),
                          content: Text(
                              "Make sure category names are different/not blank!"),
                        );
                      },
                    );
                  }
                },
                child: const Text("OK"),
              ),
            ],
          );
        });
  }

  void deleteCategoryDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Delete a category"),
              content: SizedBox(
                height: 300,
                width: 200,
                child: ListView.builder(
                  itemCount: categoriesOptions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(categoriesOptions[index]),
                      onTap: () {
                        deleteCategoryConfirmation(
                            categoriesOptions[index], context);
                      },
                    );
                  },
                ),
              ),
            );
          });
        });
  }


  Future<void> deleteCategoryConfirmation(String categoryName, context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: const Text("Are you sure you want to delete?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Category category = await categoryController.getCategoryFromName(categoryName);
                
                categoryController.deleteCategory(category);
                categoriesOptions.remove(categoryName);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                updateCatergoryList();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
