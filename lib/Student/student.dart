import 'package:rti/Model/Authentication/access_code_generator.dart';
import 'package:rti/Parent/parent.dart';

class Student {
  late String _name;
  late String _grade;
  late List<Parent> _parents = [];
  late String _id;
  // static final Student _blank = Student(name: "no student");

  Map<String, dynamic> toJson() => {'name': _name, 'id': _id};
  Student({required String name, subject}) {
    _name = name;
    _id = getRandomString(5);
    // print(_id);
  }

  // static Student getBlank() {
  //   return _blank;
  // }

  void setName(String name) {
    _name = name;
  }

  String getCode() {
    return _id;
  }

  String getName() {
    return _name;
  }

  void setGrade(String grade) {
    _grade = grade;
  }

  String getGrade() {
    return _grade;
  }

  List<Parent> getParents() {
    return _parents;
  }

  void setParents(List<Parent> parents) {
    _parents = parents;
  }
}
