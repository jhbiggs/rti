import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rti/RTIAssignment/rti_assignments_page.dart';

import 'Model/Authentication/application_state.dart';
import 'Model/Authentication/authentication.dart';
import 'Model/subject.dart';
import 'RTIAssignment/rti_assignment.dart';
import 'RTIAssignment/rti_assignment_list.dart';

class RTIAssignmentsScreenBySubject extends StatelessWidget {
  const RTIAssignmentsScreenBySubject({Key? key}) : super(key: key);

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
            child: Card(
              child: RTIAssignmentsBySubject(),
            ),
          ),
        )));
  }
}

class RTIAssignmentsBySubject extends StatefulWidget {
  const RTIAssignmentsBySubject({Key? key}) : super(key: key);

  @override
  State<RTIAssignmentsBySubject> createState() =>
      _RTIAssignmentsBySubjectState();
}

class _RTIAssignmentsBySubjectState extends State<RTIAssignmentsBySubject> {
  @override
  Widget build(BuildContext context) {
    final subject = ModalRoute.of(context)!.settings.arguments as Subject;

    return Consumer<ApplicationState>(
        builder: (context, appState, _) => ListView(children: [
              RtIAssignmentList(
                assignments: appState.guestBookMessages
                    .where((element) => element.subject == subject.name)
                    .toList(),
                addAssignment: (RTIAssignment assignment) {},
              ),
            ]));
  }
}
