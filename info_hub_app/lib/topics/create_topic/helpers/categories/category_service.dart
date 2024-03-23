

class CategoryService {
  String name;
  int age;

  // Constructor
  CategoryService({required this.name, required this.age});

  // Methods
  void sayHello() {
    print('Hello, my name is $name and I am $age years old.');
  }
}