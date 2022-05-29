/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:faker/faker.dart';
import 'package:com.mindframe.rti/Model/subject.dart';
import 'package:com.mindframe.rti/Parent/parent.dart';
import 'package:com.mindframe.rti/RTIAssignment/rti_assignment.dart';
import 'package:com.mindframe.rti/Student/student.dart';
import 'package:com.mindframe.rti/Model/Authentication/access_code_generator.dart';
import 'role.dart';
import '../group.dart';

class Constants {
  static const String schoolCode = "chesterton";
  static const String googleSheetID =
      schoolCode + "/1bjrulMbs-oXz9154pwM3K3h7_JRMpbCh0v7J_o63jNU/Sheet1";
  static const String googleAppScriptWebURL =
      "https://script.google.com/macros/s/AKfycbyOqXCRpcDosARkdH8Jt-k-naXqvPfOgLIFCxMxFflQLNBX-E0I8TE-QJ7g1DrZ5_4/exec";
  static const int _classCountDefault = 30;
  static List<RTIAssignment> assignments = [];

  static var subjects = SubjectExtension.names;
  static List<Group> groups = [];
  // teachers.map((element) => Group(element.subject, element)).toList();
  static FutureOr<List<dynamic>> teachers = listTeachers();

  //static function offers a list of teachers from Firebase
  static FutureOr<List<dynamic>> listTeachers() async {
    //server-side firebase function
    FirebaseFunctions functions = FirebaseFunctions.instance;

    //listAllUsers is function on Firebase
    HttpsCallable listTeachersFunction =
        functions.httpsCallable('listAllUsers');
    //call the callable as a function and invoke it server-side
    final results = await listTeachersFunction();
    var userArray = List<Object?>.from(results.data['users']);
    for (var value in userArray) {
      // print(value.toString());
    }
    var resultsArray = [];
    for (Map<String, dynamic> user in results.data['users']) {
      if (user['customClaims'] != null &&
          user['customClaims']['role'] == 'admin') {
        resultsArray.add(user);
        print("Your user is ${user['customClaims']['subject'] ?? "nothing"} and"
            " the username is ${user['displayName']}");
      }
    }
    //return the listResult of all teacher users
    return resultsArray.toList();
  }

  // static final faker = Faker();

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
