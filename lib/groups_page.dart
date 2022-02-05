import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import 'package:rti/Student/student.dart';

import 'Model/constants.dart';
import 'group.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: GroupScreenForm(),
          ),
        ),
      ),
    );
  }
}

class GroupScreenForm extends StatefulWidget {
  const GroupScreenForm({Key? key}) : super(key: key);

  @override
  _GroupScreenFormState createState() => _GroupScreenFormState();
}

class _GroupScreenFormState extends State<GroupScreenForm> {
  final items = Constants.groups;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: items.elementAt(index).getStudents().isNotEmpty
              ? Theme.of(context).errorColor
              : Theme.of(context).cardColor,
          elevation: 5,
          child: ListTile(
            title: Text("${items.elementAt(index).name}: "
                "${items.elementAt(index).getSubject()} \n"
                "Teacher: ${items.elementAt(index).teacher.name}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StudentRTIGroupListScreen(group: items.elementAt(index)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class StudentRTIGroupListScreen extends StatelessWidget {
  const StudentRTIGroupListScreen({Key? key, required this.group})
      : super(key: key);
  final Group group;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students within ${group.name}'),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: StudentRTIGroupList(group: group),
          ),
        ),
      ),
    );
  }
}

class StudentRTIGroupList extends StatefulWidget {
  const StudentRTIGroupList({Key? key, required this.group}) : super(key: key);
  final Group group;
  @override
  _StudentRTIGroupListState createState() => _StudentRTIGroupListState();
}

class _StudentRTIGroupListState extends State<StudentRTIGroupList> {
  late final List<Student> students = widget.group.getStudents();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (BuildContext context, int index) {
        RTIAssignment assignment = Constants.assignments.firstWhere(
            (element) =>
                element.student.getCode == students.elementAt(index).getCode,
            orElse: () => RTIAssignment.getBlank());
        return Card(
          elevation: 5,
          child: ListTile(
            title: Text("Student: ${students.elementAt(index).getName()},\n"
                "Subject: ${widget.group.getSubject()} \n"
                "Teacher: ${widget.group.getTeacher().name}\n"
                "Standard: ${assignment.standard}\n"
                "Dates Assigned: ${DateFormat.MMMMEEEEd().format(assignment.startDate)} "
                "to ${DateFormat.MMMMEEEEd().format(assignment.endDate ?? DateTime.now().add(const Duration(days: 14)))}"),
            onTap: () {},
          ),
        );
      },
    );
  }
}
