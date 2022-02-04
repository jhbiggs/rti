import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rti/Model/subject.dart';
import 'package:rti/Teacher/teacher.dart';

import '../Model/constants.dart';

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher List'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: TeachersList(),
          ),
        ),
      ),
    );
  }
}

class TeachersList extends StatefulWidget {
  const TeachersList({Key? key}) : super(key: key);

  @override
  _TeachersListState createState() => _TeachersListState();
}

class _TeachersListState extends State<TeachersList> {
  late List<Teacher> teacherList = [];

//async getTeachers comes from Constants file
  void getTeachers() async {
    //call Future and await result
    final teacherListResult = await Constants.listTeachers();

    final tempList = teacherListResult.data['users'] as List<dynamic>;
    for (Map user in tempList) {
      if (user['customClaims']['teacher'] != null &&
          user['customClaims']['teacher'] == true &&
          user['customClaims']['subject'] != null) {
        final String teacherName = user['displayName'];
        teacherList.add(Teacher(
            teacherName,
            Subject.values.firstWhere((element) =>
                const CaseInsensitiveEquality().equals(element.name,
                    ((user['customClaims']['subject']) as String)))));
      }
    }
    teacherList.sort((a, b) => a.subject.name.compareTo(b.subject.name));
    setState(() {});
  }

//init can't have an async function...
  void populateTeacherList() {
    getTeachers();
  }

  @override
  void initState() {
    super.initState();
    populateTeacherList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: teacherList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            child: ListTile(
                leading: const Icon(Icons.person),
                title: Text('Teacher: ${teacherList.elementAt(index).name},'
                    ' \nSubject: ${teacherList.elementAt(index).subject.name}')),
          );
        });
  }
}
