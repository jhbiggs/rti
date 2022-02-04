import 'package:rti/Model/constants.dart';
import 'package:rti/Student/student.dart';

import 'group.dart';

class RTIAssignment {
  late DateTime startDate;
  late DateTime? endDate;
  final String? standard;
  final Student student;
  final String? subject;
  late Group group;
  late String? teacher;

  static final RTIAssignment _blank = RTIAssignment(
      startDate: DateTime.now(),
      standard: "none",
      student: Student(name: "none"),
      subject: "none",
      teacher: "none");

  static RTIAssignment getBlank() {
    return _blank;
  }

  RTIAssignment(
      {required this.standard,
      required this.student,
      required this.subject,
      required this.startDate,
      this.endDate,
      this.teacher}) {
    if (this.endDate == null) {
      endDate = startDate.add(Duration(days: 21));
    }
    //assign a relevant teacher, or let the people know there's no available teacher
    group = Constants.groups.firstWhere(
        (element) => element.getSubject() == subject,
        orElse: () => Group.getBlank());
    if (group != Group.getBlank()) {
      group.addStudentToGroup(student);
    }

    // print(
    //     "Your requested operation succeeded? ${group.name} with teacher ${group.getTeacher().name}");
  }

  //check the counts in relevant teachers' classes until a suitable spot is found

}
