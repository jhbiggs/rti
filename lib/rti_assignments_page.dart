import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rti/rti_assignment.dart';
import 'Model/Authentication/application_state.dart';
import 'Model/Authentication/authentication.dart';
import 'Model/constants.dart';
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
  @override
  void initState() {
    super.initState();
    assignmentsInConstants = Constants.assignments;
    assignmentsInConstants
        .sort((a, b) => a.student.getName().compareTo(b.student.getName()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  Row(children: [Text("hello")]),
                  Center(
                      child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 0,
                    itemBuilder: (context, index) => Card(
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                            '${Constants.assignments.elementAt(index).student.getName()} is assigned to '
                            ' ${Constants.assignments.elementAt(index).group.getTeacher().name}'),
                        subtitle: Text(
                            'needs help with ${Constants.assignments.elementAt(index).standard}'),
                        onTap: () {},
                      ),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ]),
      ],
    );
  }
}
