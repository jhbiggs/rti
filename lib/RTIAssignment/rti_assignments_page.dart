/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:com.mindframe.rti/RTIAssignment/rti_assignment.dart';
import '../Model/Authentication/application_state.dart';
import '../Model/Authentication/authentication.dart';
import 'rti_assignment_list.dart';

class RTIAssignmentsScreen extends StatelessWidget {
  const RTIAssignmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        flexibleSpace: Row(
            children:  [
               const Spacer(),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
                   children:  [
                     const Spacer(),
                     IconButton(
                        icon: const Icon(Icons.settings), 
                        onPressed: () async { await Navigator.of(context).pushNamed('/settings'); },
                        ),
                     const Spacer(),
                   ],
                 ),
               ),
            ],
          ),
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
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: ListView(
        children: [
          Column(children: [
            Consumer<ApplicationState>(
              builder: (context, appState, _) => 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (appState.loginState ==
                      ApplicationLoginState.loggedIn) ...[
                    RtIAssignmentList(
                      addAssignment: (assignment) =>
                          appState.addAssignmentToList(assignment),
                      assignments: appState.guestBookMessages,
                    ),
                  ],
                ],
              ),
            ),
          ]),
        ],
      ),
    
    );
  }
}
