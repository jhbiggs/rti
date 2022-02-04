import 'package:rti/Student/student.dart';
import 'package:rti/Teacher/teacher.dart';
import 'package:uuid/uuid.dart';

import 'Model/constants.dart';
import 'Model/subject.dart';

class Group {
  late Uuid id;
  late String? name;
  final List<Student> _students = [];
  late final Subject _subject;
  static int groupCounter = 0;
  late Teacher teacher;
  static final _blankGroup =
      Group(Subject.art, Teacher("No Teacher", Subject.art));

  int classCapacity = Constants.getClassCountDefault();

  Group(this._subject, this.teacher) {
    groupCounter++;
    name = "Group $groupCounter";
    id = const Uuid();
  }
  static Group getBlank() {
    return _blankGroup;
  }

  Group addStudentToGroup(Student newStudent) {
    //check if there are groups with this subject already
    var groupsWithThisSubject =
        Constants.groups.where((element) => element._subject == _subject);
    //if there are groups with the subject, find the one with the lowest number of students
    groupsWithThisSubject
        .toList()
        .sort((a, b) => a._students.length.compareTo(b._students.length));
    var lowestCountGroup = groupsWithThisSubject.first;
    //place the student in the group with the lowest number
    if (lowestCountGroup.hasRoom()) {
      lowestCountGroup._students.add(newStudent);
      return lowestCountGroup;
    }
    //no groups available with a teacher?, assign a blank group
    return Group(_subject, Teacher("none available", _subject));
  }

  bool hasRoom() {
    return _students.length < classCapacity;
  }

  int numberOfSpotsLeft() {
    return classCapacity - _students.length;
  }

  List<Student> getStudents() {
    return _students;
  }

  Subject getSubject() {
    return _subject;
  }

  Teacher getTeacher() {
    return teacher;
  }
}
