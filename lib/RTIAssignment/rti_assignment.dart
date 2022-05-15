/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'package:com.mindframe.rti/Model/constants.dart';
import 'package:com.mindframe.rti/Student/student.dart';

import '../group.dart';

class RTIAssignment {
  late DateTime startDate;
  late DateTime? endDate;
  final String? standard;
  final Student student;
  final String? subject;
  late Group group;
  late String? teacher;
  final String assignmentName;

  static final RTIAssignment _blank = RTIAssignment(
      startDate: DateTime.now(),
      standard: "none",
      student: Student(
        name: "none",
        accessCode: '',
      ), //TODO:Implement access Code
      subject: "none",
      teacher: "none",
      assignmentName: "no assignment yet!");

  static RTIAssignment getBlank() {
    return _blank;
  }

  RTIAssignment(
      {required this.standard,
      required this.student,
      required this.subject,
      required this.startDate,
      required this.assignmentName,
      this.endDate,
      this.teacher}) {
    endDate ??= startDate.add(const Duration(days: 21));
    //assign a relevant teacher, or let the people know there's no available teacher
    group = Constants.groups.firstWhere(
        (element) => element.getSubject().name == subject,
        orElse: () => Group.getBlank());
    if (group != Group.getBlank()) {
      group.addStudentToGroup(student);
    }

    // print(
    //     "Your requested operation succeeded? ${group.name} with teacher ${group.getTeacher().name}");
  }

  //check the counts in relevant teachers' classes until a suitable spot is found

}
