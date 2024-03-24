import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/topics/create_topic/helpers/categories/category_model.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';

class CategoryController {
  final FirebaseFirestore _firestore;

  CategoryController(this._firestore);

  void addCategory(String name) async {
    Category newCategory = Category();

    newCategory.name = name;

    CollectionReference db = _firestore.collection('categories');
    await db.add(newCategory.toJson());
  }

  void deleteCategory(Category category) async {
    await _firestore.collection('categories').doc(category.id).delete();

    QuerySnapshot topicsWithCategory = await _firestore
      .collection('topics')
      .where('categories', arrayContains: category.name)
      .get();
    
    for (QueryDocumentSnapshot topic in topicsWithCategory.docs) {
      final topicReference = topic.reference;
      await topicReference.update({
        'categories': FieldValue.arrayRemove([category.name])
      });
    }
  }

  Future<Category> getCategoryFromName(String categoryName) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();

    QueryDocumentSnapshot queryDocumentSnapshot = querySnapshot.docs[0];
    Category category = Category.fromSnapshot(queryDocumentSnapshot);

    return category;
  }

  Future<List<Category>> getCategoryList() async {
    QuerySnapshot data =
        await _firestore.collection('categories').orderBy('name').get();

    List<Category> categoryList =
        List.from(data.docs.map((doc) => Category.fromSnapshot(doc)));

    return categoryList;
  }
}
