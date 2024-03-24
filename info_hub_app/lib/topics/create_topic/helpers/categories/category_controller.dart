import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/topics/create_topic/helpers/categories/category_model.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';

class CategoryController {
  final FirebaseFirestore _firestore;
  final CreateTopicScreenState screen;

  CategoryController(this._firestore, this.screen);

  void addCategory(String name) async {
    Category newCategory = Category();

    newCategory.name = name;

    CollectionReference db = _firestore.collection('categories');
    await db.add(newCategory.toJson());
  }

  void deleteCategory(String categoryName) async {
    QuerySnapshot categoryToDelete = await _firestore
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();

    QueryDocumentSnapshot category = categoryToDelete.docs[0];
    await _firestore.collection('categories').doc(category.id).delete();

    screen.categoriesOptions.remove(categoryName);
  }

  Future<List<Category>> getCategoryList() async {
    QuerySnapshot data =
        await _firestore.collection('categories').orderBy('name').get();

    List<Category> categoryList =
        List.from(data.docs.map((doc) => Category.fromSnapshot(doc)));

    return categoryList;
  }
}
