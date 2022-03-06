import 'package:flutter/material.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';

class StudentAssignmentScreen extends StatelessWidget {
  static const String _routeName = '/studentAssignmentScreen';
  static String get routeName => _routeName;
  const StudentAssignmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final studentAssignment =
        ModalRoute.of(context)!.settings.arguments as RTIAssignment;

    return Scaffold(
      appBar: AppBar(
        title: Text("${studentAssignment.student.getName()} RTI Assignment"),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: Text('$studentAssignment.assignmentName'),
          ),
        ),
      ),
    );
  }
}
