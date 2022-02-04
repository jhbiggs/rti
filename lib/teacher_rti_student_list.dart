import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rti/rti_assignment.dart';
import 'package:rti/rti_assignment_list.dart';
import 'Model/Authentication/application_state.dart';
import 'Model/Authentication/authentication.dart';
import 'Model/constants.dart';

class TeacherRTIStudentScreen extends StatelessWidget {
  const TeacherRTIStudentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My RtI Assignments'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: TeacherRTIStudentList(),
          ),
        ),
      ),
    );
  }
}

class TeacherRTIStudentList extends StatefulWidget {
  const TeacherRTIStudentList({Key? key}) : super(key: key);

  @override
  _TeacherRTIStudentListState createState() => _TeacherRTIStudentListState();
}

class _TeacherRTIStudentListState extends State<TeacherRTIStudentList> {
  late List<RTIAssignment> assignmentsInConstants;
  final _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    assignmentsInConstants = Constants.assignments;
    assignmentsInConstants
        .sort((a, b) => a.student.getName().compareTo(b.student.getName()));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[
      const SizedBox(height: 8),
      const Divider(
        height: 8,
        thickness: 1,
        indent: 8,
        endIndent: 8,
        color: Colors.grey,
      ),
      Consumer<ApplicationState>(
        builder: (context, appState, _) => Wrap(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (appState.loginState == ApplicationLoginState.loggedIn) ...[
              RtIAssignmentList(
                addAssignment: (assignment) =>
                    appState.addAssignmentToList(assignment),
                assignments: appState.guestBookMessages,
              ),
            ],
          ],
        ),
      ),
    ]);
  }
}
