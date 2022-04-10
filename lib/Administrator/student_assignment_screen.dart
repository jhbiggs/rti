/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'package:flutter/material.dart';
import 'package:com.mindframe.rti/RTIAssignment/rti_assignment.dart';
import 'package:com.mindframe.rti/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentAssignmentScreen extends StatelessWidget {
  static const String _routeName = '/studentAssignmentScreen';
  static String get routeName => _routeName;
  const StudentAssignmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final studentAssignment =
        ModalRoute.of(context)!.settings.arguments as RTIAssignment;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Card(
          child: StudentAssignment(studentAssignment: studentAssignment),
        ),
      ),
    );
  }
}

class StudentAssignment extends StatefulWidget {
  const StudentAssignment({Key? key, required this.studentAssignment})
      : super(key: key);

  final RTIAssignment studentAssignment;

  @override
  State<StudentAssignment> createState() => _StudentAssignmentState();
}

class _StudentAssignmentState extends State<StudentAssignment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.studentAssignment.student.getName()}'s RTI Assignment"),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          children: [
            SizedBox(
                width: 400,
                child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Header('${widget.studentAssignment.subject}')))),
            SizedBox(
              width: 400,
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      isThreeLine: true,
                      title: Text('Standard'),
                      subtitle:
                          Text('a little about the purpose of the assignment'),
                      onTap: () {},
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        child: Column(
                          children: [
                            Text('${widget.studentAssignment.assignmentName}'),
                          ],
                        ),
                        onTap: () => {
                          // if ( canLaunch(widget.studentAssignment.assignmentName)){
                          launch('${widget.studentAssignment.assignmentName}')
                          // }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
