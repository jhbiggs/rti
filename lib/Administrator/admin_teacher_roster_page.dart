import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rti/Model/subject.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import 'package:rti/Teacher/teacher.dart';
import '../Model/Authentication/application_state.dart';
import '../Model/Authentication/authentication.dart';
import '../Model/constants.dart';
import '../RTIAssignment/rti_assignment_list.dart';

class AdminTeacherRosterScreen extends StatelessWidget {
  static const routeName = '/teacher_roster';

  const AdminTeacherRosterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Teacher;
    return Scaffold(
      appBar: AppBar(
        title: Text('${args.name} Assignments'),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: AdminTeacherRoster(teacher: args),
          ),
        ),
      ),
    );
  }
}

class AdminTeacherRoster extends StatefulWidget {
  late Teacher teacher;

  AdminTeacherRoster({Key? key, required this.teacher}) : super(key: key);

  @override
  _AdminTeacherRosterState createState() => _AdminTeacherRosterState();
}

class _AdminTeacherRosterState extends State<AdminTeacherRoster> {
  late List<RTIAssignment> assignmentsInConstants;

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
                    assignments: appState.guestBookMessages
                        .where(
                            (element) => element.teacher == widget.teacher.name)
                        .toList(),
                  ),
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
