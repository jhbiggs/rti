import "package:flutter/material.dart";

import '../Model/constants.dart';

class RTITeacherScreen extends StatelessWidget {
  const RTITeacherScreen({Key? key}) : super(key: key);

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
            child: RTITeacherForm(),
          ),
        ),
      ),
    );
  }
}

class RTITeacherForm extends StatefulWidget {
  const RTITeacherForm({Key? key}) : super(key: key);

  @override
  _RTITeacherFormState createState() => _RTITeacherFormState();
}

class _RTITeacherFormState extends State<RTITeacherForm> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView.builder(
      itemCount: Constants.assignments.length,
      itemBuilder: (context, index) => Card(
        elevation: 5,
        child: ListTile(
          title: Text(
              '${Constants.assignments.elementAt(index).student.getName()} is assigned to '
              ' ${Constants.assignments.elementAt(index).endDate}'),
          subtitle: Text(
              'needs help with ${Constants.assignments.elementAt(index).standard}'),
          onTap: () {},
        ),
      ),
    ));
  }
}
