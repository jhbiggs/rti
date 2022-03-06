import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rti/Administrator/StudentAssignmentScreen.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import '../Model/Authentication/application_state.dart';
import '../Model/Authentication/authentication.dart';
import '../Model/constants.dart';
import 'rti_assignment_list.dart';

class RTIAssignmentsScreen extends StatelessWidget {
  const RTIAssignmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student RTI Assignments'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: RTIAssignments(),
          ),
        ),
      ),
    );
  }
}

class RTIAssignments extends StatefulWidget {
  const RTIAssignments({Key? key}) : super(key: key);

  @override
  _RTIAssignmentsState createState() => _RTIAssignmentsState();
}

class _RTIAssignmentsState extends State<RTIAssignments> {
  late List<RTIAssignment> assignmentsInConstants;

  void _pushStudentAssignmentPage(RTIAssignment assignment) {
    /* The student assignment page shows the assignment from the Google
    Sheet.  Currently the column heading on the Google sheet is "missing 
    assignment" and the field contains a description or a link to another 
    Google Doc assignment. The relevant information is contained within
    the RTIAssignment object. */

    Navigator.pushNamed(context, StudentAssignmentScreen.routeName,
        arguments: assignment);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(children: [
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                  RtIAssignmentList(
                    addAssignment: (assignment) =>
                        appState.addAssignmentToList(assignment),
                    assignments: appState.guestBookMessages,
                  ),
                  // Center(
                  //     child: ListView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: 0,
                  //   itemBuilder: (context, index) => Card(
                  //     elevation: 5,
                  //     child: ListTile(
                  //       title: Text(
                  //           '${Constants.assignments.elementAt(index).student.getName()} is assigned to '
                  //           ' ${Constants.assignments.elementAt(index).group.getTeacher().name}'),
                  //       subtitle: Text(
                  //           'needs help with ${Constants.assignments.elementAt(index).standard}'),
                  //       onTap: () {
                  //         print('student card tapped');
                  //         _pushStudentAssignmentPage(
                  //             Constants.assignments.elementAt(index));
                  //       },
                  //     ),
                  //   ),
                  // )),
                ],
              ],
            ),
          ),
        ]),
      ],
    );
  }
}
