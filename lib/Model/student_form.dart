/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */

// student form is a data class to store data fields from a google sheet

import 'package:faker/faker.dart';

import '../Teacher/teacher.dart';

class StudentForm {
  String studentName;
  String subject;
  String assignment;
  Teacher? teacher;
  String standard;

  StudentForm(this.studentName, this.subject, this.standard, this.assignment);

  factory StudentForm.fromJson(dynamic json) {
    return StudentForm('${json['name']}', '${json['subject']}',
        '${json['standard']}', '${json['assignment']}');
  }

  // method to make get parameters
  Map toJson() => {
        'row_id': "appGen${RandomGenerator().integer(10000)}",
        'student_name': studentName,
        'subject': subject,
        'id': 'abcd1234',
        'teacher': teacher?.name ?? "no teacher assigned",
        'standard': standard,
        'classroom': teacher?.classroom ?? "no classroom assigned",
        'assignment': assignment,
        'name': studentName,
      };
}
