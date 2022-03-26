/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
// student form is a data class to store data fields from a google sheet

class StudentForm {
  String name;
  String subject;
  String assignment;
  // String? teacher;
  String standard;

  StudentForm(this.name, this.subject, this.standard, this.assignment);

  factory StudentForm.fromJson(dynamic json) {
    return StudentForm('${json['name']}', '${json['subject']}',
        '${json['standard']}', '${json['assignment']}');
  }

  // method to make get parameters
  Map toJson() => {
        'row_id': '42',
        'student_name': 'bob',
        'subject': subject,
        'id': 'abcd1234',
        'teacher': 'Mr. Magoo',
        'standard': standard,
        'classroom': 'Your mom\'s',
        'assignment': assignment,
        'name': name,
      };
}
