/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import 'package:rti/Student/student.dart';

import '../Model/constants.dart';

class StudentScreen extends StatelessWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: StudentFormScreen(),
          ),
        ),
      ),
    );
  }
}

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({Key? key}) : super(key: key);

  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  late Student studentSelf;
  //making sure there is no null pointer exception thrown if there are no assignments yet.
  late List<RTIAssignment> studentSelfAssignments = [];

  @override
  initState() {
    super.initState();
    studentSelf = Constants.studentTestList.first;
    // Constants.studentTestList.add(studentSelf);
    // print("new student code " "${studentSelf.getCode()}");
    // if (studentSelf != Student.getBlank()) {
    //   studentSelfAssignments.addAll(Constants.assignments
    //       .where((assignment) =>
    //           assignment.student.getCode() == studentSelf.getCode())
    //       .toList());
    // }
  }

  //get children from code

  @override
  Widget build(BuildContext context) {
    //TODO: display the assignment information including subject, teacher, dates
    return Center(
      child: Column(
        children: [
          Card(
              elevation: 5,
              child: ListTile(
                autofocus: false,
                title: Text(studentSelf.getName()),
              )),
          //populate listview with tiles for each child
          ListView.builder(
            shrinkWrap: true,
            itemCount: studentSelfAssignments.length,
            itemBuilder: (context, index) => Card(
              elevation: 5,
              child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  title: Row(
                    children: <Widget>[
                      // const Icon(Icons.linear_scale,
                      //     color: Colors.yellowAccent),
                      Text(studentSelfAssignments.elementAt(index).subject!,
                          style: const TextStyle(color: Colors.white))
                    ],
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Text(
                          '${DateFormat.MMMMEEEEd().format(studentSelfAssignments.elementAt(index).startDate)} to '
                          '${DateFormat.MMMMEEEEd().format(studentSelfAssignments.elementAt(index).endDate!)}',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right,
                      color: Colors.white, size: 30.0)),
            ),
          ),
        ],
      ),
    );
  }
}
