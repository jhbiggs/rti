import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'Model/constants.dart';
import 'Model/subject.dart';
import 'Teacher/teacher.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: SubjectsList(),
          ),
        ),
      ),
    );
  }
}

class SubjectsList extends StatefulWidget {
  const SubjectsList({Key? key}) : super(key: key);

  @override
  _SubjectsListState createState() => _SubjectsListState();
}

class _SubjectsListState extends State<SubjectsList> {
  late List<Subject> subjectList = [];
  late List<Teacher> teacherList = [];
  void getSubjects() async {
    final teacherListResult = await Constants.listTeachers();
    final tempList = teacherListResult.data['users'] as List<dynamic>;
    List<Subject> finalList = [];
    for (Map user in tempList) {
      if (user['customClaims']['subject'] != null) {
        final thisSubject = Subject.values.firstWhere((element) =>
            const CaseInsensitiveEquality().equals(
                element.name, ((user['customClaims']['subject'] as String))));
        subjectList.add(thisSubject);
        teacherList.add(Teacher(user['displayName'], thisSubject));
      }
    }
    setState(() {});
  }

  void populateSubjectList() {
    getSubjects();
  }

  @override
  void initState() {
    super.initState();
    populateSubjectList();
  }

  @override
  Widget build(BuildContext context) {
    subjectList.sort((a, b) => a.name.compareTo(b.name));
    return ListView.builder(
      itemCount: subjectList.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 5,
          child: ListTile(
            leading: const Icon(Icons.pages),
            title: Text(subjectList.elementAt(index).name),
            subtitle: Text(teacherList.elementAt(index).name),
          ),
        );
      },
    );
  }
}
