import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rti/Model/constants.dart';
import 'package:rti/rti_assignment.dart';
import 'package:rti/Student/student.dart';

import 'children.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Profile'),
      ),
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: Card(
            child: ParentForm(),
          ),
        ),
      ),
    );
  }
}

class ParentForm extends StatefulWidget {
  const ParentForm({Key? key}) : super(key: key);

  @override
  _ParentFormState createState() => _ParentFormState();
}

class _ParentFormState extends State<ParentForm> {
  final _studentCodeTextController = TextEditingController();
  late List<Student> students;

  @override
  initState() {
    super.initState();
    students = Children.of(parent: UserData.parent).isEmpty
        ? []
        : Children.of(parent: UserData.parent);
  }

  //get children from code
  void _checkAndConfirmStudent() async {
    final studentCode = _studentCodeTextController.text;
    final newStudent = Constants.studentTestList.firstWhere(
      (student) => student.getCode() == studentCode,
    );
    students.add(newStudent);
    UserData.parent!.codeList.add(studentCode);
    setState(() {
      _studentCodeTextController.text = "";
    });

    // print(newStudent.getName());
  }

  //store code internally
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _studentCodeTextController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Student Code'),
              onEditingComplete: _checkAndConfirmStudent,
            ),
          ),

          //populate listview with tiles for each child
          ListView.builder(
            shrinkWrap: true,
            itemCount: students.length,
            itemBuilder: (context, index) => Card(
              elevation: 5,
              child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    decoration: const BoxDecoration(
                        border: Border(
                            right:
                                BorderSide(width: 1.0, color: Colors.white24))),
                    child: const Icon(Icons.autorenew, color: Colors.white),
                  ),
                  title: Text(
                    students.elementAt(index).getName(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                  subtitle: Row(
                    children: <Widget>[
                      const Icon(Icons.linear_scale,
                          color: Colors.yellowAccent),
                      Text(
                          Constants.assignments
                                  .firstWhere(
                                      (element) =>
                                          element.student.getCode() ==
                                          students.elementAt(index).getCode(),
                                      orElse: () => RTIAssignment.getBlank())
                                  .subject ??
                              "no subject assigned",
                          style: const TextStyle(color: Colors.white))
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
