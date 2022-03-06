import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rti/Model/subject.dart';
import 'package:rti/Parent/parent.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import 'package:rti/Student/student.dart';
import 'package:rti/Teacher/teacher.dart';
import 'package:rti/subjects_page.dart';
import 'package:rti/Model/Authentication/access_code_generator.dart';

import '../Administrator/administrator.dart';
import 'role.dart';
import '../group.dart';

class Constants {
  static const int _classCountDefault = 30;
  static List<RTIAssignment> assignments = List.generate(
      50,
      (index) => RTIAssignment(
          student: Student(
              name: faker.person.name(), accessCode: getRandomString(5)),
          standard: "Factoring Polynomials",
          subject: "math",
          startDate: DateTime.now(),
          teacher: "Mrs. Highsmith",
          assignmentName: "Problem Set A"));
  static List<Parent> parents =
      List.generate(30, (index) => Parent(name: faker.person.name()));
  static var subjects = Subject.values.map((e) => e.name).toList();
  static List<Group> groups =
      teachers.map((element) => Group(element.subject, element)).toList();
  static List<Teacher> teachers = [];

  //static function offers a list of teachers from Firebase
  static Future<HttpsCallableResult> listTeachers() async {
    //server-side firebase function
    FirebaseFunctions functions = FirebaseFunctions.instance;

    //listAllUsers is function on Firebase
    HttpsCallable listTeachersFunction =
        functions.httpsCallable('listAllUsers');

    //call the callable as a function and invoke it server-side
    final results = await listTeachersFunction();

    //return the listResult of all teacher users
    return results;
  }

  static final faker = Faker();

  static List<Student> studentTestList = List.generate(
      50,
      (index) =>
          Student(name: faker.person.name(), accessCode: getRandomString(5)));

  static List<Student> studentTestList2 = List.generate(
      50,
      (index) =>
          Student(name: faker.person.name(), accessCode: getRandomString(5)));

  static int getClassCountDefault() {
    return _classCountDefault;
  }
}

class UserData {
  late String firstName;
  late String lastName;
  late String userName;
  static Subject? subject;
  static bool administrator = false;
  static bool teacher = false;
  static bool parent = false;
  static bool student = false;
  static late Role role = Role.teacher;

  String getFirstName() {
    return firstName;
  }

  String getLastName() {
    return lastName;
  }

  String getUserName() {
    return userName;
  }

  Role getRole() {
    return role;
  }
}
