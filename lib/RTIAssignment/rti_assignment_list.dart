import 'dart:async';

import 'package:field_suggestion/field_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import 'package:rti/widgets.dart';

import '../Student/student.dart';
import '../Model/constants.dart';

class RtIAssignmentMessage {
  RtIAssignmentMessage({required this.teacherName, required this.objective});
  final String teacherName;
  final String objective;
  // final String subject;
  // final String standard;
}

class RtIAssignmentList extends StatefulWidget {
  RtIAssignmentList(
      {Key? key, required this.addAssignment, required this.assignments})
      : super(key: key);
  final FutureOr<void> Function(RTIAssignment assignment) addAssignment;
  List<RTIAssignment> assignments;

  @override
  _RtIAssignmentListState createState() => _RtIAssignmentListState();
}

class _RtIAssignmentListState extends State<RtIAssignmentList> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RtIAssignmentListState');
  final _controller = TextEditingController();
  final _subjectTextController = TextEditingController();
  final _standardTextController = TextEditingController();
  final _nameBoxController = BoxController();
  final _nameTextController = TextEditingController();
  final _studentSuggestions = Constants.studentTestList;
  late Student _selectedStudent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: const EdgeInsets.all(8.0),
          child: Header("Assign a student?"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: _subjectTextController,
                decoration: const InputDecoration(
                  hintText: 'subject',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter field value and continue';
                  }
                  return null;
                },
              )),
              Expanded(
                  child: TextFormField(
                controller: _standardTextController,
                decoration: const InputDecoration(
                  hintText: 'standard',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter your message and continue';
                  }
                  return null;
                },
              )),
            ],
          ),
        ),
        StyledButton(
            child: Row(children: [
              Expanded(
                child: FieldSuggestion(
                  wSlideAnimation: true,
                  fieldDecoration: const InputDecoration(
                    hintText: 'Name', // optional
                  ),
                  // If you're using list which includes a class,
                  // Don't forget to add a search by property.
                  // Or use [customSearch] property to implement custom searching functionality.
                  //
                  // customSearch: (item, input) {
                  //   return item.getName().toString().contains(input);
                  // },

                  // The field suggestion needs toJson mehtod inside your model right?
                  searchBy: const ['name'],
                  // If you're using default suggestion item widgets
                  // then title will be searchBy property's first value.
                  boxController: _nameBoxController,
                  textController: _nameTextController,
                  suggestionList: _studentSuggestions,
                  itemStyle: const SuggestionItemStyle(
                    backgroundColor: Color(0xff000000),
                    leading: Icon(Icons.person),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 1,
                        spreadRadius: 1,
                        offset: Offset(0, 2),
                        color: Color(0x99d599D5),
                      ),
                    ],
                  ),
                  onItemSelected: (value) {
                    _selectedStudent = Constants.studentTestList.firstWhere(
                        (element) => element.getCode() == value['id']);
                    // The field suggestion needs toJson mehtod inside your model right?
                    // So that's mean it converts your model to json.
                    // Then the output has to be JSON (Map). So now we can get our value's email.
                    // print(value['name']);
                  },
                ),
              ),
              const Icon(Icons.send),
              const SizedBox(width: 8),
              const Text('SEND')
            ]),
            onPressed: () async {
              await widget.addAssignment(RTIAssignment(
                  /*TODO: get the teacher name from the userInfo and add it to the assignment
                Must have a model on the server checking the number of students already
                in the class.*/
                  student: _selectedStudent,
                  subject: _subjectTextController.text,
                  standard: _standardTextController.text,
                  startDate: DateTime.now()));
              _subjectTextController.clear();
              _nameTextController.clear();
              _standardTextController.clear();
            }),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Header("Your List"),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: widget.assignments.length,
            itemBuilder: (context, index) => Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                        '${widget.assignments.elementAt(index).student.getName()} needs help in '
                        ' ${widget.assignments.elementAt(index).subject} with '
                        '${widget.assignments.elementAt(index).standard}'),
                    subtitle: Text(
                        'from ${DateFormat.MMMMEEEEd().format(widget.assignments.elementAt(index).startDate)} '
                        'until ${DateFormat.MMMMEEEEd().format(widget.assignments.elementAt(index).endDate!)}'),
                    onTap: () {},
                  ),
                )),
      ],
    );
  }
}
